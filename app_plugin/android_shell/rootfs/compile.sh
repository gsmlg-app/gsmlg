#!/bin/sh
set -eu
export SOURCE_DATE_EPOCH=0 LC_ALL=C TZ=UTC
apk add --no-network /work/build/*.apk
mkdir -p /tmp/lrzsz-build /tmp/lrzsz-package
cd /tmp/lrzsz-build
tar xzf /work/sources/lrzsz.tar.gz --strip-components=1
tar xJf /work/sources/lrzsz-debian.tar.xz
while IFS= read -r patch_name; do
    case "$patch_name" in ''|'#'*) continue ;; esac
    patch -p1 < "debian/patches/$patch_name"
done < debian/patches/series
./configure --prefix=/usr --disable-nls --disable-rpath --disable-Werror \
    --program-transform-name=s/l// \
    CFLAGS='-Os -ffile-prefix-map=/tmp/lrzsz-build=.'
make -j2
make quickcheck
make DESTDIR=/tmp/lrzsz-package install
mkdir -p /tmp/lrzsz-package/usr/share/licenses/lrzsz
cp COPYING debian/copyright /tmp/lrzsz-package/usr/share/licenses/lrzsz/
python3 /recipe/package_apk.py /tmp/lrzsz-package /work/runtime/lrzsz-0.13.1-r0.apk "$(apk --print-arch)"
