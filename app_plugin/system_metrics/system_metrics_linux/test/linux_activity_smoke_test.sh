#!/usr/bin/env bash
set -euo pipefail

plugin_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
probe_directory="$(mktemp -d "${TMPDIR:-/tmp}/gsmlg-linux-activity.XXXXXX")"
trap 'python3 -c "import shutil, sys; shutil.rmtree(sys.argv[1])" "$probe_directory"' EXIT

"${CXX:-c++}" -std=c++17 -Wall -Wextra -Werror -pthread \
    "$plugin_root/linux/activity_monitor_collector.cc" \
    "$plugin_root/test/activity_monitor_collector_test.cc" \
    -o "$probe_directory/activity_monitor_collector_test"

if [[ $# -gt 0 ]]; then
    "$probe_directory/activity_monitor_collector_test" "$@"
else
    "$probe_directory/activity_monitor_collector_test" --fixtures
    if [[ "$(uname -s)" == "Linux" ]]; then
        "$probe_directory/activity_monitor_collector_test" --live
    fi
fi
