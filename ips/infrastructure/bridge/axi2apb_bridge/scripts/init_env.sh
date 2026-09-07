#!/usr/bin/env bash
# Usage: RTL_EDA_PROFILE=commercial-systemverilog bash scripts/init_env.sh

set -euo pipefail

PROFILE="${RTL_EDA_PROFILE:-commercial-systemverilog}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ "$(uname -s)" != "Linux" ]; then
    echo "ERROR: this workspace supports Linux only" >&2
    exit 1
fi
if ! command -v uv >/dev/null 2>&1; then
    echo "ERROR: uv is required; install it from https://docs.astral.sh/uv/" >&2
    exit 1
fi
if [ ! -f "$PROJECT_DIR/pyproject.toml" ]; then
    echo "ERROR: missing $PROJECT_DIR/pyproject.toml" >&2
    exit 1
fi

cd "$PROJECT_DIR"
if [ -f uv.lock ]; then
    uv sync --frozen --all-groups
else
    uv lock
    uv sync --frozen --all-groups
fi

echo "Python: $(uv run python --version 2>&1)"
echo "Virtual environment: $PROJECT_DIR/.venv"
echo "EDA profile: $PROFILE"

if ! RTL_EDA_PROFILE="$PROFILE" bash "$PROJECT_DIR/scripts/check_tools.sh"; then
    echo "WARNING: selected EDA profile is incomplete; release checks remain blocked." >&2
fi
