# ROCK 5 ITX 全屏启动

目标：系统启动后以普通用户 `gao` 自动进入 Sway，直接显示 GSMLG；不显示登录器。
SSH 继续用于维护。以下配置针对 `rock-5-itx`、UID 1000 和 HDMI-A-1。

## 环境与构建

- Armbian 26.8.3 / Ubuntu 24.04，RK3588 ARM64，约 24 GiB 内存。
- Flutter 3.47.7 / Dart 3.13.5，在目标机原生构建。
- Panthor 内核驱动与 Mesa，目标内核 `6.1.115-vendor-rk35xx`。
- HDMI 使用 1920×1080 @ 60 Hz，GTK 使用 Wayland。

目标机需要 Sway、greetd、GTK3、libsecret、GStreamer、PipeWire、中文字体及编译工具：

```sh
sudo apt-get install --no-install-recommends \
  sway greetd clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev \
  libsecret-1-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  libegl-mesa0 libgles2 gnome-keyring at-spi2-core fonts-noto-cjk fonts-noto-color-emoji \
  pipewire pipewire-pulse wireplumber pulseaudio-utils ffmpeg grim mesa-utils \
  unzip xz-utils
```

安装固定版本 Flutter，仅同步受控源码、lockfile、LFS 的实际内容和本次修改。
不要同步凭据、`.env`、本机 `.dart_tool` 或构建缓存。目标机源码目录为
`/home/gao/gsmlg-kiosk/src`，SDK 为 `/home/gao/opt/flutter-3.47.7`。

```sh
export PATH=/home/gao/opt/flutter-3.47.7/bin:$PATH
cd /home/gao/gsmlg-kiosk/src
flutter config --no-analytics --enable-linux-desktop
flutter precache --linux
flutter pub get --enforce-lockfile
flutter build linux --release --no-pub --dart-define=GSMLG_ENABLE_LOCAL_LLM=false
```

该开关默认为 `true`。设为 `false` 时，本地模型列表为空、自动下载没有候选，
加载入口报告不可用；Linux 原生构建只排除 `lib_llama_cpp_linux`，保留其他插件。
远程聊天仍可通过现有设置启用。历史模型 ID 的识别保留。

