"""Build the unsigned local APK v2 for the separately pinned lrzsz source."""

import gzip
import hashlib
import io
from pathlib import Path
import sys
import tarfile


def archive(root):
    output = io.BytesIO()
    with tarfile.open(fileobj=output, mode='w', format=tarfile.PAX_FORMAT) as tar:
        for path in sorted(root.rglob('*')):
            info = tar.gettarinfo(str(path), path.relative_to(root).as_posix())
            info.uid = info.gid = info.mtime = 0
            info.uname = info.gname = 'root'
            if info.isfile():
                info.pax_headers['APK-TOOLS.checksum.SHA1'] = hashlib.sha1(path.read_bytes()).hexdigest()
            elif info.issym():
                info.pax_headers['APK-TOOLS.checksum.SHA1'] = hashlib.sha1(info.linkname.encode()).hexdigest()
            with path.open('rb') if info.isfile() else io.BytesIO() as content:
                tar.addfile(info, content if info.isfile() else None)
    return gzip.compress(output.getvalue(), mtime=0)


def package(root, output, architecture):
    data = archive(root)
    size = sum(path.stat().st_size for path in root.rglob('*') if path.is_file())
    metadata = (
        'pkgname = lrzsz\npkgver = 0.13.1-r0\n'
        'pkgdesc = XMODEM YMODEM ZMODEM transfer tools\n'
        'url = https://ohse.de/uwe/software/lrzsz.html\n'
        'builddate = 0\npackager = Web Terminal\n'
        f'size = {size}\narch = {architecture}\n'
        'origin = lrzsz\nlicense = GPL-2.0-or-later\ndepend = musl\n'
        f'datahash = {hashlib.sha256(data).hexdigest()}\n'
    ).encode()
    control = io.BytesIO()
    with tarfile.open(fileobj=control, mode='w', format=tarfile.USTAR_FORMAT) as tar:
        info = tarfile.TarInfo('.PKGINFO')
        info.size = len(metadata)
        info.mode = 0o644
        tar.addfile(info, io.BytesIO(metadata))
    # APK v2 control tar omits EOF records, as abuild-tar --cut does.
    control_size = 512 + ((len(metadata) + 511) // 512) * 512
    output.write_bytes(gzip.compress(control.getvalue()[:control_size], mtime=0) + data)


if __name__ == '__main__':
    package(Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3])
