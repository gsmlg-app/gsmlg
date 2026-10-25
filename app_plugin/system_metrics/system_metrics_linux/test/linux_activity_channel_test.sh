#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    printf 'Usage: %s ENGINE_DIRECTORY\n' "$0" >&2
    printf 'ENGINE_DIRECTORY must contain flutter_linux/ and libflutter_linux_gtk.so.\n' >&2
    exit 2
fi
engine_directory="$(cd "$1" && pwd)"
if [[ ! -f "$engine_directory/flutter_linux/flutter_linux.h" || ! -f "$engine_directory/libflutter_linux_gtk.so" ]]; then
    printf 'Flutter Linux SDK headers/library missing from %s\n' "$engine_directory" >&2
    exit 2
fi
pkg-config --exists gtk+-3.0 epoxy fontconfig
plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
channel_directory="$(mktemp -d "${TMPDIR:-/tmp}/gsmlg-linux-channel.XXXXXX")"
trap 'python3 -c "import shutil, sys; shutil.rmtree(sys.argv[1])" "$channel_directory"' EXIT
# Link the engine's graphics/font dependencies explicitly, including on systems
# such as NixOS where indirect libraries are outside the default linker path.
read -r -a gtk_flags <<< "$(pkg-config --cflags --libs gtk+-3.0 epoxy fontconfig)"

"${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror -pthread \
    -I"$engine_directory" \
    "$plugin_root/test/linux_activity_channel_test.cc" \
    "$plugin_root/linux/activity_monitor_collector.cc" \
    -L"$engine_directory" -Wl,-rpath,"$engine_directory" -lflutter_linux_gtk \
    "${gtk_flags[@]}" \
    -o "$channel_directory/linux_activity_channel_test"

# No engine, GtkWindow, GTK initialization or display server is required.
DISPLAY= WAYLAND_DISPLAY= "$channel_directory/linux_activity_channel_test"
