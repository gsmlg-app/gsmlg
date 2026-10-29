#!/usr/bin/env python3
"""Explicit online refresh and offline rebuild of bundled Android Alpine images."""

import argparse
import copy
import concurrent.futures
import fcntl
import gzip
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import tarfile
import tempfile
import urllib.request

SCRIPT_DIR = Path(__file__).resolve().parent
PLUGIN = SCRIPT_DIR.parent
ROOT = PLUGIN.parent.parent
RECIPE = PLUGIN / 'rootfs'
ASSETS = PLUGIN / 'android/src/main/assets/shell'
CONFIG = ASSETS / 'rootfs-config.json'
LOCK = RECIPE / 'rootfs.lock.json'
CACHE = ROOT / 'build/android-rootfs'
ARCHITECTURES = {
    'arm64-v8a': ('aarch64', 'linux/arm64'),
    'armeabi-v7a': ('armv7', 'linux/arm/v7'),
    'x86_64': ('x86_64', 'linux/amd64'),
    'x86': ('x86', 'linux/386'),
}
BUILD_PACKAGES = ['build-base', 'python3', 'bc', 'xz', 'patch']


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_text())


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + '\n')


def recipe_sha256():
    paths = [Path(__file__)] + sorted(path for path in RECIPE.rglob('*')
                                      if path.is_file() and path.name != LOCK.name
                                      and '__pycache__' not in path.parts)
    digest = hashlib.sha256()
    for path in paths:
        digest.update(path.relative_to(PLUGIN).as_posix().encode() + b'\0')
        digest.update(path.read_bytes() + b'\0')
    return digest.hexdigest()


def load_config():
    config = read_json(CONFIG)
    if config.get('schemaVersion') != 1:
        raise ValueError('Unsupported rootfs config schema')
    user = config['user']
    if user['name'] == 'root' or not re.fullmatch('[a-z][a-z0-9_-]*', user['name']):
        raise ValueError('Invalid rootfs user name')
    if any(type(user[key]) is not int or not 1 <= user[key] <= 65535
           for key in ('uid', 'gid')):
        raise ValueError('Rootfs UID/GID must be non-root integers in 1..65535')
    for key in ('home', 'shell'):
        if not re.fullmatch('/[A-Za-z0-9_./-]+', user[key]) or user[key] == '/' or any(part in ('.', '..') for part in user[key].split('/')):
            raise ValueError(f'Invalid user {key}')
    if not isinstance(config['packages'], list) or not all(
            isinstance(name, str) and re.fullmatch('[a-z0-9][a-z0-9+_.-]*', name)
            for name in config['packages']):
        raise ValueError('Expected plain Alpine package names')
    if not isinstance(config['sourcePackages'], list) or any(
            name != 'lrzsz' for name in config['sourcePackages']):
        raise ValueError('Only the audited lrzsz source recipe is supported')
    if not config['packages']:
        raise ValueError('At least one Alpine package is required; base-only images are not supported')
    return config


def upstream_base(abi):
    lock = read_json(SCRIPT_DIR / 'android_artifacts.lock.json')['alpine']
    arch = ARCHITECTURES[abi][0]
    version = lock['version']
    branch = '.'.join(version.split('.')[:2])
    return {
        'url': f'https://dl-cdn.alpinelinux.org/alpine/v{branch}/releases/{arch}/alpine-minirootfs-{version}-{arch}.tar.gz',
        'sha256': lock['sha256'][arch],
    }


def download(url, path, expected=None):
    if path.exists() and expected and sha256(path.read_bytes()) == expected:
        return
    print(f'Download {url}', flush=True)
    with urllib.request.urlopen(url, timeout=120) as response:
        data = response.read()
    if expected and sha256(data) != expected:
        raise ValueError(f'SHA256 mismatch: {url}')
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def docker(*arguments, capture=False):
    return subprocess.run(['docker', *arguments], check=True,
                          stdout=subprocess.PIPE if capture else None,
                          text=capture).stdout


