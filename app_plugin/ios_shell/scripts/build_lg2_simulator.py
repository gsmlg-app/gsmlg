#!/usr/bin/env python3
import argparse
import hashlib
import os
import plistlib
import shlex
import shutil
import subprocess
import sys
import tarfile
import tempfile
import zipfile
from pathlib import Path


SOURCE_COMMIT = '93f92993b1eb7cd1138469934181626697254a11'
SOURCE_SHA256 = '69a6bac810adc0b443c24da551eddb34cf015b71915a89235f6ff715e6a6b67e'
HEADER_SHA256 = '51d46b912eb30399cbb5c36c8c8f15eb1a44adcfc9ee581304ac9d3739a84716'
CMAKE_VERSION = '3.31.10'
CMAKE_URL = (
    'https://files.pythonhosted.org/packages/99/3b/'
    '6ed408a99709808df4014bead522e075f0e8d1100e6d886eb5bc30fee04e/'
    'cmake-3.31.10-py3-none-macosx_10_10_universal2.whl'
)
CMAKE_SHA256 = 'ad697643a00d9ba85179590a383c4f7401169b55ebf4b8b2938daf28c6bdeb6d'


def run(command, **kwargs):
    print(shlex.join([str(argument) for argument in command]), flush=True)
    return subprocess.run([str(argument) for argument in command], check=True, **kwargs)


def download(url, checksum, destination):
    cached = os.environ.get('IOS_SHELL_ARCHIVE_CACHE')
    cached_file = Path(cached) / url.rsplit('/', 1)[-1] if cached else None
    if cached_file is not None and cached_file.is_file():
        shutil.copyfile(cached_file, destination)
    else:
        run(['curl', '--fail', '--location', '--retry', '2', url, '--output', destination])
    actual = hashlib.sha256(destination.read_bytes()).hexdigest()
    if actual != checksum:
        raise ValueError(f'SHA256 mismatch for {url}: expected {checksum}, got {actual}')


def cmake_binary(work):
    override = os.environ.get('CMAKE_BIN')
    candidate = shutil.which(override or 'cmake')
    if override and candidate is None:
        raise ValueError(f'CMAKE_BIN executable not found: {override}')
    if candidate:
        version = subprocess.check_output([candidate, '--version'], text=True).splitlines()[0]
        if version == f'cmake version {CMAKE_VERSION}':
            return Path(candidate).resolve()
        if override:
            raise ValueError(f'CMAKE_BIN must provide CMake {CMAKE_VERSION}; found {version}')
    archive = work / 'cmake.whl'
    download(CMAKE_URL, CMAKE_SHA256, archive)
    tools = work / 'cmake-tool'
    with zipfile.ZipFile(archive) as wheel:
        wheel.extractall(tools)
    binary = tools / 'cmake/data/bin/cmake'
    binary.chmod(0o755)
    return binary


def simulator_slice(framework):
    metadata = plistlib.loads((framework / 'Info.plist').read_bytes())
    for library in metadata['AvailableLibraries']:
        if library['SupportedPlatform'] == 'ios' and library.get('SupportedPlatformVariant') == 'simulator':
            return framework / library['LibraryIdentifier']
    raise ValueError(f'No simulator slice in {framework}')


def configure_command(cmake, source, build, frameworks, include, sdk, compiler):
    ssh = simulator_slice(frameworks / 'libssh2.xcframework')
    ssl = simulator_slice(frameworks / 'openssl.xcframework')
    ios = simulator_slice(frameworks / 'ios_system.xcframework')
    flags = [
        '-target', 'arm64-apple-ios14.0-simulator',
        '-I', str(ssh / 'libssh2.framework/Headers'),
        '-I', str(ios / 'ios_system.framework/Headers'), '-I', str(include),
        '-F', str(ssh), '-F', str(ssl), '-F', str(ios),
    ]
    linker_flags = ['-F', str(ssh), '-F', str(ssl), '-F', str(ios), '-framework', 'ios_system']
    return [
        cmake, '-S', source, '-B', build,
        '-DREGEX_BACKEND=builtin', '-DBUILD_CLAR=OFF', '-DBUILD_EXAMPLES=ON',
        '-DBUILD_SHARED_LIBS=OFF', '-DTHREADSAFE=OFF', '-DCMAKE_BUILD_TYPE=Release',
        '-DCMAKE_SYSTEM_NAME=iOS', '-DCMAKE_OSX_ARCHITECTURES=arm64',
        '-DCMAKE_OSX_DEPLOYMENT_TARGET=14.0', f'-DCMAKE_OSX_SYSROOT={sdk}',
        f'-DCMAKE_C_COMPILER={compiler}', f'-DCMAKE_C_FLAGS={shlex.join(flags)}',
        f'-DCMAKE_EXE_LINKER_FLAGS={shlex.join(linker_flags)}',
        '-DCMAKE_TRY_COMPILE_TARGET_TYPE=EXECUTABLE', '-DUSE_HTTPS=OpenSSL',
        f'-DOPENSSL_INCLUDE_DIR={ssl / "openssl.framework/Headers"}',
        f'-DOPENSSL_SSL_LIBRARY={ssl / "openssl.framework/openssl"}',
        f'-DOPENSSL_CRYPTO_LIBRARY={ssl / "openssl.framework/openssl"}',
        '-DPKG_CONFIG_EXECUTABLE=/usr/bin/false',
        '-DCMAKE_IGNORE_PREFIX_PATH=/opt/homebrew;/usr/local',
        '-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF',
        '-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF', '-DUSE_SSH=ON',
    ]


