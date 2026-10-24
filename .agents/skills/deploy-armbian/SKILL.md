---
name: deploy-armbian
description: Build, install, update, and verify GSMLG as an unattended Sway kiosk on ARM64 Armbian over SSH. Use when deploying the full Flutter interface to a connected display with automatic startup and no interactive login.
---

# Deploy GSMLG on Armbian

Use the repository's deployment assets to run GSMLG as an ordinary user through
`greetd -> Sway -> systemd user app service`. Keep SSH available for maintenance.
Match the requested scope: documenting or inspecting a deployment does not authorize
installing packages, changing boot configuration, restarting a session, or rebooting.
Reuse authorization already given for deployment; do not ask for it again.

Run repository commands from the root, three directories above this skill.
Read these maintained sources before adapting the deployment:

- [Kiosk templates](../../../linux/kiosk/): session scripts, Sway, greetd, and services.
- [Linux plugin rules](../../../linux/cmake/plugins.cmake): the local inference build switch.
- [ROCK 5 deployment record](../../../docs/ROCK5_KIOSK.md): detailed commands and dated
  acceptance evidence for the original machine. This record is in Chinese.

## Discover the target

Resolve the SSH alias and inspect the machine before selecting commands. Establish
the distro, architecture, running kernel, installed modules/DTBs/firmware, available
space, Flutter version, display outputs, GPU drivers, and existing display manager.
Discover the kiosk user's name, group, UID, and home directory. Check sudo access,
existing releases, greetd configuration, and existing keyring state without reading
stored application credentials.

Use task-specific variables such as `TARGET_HOST`, `KIOSK_USER`, `KIOSK_UID`,
`KIOSK_HOME`, `SRC_DIR`, and `FLUTTER_HOME`. In command examples below, run on the
target as the kiosk user unless `sudo` is shown. User service and D-Bus commands need
that user's environment:

```sh
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
```

The verified example used `rock-5-itx`, user/group `gao`, UID 1000, tty7, and
`HDMI-A-1`. Templates contain these values: adapt every occurrence to the discovered
target. DRM card/render node numbers are not stable identifiers; inspect their
drivers through sysfs. If SSH is refused, report the connectivity blocker instead
of repeatedly retrying or changing unrelated network configuration.

## Prepare and build natively

Use a pinned Flutter release compatible with the checkout and lockfile. Build on
Linux ARM64; never transfer a macOS Flutter/Dart cache as the target toolchain.
The original deployment used Flutter 3.47.7 / Dart 3.13.5 under
`/home/gao/opt/flutter-3.47.7`, with source under `/home/gao/gsmlg-kiosk/src`.
These are a verified example, not universal version requirements.

For the verified Ubuntu 24.04 base, the package set was:

```sh
sudo apt-get install --no-install-recommends \
  sway greetd clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev \
  libsecret-1-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
  libegl-mesa0 libgles2 gnome-keyring at-spi2-core fonts-noto-cjk fonts-noto-color-emoji \
  pipewire pipewire-pulse wireplumber pulseaudio-utils ffmpeg grim mesa-utils \
  unzip xz-utils
```

Adapt packages to the actual Armbian base. Avoid starting greetd during incomplete
provisioning. If a temporary runtime mask is needed, record it and remove only the
mask introduced by this task before enabling the finished session.

Transfer tracked working files plus explicitly selected deployment changes,
including required untracked files and real Git LFS content. Do not rely on a Git
archive to include uncommitted changes or materialize LFS objects. Exclude
credentials, `.env`, `.dart_tool`, build output, and host caches. Preserve the
lockfile and verify the transferred source/configuration hashes. If a target SDK
clone is too slow, transfer a clean shallow checkout of the same Flutter tag,
retain the official origin URL, and fetch Linux artifacts on the target.

From `SRC_DIR`, enable Linux desktop support and fetch artifacts:

```sh
export PATH="$FLUTTER_HOME/bin:$PATH"
cd "$SRC_DIR"
flutter config --no-analytics --enable-linux-desktop
flutter precache --linux
flutter pub get --enforce-lockfile
```

Choose the build flag from the user's requested functionality:

- The default is `GSMLG_ENABLE_LOCAL_LLM=true`; preserve it when local inference
  is required and supported, using `flutter build linux --release --no-pub`.