def run_container(image, platform, work, command, network='none', export=None):
    container = docker('create', '--platform', platform, '--network', network,
                       '-v', f'{work.resolve()}:/work',
                       '-v', f'{RECIPE.resolve()}:/recipe:ro',
                       '--entrypoint', '/bin/sh', image, '-ec', command,
                       capture=True).strip()
    try:
        docker('start', '-a', container)
        # docker start -a does not propagate the container process exit status.
        status = int(docker('inspect', '--format', '{{.State.ExitCode}}', container,
                            capture=True).strip())
        if status:
            raise RuntimeError(f'Rootfs container exited with status {status}')
        if export:
            manifest = work / 'manifest.json'
            docker('cp', str(manifest), f'{container}:/etc/web-terminal/rootfs.json')
            docker('export', '--output', str(export), container)
    finally:
        docker('rm', '-f', container)


def parse_database(data):
    packages = []
    for record in data.decode().split('\n\n'):
        fields = dict(line.split(':', 1) for line in record.splitlines()
                      if ':' in line)
        if 'P' in fields:
            packages.append({'name': fields['P'], 'version': fields['V'],
                             'architecture': fields['A']})
    return sorted(packages, key=lambda package: package['name'])


def normalized_archive(source, destination):
    """Keep Android-supported GNU headers; materialize unsupported hardlinks."""
    with tarfile.open(source, 'r:') as incoming, destination.open('wb') as raw:
        members = {member.name.removeprefix('./').rstrip('/'): member
                   for member in incoming if member.name not in ('.', './')}
        with gzip.GzipFile(filename='', mode='wb', fileobj=raw, mtime=0) as zipped:
            with tarfile.open(fileobj=zipped, mode='w', format=tarfile.GNU_FORMAT) as outgoing:
                for name, member in sorted(members.items()):
                    if name.startswith('/') or '..' in PurePosixPath(name).parts:
                        raise ValueError(f'Unsafe archive member: {name}')
                    if not (member.isfile() or member.isdir() or member.issym() or member.islnk()):
                        continue
                    info = copy.copy(member)
                    info.name = name
                    info.mtime = 0
                    info.uname = info.gname = ''
                    info.pax_headers = {}
                    content = None
                    if member.isfile() or member.islnk():
                        target = member
                        visited = set()
                        while target.islnk():
                            if target.name in visited:
                                raise ValueError(f'Cyclic hardlink: {name}')
                            visited.add(target.name)
                            target = incoming._find_link_target(target)
                        if not target.isfile():
                            raise ValueError(f'Hardlink does not target a file: {name}')
                        content = incoming.extractfile(target)
                        if member.islnk():
                            info = copy.copy(target)
                            info.name = name
                            info.mtime = 0
                            info.uname = info.gname = ''
                            info.pax_headers = {}
                            info.type = tarfile.REGTYPE
                            info.linkname = ''
                    try:
                        outgoing.addfile(info, content)
                    finally:
                        if content:
                            content.close()


def input_manifest(inputs):
    urls = {}
    url_file = inputs / 'package-urls.txt'
    if url_file.exists():
        urls = {url.rsplit('/', 1)[-1]: url for url in url_file.read_text().splitlines()
                if url.startswith('https://')}
    sources = read_json(RECIPE / 'sources.json')
    for source in sources.values():
        urls[source['file']] = source['url']
    result = []
    for path in sorted(inputs.rglob('*')):
        if not path.is_file() or path.name == 'base.tgz':
            continue
        data = path.read_bytes()
        result.append({'file': path.relative_to(inputs).as_posix(),
                       'sha256': sha256(data), 'size': len(data),
                       'url': urls.get(path.name)})
    return result


def verify_inputs(inputs, architecture):
    base = inputs / 'base.tgz'
    if sha256(base.read_bytes()) != architecture['base']['sha256']:
        raise ValueError('Cached upstream rootfs checksum mismatch')
    for item in architecture['inputs']:
        relative = PurePosixPath(item['file'])
        if relative.is_absolute() or '..' in relative.parts:
            raise ValueError('Unsafe cached input path')
        data = (inputs / relative).read_bytes()
        if len(data) != item['size'] or sha256(data) != item['sha256']:
            raise ValueError(f'Cached input checksum mismatch: {relative}')


