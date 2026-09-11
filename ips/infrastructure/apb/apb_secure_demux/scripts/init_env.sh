#!/usr/bin/env bash
# Usage: RTL_EDA_PROFILE=commercial-systemverilog bash scripts/init_env.sh

set -euo pipefail

PROFILE="${RTL_EDA_PROFILE:-commercial-systemverilog}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

find_workflow_root() {
    local candidate="${AIX_WORKFLOW_ROOT:-}"
    local cursor
    if [ -n "$candidate" ]; then
        [ -f "$candidate/bootstrap.py" ] && [ -f "$candidate/pyproject.toml" ] && {
            cd "$candidate" && pwd
            return 0
        }
        return 1
    fi
    cursor="$PROJECT_DIR"
    while [ "$cursor" != "/" ]; do
        if [ -f "$cursor/bootstrap.py" ] && [ -f "$cursor/pyproject.toml" ] && \
           [ -d "$cursor/repos/aixsilicon_ip_repo" ]; then
            printf '%s\n' "$cursor"
            return 0
        fi
        cursor="$(dirname "$cursor")"
    done
    return 1
}

if [ "$(uname -s)" != "Linux" ]; then
    echo "ERROR: this workspace supports Linux only" >&2
    exit 1
fi
if ! command -v uv >/dev/null 2>&1; then
    echo "ERROR: uv is required; install it from https://docs.astral.sh/uv/" >&2
    exit 1
fi
WORKFLOW_ROOT="$(find_workflow_root)" || {
    echo "ERROR: cannot locate workflow root; set AIX_WORKFLOW_ROOT" >&2
    exit 1
}
[ -f "$WORKFLOW_ROOT/uv.lock" ] || {
    echo "ERROR: missing workflow lock: $WORKFLOW_ROOT/uv.lock" >&2
    exit 1
}

cd "$WORKFLOW_ROOT"
uv sync --frozen --all-groups

echo "Python: $(uv run python --version 2>&1)"
echo "Virtual environment: $WORKFLOW_ROOT/.venv"
echo "EDA profile: $PROFILE"

if ! RTL_EDA_PROFILE="$PROFILE" bash "$PROJECT_DIR/scripts/check_tools.sh"; then
    echo "WARNING: selected EDA profile is incomplete; release checks remain blocked." >&2
fi
