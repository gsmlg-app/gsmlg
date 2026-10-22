#!/bin/sh
# Optional per-user Open With registration; does not choose default applications.
set -eu

usage() {
    printf '%s\n' 'Usage: install-editor.sh [--executable /path/to/gsmlg] [--uninstall]'
}

script_directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
executable=$script_directory/gsmlg
uninstall=false
while [ "$#" -gt 0 ]; do
    case "$1" in
        --executable)
            [ "$#" -ge 2 ] || { usage >&2; exit 2; }
            executable=$2
            shift 2
            ;;
        --uninstall) uninstall=true; shift ;;
        --help|-h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

data_home=${XDG_DATA_HOME:-"${HOME:?HOME or XDG_DATA_HOME is required}/.local/share"}
case "$data_home" in /*) ;; *) printf '%s\n' 'XDG_DATA_HOME must be an absolute path.' >&2; exit 2 ;; esac
applications=$data_home/applications
desktop_file=$applications/org.gsmlg.app.editor.desktop

if [ -e "$desktop_file" ] && ! grep -qx 'X-GSMLG-Editor-Registration=true' "$desktop_file"; then
    printf '%s\n' "Refusing to change an unowned desktop entry: $desktop_file" >&2
    exit 1
fi

if [ "$uninstall" = true ]; then
    rm -f -- "$desktop_file"
else
    [ -f "$executable" ] && [ -x "$executable" ] || {
        printf '%s\n' "Executable is missing or not executable: $executable" >&2
        exit 1
    }
    # Canonicalize the parent, preserving the actual executable name and quotes.
    executable_directory=$(CDPATH= cd -- "$(dirname -- "$executable")" && pwd -P)
    executable=$executable_directory/$(basename -- "$executable")
    if [ "$(printf '%s' "$executable" | tr -d '\011\012\015')" != "$executable" ]; then
        printf '%s\n' 'Executable paths containing tabs or line breaks are unsupported.' >&2
        exit 1
    fi
    # Exec quoting is decoded after Desktop Entry string escaping. Escape both
    # layers, and double literal percent signs to avoid field-code expansion.
    escaped=$(printf '%s' "$executable" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\$/\\$/g; s/`/\\`/g; s/%/%%/g; s/\\/\\\\/g')
    mkdir -p -- "$applications"
    temporary=$(mktemp "$applications/.gsmlg-editor.XXXXXX")
    trap 'rm -f -- "$temporary"' 0
    trap 'exit 1' HUP INT TERM
    while IFS= read -r line; do
        case "$line" in
            Exec=*) printf 'Exec="%s" %%F\n' "$escaped" ;;
            *) printf '%s\n' "$line" ;;
        esac
    done < "$script_directory/org.gsmlg.app.editor.desktop" > "$temporary"
    chmod 644 "$temporary"
    mv -f -- "$temporary" "$desktop_file"
    trap - 0 HUP INT TERM
fi

if command -v update-desktop-database >/dev/null 2>&1 && [ -d "$applications" ]; then
    update-desktop-database "$applications"
fi
if [ "$uninstall" = true ]; then
    printf '%s\n' 'Removed GSMLG Editor Open With registration for the current user.'
else
    printf '%s\n' "Installed Open With entry: $desktop_file"
fi
