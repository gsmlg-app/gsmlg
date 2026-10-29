#!/bin/sh
set -eu
export SOURCE_DATE_EPOCH=0 LC_ALL=C TZ=UTC
packages=$(cat /work/packages.txt)
repo_arch=$(apk --print-arch)
# apk local repositories look up the target arch and noarch below the URL.
ln -s . "/work/runtime/$repo_arch"
ln -s . /work/runtime/noarch
# This repository has been verified against the lock by the host before launch.
# Only the locally built lrzsz APK lacks an Alpine signature.
apk --no-network --allow-untrusted --repositories-file /dev/null --repository /work/runtime add $packages
mkdir -p /opt/web-terminal/apks /etc/web-terminal
cp /work/runtime/*.apk /work/runtime/APKINDEX.tar.gz /opt/web-terminal/apks/
ln -s . "/opt/web-terminal/apks/$repo_arch"
ln -s . /opt/web-terminal/apks/noarch
cp /work/manifest.json /etc/web-terminal/rootfs.json
# Account configuration is generated from the canonical config, never evaluated.
. /work/user.env
addgroup -g "$WT_GID" "$WT_USER"
adduser -D -u "$WT_UID" -G "$WT_USER" -h "$WT_HOME" -s "$WT_SHELL" "$WT_USER"
mkdir -p "$WT_HOME"
cat > "$WT_HOME/.zshrc" <<'ZSH'
autoload -Uz compinit
compinit -d "$HOME/.zcompdump"
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
PROMPT='%n@%m:%~%# '
alias ll='ls -la'
ZSH
printf 'cd "$HOME"\n' > "$WT_HOME/.zprofile"
chown -R "$WT_UID:$WT_GID" "$WT_HOME"
# This is a fresh image with locked accounts. adduser/package scripts otherwise
# record today's date for gao and sshd, varying identical builds across dates.
sed -i 's@^\([^:]*:[^:]*:\)[^:]*:@\10:@' /etc/shadow
sed -i "s@^root:\([^:]*:[^:]*:[^:]*:[^:]*:[^:]*:\).*@root:\1$WT_SHELL@" /etc/passwd
printf 'cd "$HOME"\n' > /root/.zprofile
printf "PROMPT='%%n@%%m:%%~%%# '\n" > /root/.zshrc
printf 'nameserver 1.1.1.1\nnameserver 8.8.8.8\n' > /etc/resolv.conf
printf '127.0.0.1 localhost\n::1 localhost\n' > /etc/hosts
# No host keys, credentials, or machine-specific caches belong in the image.
rm -f /etc/ssh/ssh_host_* /etc/machine-id
rm -rf /var/cache/apk/* /tmp/* /var/log/*
. /work/checks.sh
rm -rf /root/.cache /root/.local /root/.zcompdump* /home/*/.zcompdump*
rm -f /root/.zsh_history /home/*/.zsh_history