def refresh_inputs(abi, config, inputs, image, platform):
    for directory in ('runtime', 'build', 'indexes', 'sources'):
        (inputs / directory).mkdir(parents=True, exist_ok=True)
    for source in read_json(RECIPE / 'sources.json').values():
        if config['sourcePackages']:
            download(source['url'], inputs / 'sources' / source['file'], source['sha256'])
    packages = ' '.join(config['packages'])
    build_packages = ' '.join(BUILD_PACKAGES) if config['sourcePackages'] else ''
    command = (
        'apk --cache-dir /work/indexes update; '
        f'apk --cache-dir /work/indexes fetch --recursive --url --output /work/runtime {packages} > /work/package-urls.txt; '
    )
    if build_packages:
        command += f'apk --cache-dir /work/indexes fetch --recursive --url --output /work/build {build_packages} >> /work/package-urls.txt; '
    command += 'apk verify /work/runtime/*.apk'
    if build_packages:
        command += ' /work/build/*.apk'
    run_container(image, platform, inputs, command, network='bridge')


def build_architecture(abi, config, old=None, refresh=False):
    arch, platform = ARCHITECTURES[abi]
    base = upstream_base(abi)
    directory = CACHE / abi
    inputs = directory / 'inputs'
    inputs.mkdir(parents=True, exist_ok=True)
    if refresh:
        # Refresh replaces only this explicitly selected architecture's cache.
        for child in inputs.iterdir():
            if child.name != 'base.tgz':
                shutil.rmtree(child) if child.is_dir() else child.unlink()
        download(base['url'], inputs / 'base.tgz', base['sha256'])
    else:
        if old is None:
            raise ValueError(f'No locked architecture for {abi}; run refresh')
        verify_inputs(inputs, old)
    image = docker('import', '--platform', platform, str(inputs / 'base.tgz'), capture=True).strip()
    try:
        if refresh:
            refresh_inputs(abi, config, inputs, image, platform)
        with tempfile.TemporaryDirectory(prefix='work-', dir=directory) as temporary:
            work = Path(temporary)
            shutil.copytree(inputs, work, dirs_exist_ok=True, symlinks=True)
            if 'lrzsz' in config['sourcePackages']:
                run_container(image, platform, work, '/recipe/compile.sh')
                compiled = work / 'runtime/lrzsz-0.13.1-r0.apk'
                cached = inputs / 'runtime' / compiled.name
                if refresh:
                    shutil.copy2(compiled, cached)
                elif sha256(compiled.read_bytes()) != sha256(cached.read_bytes()):
                    raise ValueError(f'Offline source rebuild differs from lock: {abi}/lrzsz')
            run_container(image, platform, work,
                          'apk index --allow-untrusted --output /work/runtime/APKINDEX.tar.gz /work/runtime/*.apk')
            index = work / 'runtime/APKINDEX.tar.gz'
            if refresh:
                shutil.copy2(index, inputs / 'runtime/APKINDEX.tar.gz')
            else:
                # apk index includes a timestamp; use the exact locked index bytes.
                shutil.copy2(inputs / 'runtime/APKINDEX.tar.gz', index)
            (work / 'packages.txt').write_text(' '.join(config['packages'] + config['sourcePackages']))
            user = config['user']
            (work / 'user.env').write_text(''.join(
                f"{key}='{value}'\n" for key, value in {
                    'WT_USER': user['name'], 'WT_UID': user['uid'],
                    'WT_GID': user['gid'], 'WT_HOME': user['home'],
                    'WT_SHELL': user['shell'],
                }.items()))
            (work / 'checks.sh').write_text(command_checks(config))
            manifest = {'schemaVersion': 1, 'configSha256': sha256(CONFIG.read_bytes()),
                        'recipeSha256': recipe_sha256(), 'abi': abi,
                        'alpineArch': arch, 'user': user, 'packages': [],
                        'sourcePackages': config['sourcePackages']}
            write_json(work / 'manifest.json', manifest)
            exported = directory / 'rootfs.tar'
            # Assemble first, then get the installed DB before docker export.
            command = '/recipe/assemble.sh; cp /lib/apk/db/installed /work/installed.db'
            container = docker('create', '--platform', platform, '--network', 'none',
                               '-v', f'{work.resolve()}:/work', '-v', f'{RECIPE.resolve()}:/recipe:ro',
                               '--entrypoint', '/bin/sh', image, '-ec', command, capture=True).strip()
            try:
                docker('start', '-a', container)
                status = int(docker('inspect', '--format', '{{.State.ExitCode}}', container,
                                    capture=True).strip())
                if status:
                    raise RuntimeError(f'Rootfs assembly failed: {abi} status {status}')
                manifest['packages'] = parse_database((work / 'installed.db').read_bytes())
                write_json(work / 'manifest.json', manifest)
                docker('cp', str(work / 'manifest.json'), f'{container}:/etc/web-terminal/rootfs.json')
                docker('export', '--output', str(exported), container)
            finally:
                docker('rm', '-f', container)
            destination = ASSETS / abi / 'rootfs.tgz'
            candidate = directory / 'rootfs.tgz'
            normalized_archive(exported, candidate)
            data = candidate.read_bytes()
            if not refresh and sha256(data) != old['sha256']:
                raise ValueError(f'Offline image differs from lock: {abi}')
            shutil.copy2(candidate, destination)
            result = {'alpineArch': arch, 'platform': platform, 'base': base,
                      'inputs': input_manifest(inputs), 'packages': manifest['packages'],
                      'sha256': sha256(data), 'size': len(data)}
            print(f'PASS {abi}: {len(data)} bytes {result["sha256"]}', flush=True)
            return result
    finally:
        docker('image', 'rm', image)