临时排除的原因见 [lib_llama_cpp #33](https://github.com/gsmlg-app/lib_llama_cpp/issues/33)：
0.7.3 的发布包缺少 ARM64 库及源码回退所需文件。上游发布支持 ARM64 的包、
更新依赖并通过原生构建与本地推理验证后，移除 CMake 排除逻辑；不修改 pub 缓存。

## 安装与启动链

`greetd → gsmlg-kiosk-session → Sway → gsmlg-kiosk-app.service → GSMLG`。
Sway 就绪后才向用户 systemd 和 D-Bus 导入显示环境并启动应用。
应用退出后配置为 3 秒重启；Sway 退出时会停止应用服务，greetd 再次启动会话。
全屏规则仅匹配 GSMLG 主窗口，文件选择等 GTK 对话框保留正常布局及按钮。

将 `build/linux/arm64/release/bundle/` **整个目录**安装到
`/opt/gsmlg/releases/<构建标识>/`，所有者为 root，并令 `/opt/gsmlg/current`
指向该目录。可执行文件、`lib/` 和 `data/` 必须一起保留。

在源码根目录安装配置：

```sh
sudo install -d /etc/gsmlg-kiosk /etc/systemd/system/greetd.service.d
sudo install -m 755 linux/kiosk/gsmlg-kiosk-session linux/kiosk/gsmlg-kiosk-start-app /usr/local/bin/
sudo install -m 644 linux/kiosk/sway.conf /etc/gsmlg-kiosk/
sudo install -m 644 linux/kiosk/gsmlg-kiosk-app.service /etc/systemd/user/
sudo install -m 644 linux/kiosk/gsmlg-kiosk-keyring.service /etc/systemd/system/
sudo install -m 644 linux/kiosk/greetd-keyring.conf /etc/systemd/system/greetd.service.d/
# 覆盖前备份已有 /etc/greetd/config.toml。
sudo install -m 644 linux/kiosk/greetd.toml /etc/greetd/config.toml
```

### 无人值守密钥环

flutter_secure_storage 的 Linux 实现连读取空凭据库也会写入控制项，因而需要
已解锁的 Secret Service。首次部署时为原本没有密钥环的 `gao` 用户创建机器随机密码：

```sh
# 仅首次执行；已有密钥环或凭据时不要覆盖。
sudo bash -c 'set -euo pipefail; umask 077; openssl rand -hex 32 | systemd-creds encrypt --name=keyring-password --with-key=host - /etc/gsmlg-kiosk/keyring-password.cred'
sudo systemctl daemon-reload
sudo systemctl start gsmlg-kiosk-keyring.service
```

密钥环服务在 greetd 前运行，解锁后检查 `Locked=false` 才允许继续。
`--unlock` 创建并解锁守护进程，不能与 `--start` 合用，也不能先启动另一个
Secret Service 再用 `--unlock` 尝试接入。

API 凭据保存在用户的加密密钥环中。解锁密码由 systemd 加密保存，启动时仅在
运行时凭据目录中解密，不写入源码、命令参数或明文配置。解密依赖本机
`/var/lib/systemd/credential.secret`；本机磁盘未加密，因此这不提供整盘离线保护。
备份或迁移密钥环时必须同时安排解锁凭据及 host key 的恢复。

### 显卡与开机启用

本机提供 `/boot/dtb/rockchip/overlay/rockchip-rk3588-panthor-gpu.dtbo`、
Panthor 模块和 `arm/mali/arch10.8/mali_csffw.bin` 固件。
备份 `/boot/armbianEnv.txt`，在保留其他 overlay 的前提下加入
`overlays=panthor-gpu`。更新后的内核、DTB、模块必须匹配；原先运行的
6.1.75 内核与已安装的 6.1.115 模块不匹配，需要重启。

```sh
systemctl --user daemon-reload
sudo systemctl unmask --runtime greetd.service
sudo systemctl enable greetd.service
sudo reboot
```

系统默认目标须为 `graphical.target`。应用不使用软件渲染作为默认配置。

## 检查与维护

```sh
sudo systemctl status greetd gsmlg-kiosk-keyring --no-pager
systemctl --user status gsmlg-kiosk-app --no-pager
journalctl --user -u gsmlg-kiosk-app -b --no-pager
sudo journalctl -u greetd -u gsmlg-kiosk-keyring -b --no-pager

export SWAYSOCK=$(find /run/user/1000 -maxdepth 1 -name 'sway-ipc.*.sock' -print -quit)
swaymsg -t get_outputs
swaymsg -t get_tree
```

验收需检查：重启后服务自动运行、Panthor/Mesa 实际加速、HDMI 输出与
`org.gsmlg.app` 窗口全屏、截图可见应用、输入与页面切换、应用退出后自动恢复、
密钥环重启后自动解锁。构建或进程存在本身不能证明显示成功。

更新整个 bundle 并切换 `current` 链接后，运行
`systemctl --user restart gsmlg-kiosk-app`。键盘 `Super+Shift+R` 也可重启应用。
`sudo systemctl restart greetd` 重启整个显示会话。
要回到控制台维护，可通过 SSH 执行 `sudo systemctl disable --now greetd`
和 `sudo chvt 1`。显卡配置回退时恢复 boot 配置备份并重启。

## 本次验收记录（北京时间 2026-10-25）

- 源码基于 `abfe8a9` 加本次未提交修改；未提交、推送或修改 lockfile。
  ARM64 Release 已安装到 `/opt/gsmlg/releases/20261025-abfe8a9-no-local-llm/`。
  稳定重建成功，ELF 为 AArch64，动态库检查无缺失，bundle 不含 llama.cpp Linux 库。
- 实际重启后运行 `6.1.115-vendor-rk35xx`，greetd、密钥环与应用自动启动。
  显示会话位于 tty7，用户为 gao；密钥环 `Locked=false`。
- Mesa 报告 `Mali-G610 (Panfrost)`、OpenGL ES 3.1、Mesa 25.2.8，
  GSMLG 进程打开了 Panthor 的 `/dev/dri/renderD130`。
  HDMI-A-1 为 1920×1080 / 60000 mHz；Sway 主窗口 `fullscreen_mode=1`。
- 已检查实际显示截图，并从运行日志观察到 Home、Service、Toolbox、Settings、
  Editor、Monitor、Whois 等页面导航。文件对话框误匹配全屏的问题已通过限定主窗口
  规则修正并在当前会话加载；应用 PID 保持不变。
- Secret Service 使用合成测试值通过写入、守护进程重启、自动解锁及持久读回，
  测试项已清理。未读取用户真实 API 凭据进行测试。
- 默认配置 21 项相关测试通过；禁用本地推理后 22 项测试通过（包含远程模型协议与
  Backplane 仓库测试）。相关 3 个 Dart 文件分析、格式检查、CMake 4 种插件配置、
  shell 语法及 systemd/Sway 配置检查通过。
- 屏幕端已在使用应用，未强制终止进程测试崩溃恢复；已检查运行时重启策略为
  `Restart=always`、间隔 3 秒。外部云 API、蓝牙、相机及录音未逐项验收。

构建日志位于 `/home/gao/gsmlg-kiosk/build-verify.log`，应用日志位于
`/home/gao/.local/share/org.gsmlg.app/gsmlg/app.log`。boot 配置备份为
`/boot/armbianEnv.txt.gsmlg-20261024-161758.bak`，greetd 原配置备份为
`/etc/greetd/config.toml.gsmlg-before-kiosk`。

基础系统的 PAM 配置仍报告缺少可选 `pam_lastlog.so`，不影响本次会话启动，未修改
该系统配置。GitNexus 的 `detect_changes` 对本次返回零符号，不能作为无影响的证明；
实际改动范围已通过 Git diff 和上述针对性验证复核。