def dylib_command(link_file, output):
    command = shlex.split(link_file.read_text())
    command[command.index('-o') + 1] = str(output)
    command = [argument for argument in command if not argument.startswith('-Wl,-rpath,')]
    return command + [
        '-dynamiclib', '-Wl,-install_name,@rpath/lg2.framework/lg2',
        '-Wl,-current_version,1.0', '-Wl,-compatibility_version,1.0',
    ]


def merge_simulator(framework, binary):
    metadata_file = framework / 'Info.plist'
    metadata = plistlib.loads(metadata_file.read_bytes())
    original = next(
        library for library in metadata['AvailableLibraries']
        if library['SupportedPlatform'] == 'ios'
        and library.get('SupportedPlatformVariant') == 'simulator'
    )
    original_slice = framework / original['LibraryIdentifier']
    target_identifier = 'ios-arm64_x86_64-simulator'
    target_slice = framework / target_identifier
    if original_slice != target_slice:
        shutil.copytree(original_slice, target_slice, symlinks=True)
    library = target_slice / original['LibraryPath']
    run(['xcrun', 'lipo', '-create', original_slice / original['LibraryPath'] / 'lg2', binary,
         '-output', library / 'lg2'])
    run(['codesign', '--force', '--sign', '-', '--timestamp=none', library])
    original['LibraryIdentifier'] = target_identifier
    original['SupportedArchitectures'] = ['arm64', 'x86_64']
    metadata_file.write_bytes(plistlib.dumps(metadata))
    if original_slice != target_slice:
        shutil.rmtree(original_slice)
    architectures = subprocess.check_output(['xcrun', 'lipo', '-archs', library / 'lg2'], text=True).split()
    if set(architectures) != {'arm64', 'x86_64'}:
        raise ValueError(f'Unexpected lg2 simulator architectures: {architectures}')


def build_simulator(frameworks, work):
    archive = work / 'libgit2.tar.gz'
    download(f'https://codeload.github.com/holzschu/libgit2/tar.gz/{SOURCE_COMMIT}', SOURCE_SHA256, archive)
    with tarfile.open(archive) as source_archive:
        source_archive.extractall(work)
    source = work / f'libgit2-{SOURCE_COMMIT}'
    include = work / 'include'
    include.mkdir()
    download('https://github.com/holzschu/ios_system/releases/download/v3.0.4/ios_error.h',
             HEADER_SHA256, include / 'ios_error.h')
    cmake = cmake_binary(work)
    sdk = subprocess.check_output(['xcrun', '--sdk', 'iphonesimulator', '--show-sdk-path'], text=True).strip()
    compiler = subprocess.check_output(['xcrun', '--find', 'clang'], text=True).strip()
    build = work / 'build'
    environment = os.environ.copy()
    environment.pop('PKG_CONFIG_PATH', None)
    environment['PKG_CONFIG_LIBDIR'] = str(work / 'empty-pkgconfig')
    run(configure_command(cmake, source, build, frameworks, include, sdk, compiler), env=environment)
    run([cmake, '--build', build, '--parallel', str(min(os.cpu_count() or 1, 6))], env=environment)
    binary = work / 'lg2-arm64-simulator'
    run(dylib_command(build / 'examples/CMakeFiles/lg2.dir/link.txt', binary),
        cwd=build / 'examples', env=environment)
    merge_simulator(frameworks / 'lg2.xcframework', binary)


def main():
    parser = argparse.ArgumentParser(description='Add the missing lg2 arm64 iOS simulator slice from pinned source.')
    parser.add_argument('--frameworks-dir', required=True, type=Path)
    arguments = parser.parse_args()
    if sys.platform != 'darwin':
        parser.error('An Xcode-equipped macOS host is required')
    with tempfile.TemporaryDirectory(prefix='ios-shell-lg2-') as work:
        build_simulator(arguments.frameworks_dir.resolve(), Path(work))


if __name__ == '__main__':
    main()