def command_checks(config):
    checks = ['set -eu', 'test -x "$WT_SHELL"']
    commands = {'neovim': 'nvim --headless -u NONE -i NONE +q',
                'bash': 'bash --version >/dev/null', 'zsh': 'zsh --version',
                'ripgrep': 'rg --version', 'gawk': 'awk --version >/dev/null',
                'sed': 'sed --version >/dev/null', 'openssh': 'ssh -V',
                'openssl': 'openssl version', 'lrzsz': 'sz --version; rz --version'}
    for name in config['packages'] + config['sourcePackages']:
        if name in commands:
            checks.append(commands[name])
    checks += ['actual=$(su - "$WT_USER" -c \'printf "%s:%s:%s:%s" "$(id -u)" "$(id -g)" "$HOME" "$SHELL"\')',
               'test "$actual" = "$WT_UID:$WT_GID:$WT_HOME:$WT_SHELL"']
    return '\n'.join(checks) + '\n'


def verify_lock(abis=None):
    """Validate recipe/input identity without requiring generated output files."""
    config = load_config()
    lock = read_json(LOCK)
    if lock.get('schemaVersion') != 1:
        raise ValueError('Unsupported rootfs lock schema')
    if lock['configSha256'] != sha256(CONFIG.read_bytes()):
        raise ValueError('Rootfs config changed; run explicit refresh')
    if lock['recipeSha256'] != recipe_sha256():
        raise ValueError('Rootfs recipe changed; run explicit refresh')
    if lock['sources'] != read_json(RECIPE / 'sources.json'):
        raise ValueError('Source recipe differs from lock')
    for abi in abis or ARCHITECTURES:
        if lock['architectures'][abi]['base'] != upstream_base(abi):
            raise ValueError(f'Upstream input differs from original lock: {abi}')
    return lock


