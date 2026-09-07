#!/usr/bin/env bash
# Usage: bash scripts/setup_env.sh

set -euo pipefail

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

cd "$PROJECT_DIR"
if [ -f uv.lock ]; then
    uv sync --frozen --all-groups
else
    uv lock
    uv sync --frozen --all-groups
fi
uv run python --version
echo "Environment ready at $PROJECT_DIR/.venv"
