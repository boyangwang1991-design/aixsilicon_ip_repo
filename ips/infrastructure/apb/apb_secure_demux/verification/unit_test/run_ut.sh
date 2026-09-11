#!/usr/bin/env bash
set -euo pipefail
ip_dir=$(cd "$(dirname "$0")/../.." && pwd)
if [ "$#" -gt 0 ]; then
    uv run python "$ip_dir/scripts/run_module_ut.py" --test "$1"
else
    uv run python "$ip_dir/scripts/run_module_ut.py"
fi