def verify_assets(abis=None):
    """Offline clean-checkout verification; does not require Docker or cache."""
    config = load_config()
    lock = verify_lock(abis)
    for abi in abis or ARCHITECTURES:
        entry = lock['architectures'][abi]
        data = (ASSETS / abi / 'rootfs.tgz').read_bytes()
        if len(data) != entry['size'] or sha256(data) != entry['sha256']:
            raise ValueError(f'Final rootfs checksum mismatch: {abi}')
        with tarfile.open(fileobj=io.BytesIO(data), mode='r:gz') as archive:
            manifest = json.load(archive.extractfile('etc/web-terminal/rootfs.json'))
            for key in ('configSha256', 'recipeSha256'):
                if manifest[key] != lock[key]:
                    raise ValueError(f'Embedded {key} differs: {abi}')
            if manifest['packages'] != entry['packages'] or manifest['user'] != config['user']:
                raise ValueError(f'Embedded package/user manifest differs: {abi}')
            if (manifest['schemaVersion'], manifest['abi'], manifest['alpineArch'],
                manifest['sourcePackages']) != (1, abi, ARCHITECTURES[abi][0], config['sourcePackages']):
                raise ValueError(f'Embedded image identity differs: {abi}')
            accounts = [line.split(':') for line in archive.extractfile('etc/passwd').read().decode().splitlines()]
            user = config['user']
            account = next((row for row in accounts if row[0] == user['name']), [])
            if len(account) != 7 or account[2:4] != [str(user['uid']), str(user['gid'])] or account[5:] != [user['home'], user['shell']]:
                raise ValueError(f'Installed default account differs: {abi}')
            installed = parse_database(archive.extractfile('lib/apk/db/installed').read())
            if installed != entry['packages']:
                raise ValueError(f'Installed package database differs: {abi}')
            if not set(config['packages'] + config['sourcePackages']) <= {p['name'] for p in installed}:
                raise ValueError(f'Missing requested package: {abi}')
            repo = 'opt/web-terminal/apks/'
            for name in (ARCHITECTURES[abi][0], 'noarch'):
                alias = archive.getmember(repo + name)
                if not alias.issym() or alias.linkname != '.':
                    raise ValueError(f'Offline repository architecture alias missing: {abi}/{name}')
            for item in entry['inputs']:
                if item['file'].startswith('runtime/'):
                    bundled = archive.extractfile(repo + Path(item['file']).name).read()
                    if sha256(bundled) != item['sha256']:
                        raise ValueError(f'Bundled offline APK mismatch: {abi}/{item["file"]}')
        print(f'PASS verified rootfs {abi}', flush=True)
    return lock


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['refresh', 'build', 'verify'])
    parser.add_argument('--arch', action='append', choices=ARCHITECTURES,
                        help='Repeat to select ABIs; default is all four')
    parser.add_argument('--jobs', type=int, default=2, help='Parallel architecture builds (default: 2)')
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error('--jobs must be positive')
    abis = args.arch or list(ARCHITECTURES)
    if args.command == 'verify':
        verify_assets(abis)
        return
    config = load_config()
    refreshing = args.command == 'refresh'
    if refreshing:
        previous = read_json(LOCK) if LOCK.exists() else {}
        lock = {'schemaVersion': 1, 'configSha256': sha256(CONFIG.read_bytes()),
                'recipeSha256': recipe_sha256(), 'sources': read_json(RECIPE / 'sources.json'),
                'architectures': previous.get('architectures', {})}
    else:
        lock = verify_lock(abis)
    CACHE.mkdir(parents=True, exist_ok=True)
    def build_one(abi):
        return abi, build_architecture(
            abi, config, old=lock['architectures'].get(abi), refresh=refreshing)
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as executor:
        futures = [executor.submit(build_one, abi) for abi in abis]
        for future in concurrent.futures.as_completed(futures):
            abi, result = future.result()
            lock['architectures'][abi] = result
            if refreshing:
                # Separate explicit --arch refreshes may run concurrently.
                with (CACHE / 'lock-update').open('a') as guard:
                    fcntl.flock(guard, fcntl.LOCK_EX)
                    latest = read_json(LOCK) if LOCK.exists() else {}
                    if all(latest.get(key) == lock[key]
                           for key in ('configSha256', 'recipeSha256', 'sources')):
                        latest['architectures'][abi] = result
                    else:
                        latest = dict(lock)
                        latest['architectures'] = {abi: result}
                    temporary = CACHE / 'rootfs.lock.json.tmp'
                    write_json(temporary, latest)
                    os.replace(temporary, LOCK)
    verify_assets(abis)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, KeyError, subprocess.CalledProcessError) as error:
        raise SystemExit(f'Rootfs build failed: {error}') from error