- When local inference is optional and disabling it is already accepted, build with:

  ```sh
  flutter build linux --release --no-pub --dart-define=GSMLG_ENABLE_LOCAL_LLM=false
  ```

  This empties the local model catalog, removes automatic download candidates,
  rejects native model loading, and excludes only `lib_llama_cpp_linux` from the
  Linux plugin build. Remote model features remain available.

The original blocker was `lib_llama_cpp_linux` 0.7.3 missing ARM64 binaries and a
complete source fallback: [upstream issue #33](https://github.com/gsmlg-app/lib_llama_cpp/issues/33).
Recheck the resolved package and upstream status. Follow `upstream-issue-routing`
for covered dependency issues. Do not silently disable required inference, edit
the pub cache, or patch generated plugin files. Remove the existing temporary
exclusion only after an upstream release, an in-scope dependency update, and native
ARM64 build/inference validation.

Keep the source stable during compilation. If a first build reports that inputs
changed, inspect why and rebuild after they settle. Diagnose repeated failures.
Check that the release executable and bundled libraries are AArch64 and that
`ldd` reports no missing dependencies on the target. A successful build alone does
not establish display or hardware support.

## Install the bundle and session

Install the entire `build/linux/arm64/release/bundle/` into a new, root-owned
`/opt/gsmlg/releases/<build-id>/`. Keep the executable, `lib/`, and `data/` together.
Record the source revision, uncommitted deployment changes, Flutter version,
lockfile hash, and build flag. Retain the previous release, then switch
`/opt/gsmlg/current` atomically to the new bundle.

Stage target-specific copies of the existing templates; back up installed
configuration before replacing it. Use these destinations and permissions:

| Repository source under `linux/kiosk/` | Installed path | Mode |
| --- | --- | --- |
| `gsmlg-kiosk-session`, `gsmlg-kiosk-start-app` | `/usr/local/bin/` | 755 |
| `sway.conf` | `/etc/gsmlg-kiosk/sway.conf` | 644 |
| `gsmlg-kiosk-app.service` | `/etc/systemd/user/gsmlg-kiosk-app.service` | 644 |
| `gsmlg-kiosk-keyring.service` | `/etc/systemd/system/gsmlg-kiosk-keyring.service` | 644 |
| `greetd-keyring.conf` | `/etc/systemd/system/greetd.service.d/greetd-keyring.conf` | 644 |
| `greetd.toml` | `/etc/greetd/config.toml` | 644 |

Preserve the startup ordering in the templates:

1. Start the shared user manager/D-Bus and unlock Secret Service before greetd.
2. Let greetd open the ordinary user's session without an interactive login.
3. Start Sway with `GDK_BACKEND=wayland` and the shared user bus.
4. Only after Sway is ready, import `WAYLAND_DISPLAY`, `SWAYSOCK`, and desktop/session
   variables into D-Bus/systemd, then start the app user service.
5. Restart the app after exits (`Restart=always`, three seconds); stop it when Sway
   exits. Do not independently enable the app before its display environment exists.

Keep fullscreen matching restricted to the main window:

```sway
for_window [app_id="org.gsmlg.app" title="^GSMLG$"] fullscreen enable
```

Matching every window with that app ID also fullscreened GTK file choosers and hid
their buttons. Preserve dialog layout when adapting the rule.

## Configure unattended secure storage

Linux `flutter_secure_storage` can write a control item even while reading an empty
vault. A locked or missing default keyring can therefore block startup with a prompt.
Inspect existing keyrings first. Never replace an existing keyring or its unlock
credential as part of an update; resolve ownership/recovery before provisioning.

Only for first installation with no existing keyring or credential, create
`/etc/gsmlg-kiosk/` and generate a machine password directly into a systemd encrypted
credential. This example refuses to replace an existing credential:

```sh
sudo bash -c '
  set -euo pipefail
  umask 077
  test ! -e /etc/gsmlg-kiosk/keyring-password.cred
  openssl rand -hex 32 | systemd-creds encrypt \
    --name=keyring-password --with-key=host - \
    /etc/gsmlg-kiosk/keyring-password.cred
  chmod 600 /etc/gsmlg-kiosk/keyring-password.cred
'
```

Keep the credential root-owned. Never print the password or put it in arguments,
source, logs, or persistent plaintext files. The service passes `%d/keyring-password`
through stdin to `gnome-keyring-daemon --unlock --components=secrets`.
`--unlock` creates the daemon; do not combine it with `--start` or start a competing
Secret Service first and then try to attach using `--unlock`. Start the keyring
service, wait for the bus name, and verify the collection reports `Locked=false`
before allowing greetd to proceed.

Decryption depends on `/var/lib/systemd/credential.secret`. Plan recovery of the
keyring, encrypted credential, and host key together when backing up or migrating.
This arrangement does not provide full offline disk protection on an unencrypted
host.

## Enable graphics and boot startup

Check the running kernel against installed modules, DTBs, and firmware before
changing boot settings. On the verified RK3588 board, the supplied
`/boot/dtb/rockchip/overlay/rockchip-rk3588-panthor-gpu.dtbo`, Panthor module, and
`arm/mali/arch10.8/mali_csffw.bin` firmware enabled Mesa acceleration. Back up
`/boot/armbianEnv.txt` and add `panthor-gpu` to its existing `overlays=` value,
preserving other overlays, only when this board/kernel combination supports it.
Do not apply RK3588 overlay assumptions to other Armbian boards.

The original machine was running 6.1.75 while 6.1.115 boot artifacts/modules were
installed; it needed a reboot before Panthor could work. The verified result was
kernel `6.1.115-vendor-rk35xx`, Mesa 25.2.8, and `Mali-G610 (Panfrost)` with GLES 3.1.
Discover actual drivers and versions again for each deployment.

Validate shell syntax, systemd units, and the Sway configuration before enabling
startup. Headless Sway validation with `WLR_RENDERER=pixman` checks configuration
only; it does not prove GPU/display operation or justify a software-rendering default.
Reload both system and kiosk-user service managers. Ensure the keyring service
succeeds, `graphical.target` is the default, and enabled greetd is pulled into boot.
Reconcile any existing display manager before enabling greetd. Remove temporary
masks introduced by this task. Reboot when included in the authorized deployment
and when it will not interrupt active use unexpectedly.

## Verify the actual session

Collect current evidence rather than copying the historical acceptance result:

| Check | Required evidence |
| --- | --- |
| Build and installation | AArch64 release, no missing libraries, unchanged lockfile, installed bundle/config hashes match the selected source or staged adaptations. |
| Unattended boot | Boot ID changed; greetd, keyring, and app started without a manual app launch or login. |
| Hardware rendering | Wayland `eglinfo -B -p wayland -a gles` identifies the expected Mesa GPU; the app opens a render node whose driver is Panthor on the RK3588 target. |
| Display and interaction | `swaymsg -t get_outputs` shows the intended mode; `get_tree` identifies the main window with `fullscreen_mode=1`; inspect a `grim` screenshot and exercise navigation/input and a dialog. |
| Secret Service | `Locked=false` after reboot; a synthetic item survives daemon restart and automatic unlock. Remove the test item without reading real tokens. |
| Recovery | Inspect the running restart policy. Test app exit/relaunch only when interrupting the session is appropriate and authorized; otherwise mark crash recovery unverified. |

Discover `SWAYSOCK` under the kiosk user's runtime directory and set the actual
`WAYLAND_DISPLAY` for diagnostics. Inspect `greetd`, `gsmlg-kiosk-keyring`, and user
`gsmlg-kiosk-app` service status. Review only necessary log excerpts; application
logs may contain user-entered information after the machine enters use.

The 2026-10-25 record verified an actual reboot, automatic startup, GPU use, HDMI
1920x1080 at 60 Hz, fullscreen display, navigation, and keyring persistence.
It did not verify forced crash recovery or comprehensively test cloud APIs, camera,
Bluetooth, or recording. State those boundaries separately from configuration checks.

## Update and recover

For an update, install another complete release, verify it, switch `current`, and
run `systemctl --user restart gsmlg-kiosk-app`. `Super+Shift+R` also restarts the
app; `sudo systemctl restart greetd` restarts the entire display session. Coordinate
these actions with active use. Roll back by restoring the previous release link
and restarting the app; retain configuration backups for session changes.

For console maintenance over SSH, `sudo systemctl disable --now greetd` followed
by `sudo chvt 1` stops unattended display startup. Restore the saved boot
configuration and reboot when rolling back a GPU overlay change. Finish by
reporting the release path, source/build identity, enabled services, current
verification evidence, and any remaining blockers or unverified behavior.
