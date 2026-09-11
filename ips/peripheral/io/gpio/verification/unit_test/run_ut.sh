#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
: "${UV_PROJECT:?set UV_PROJECT to the workflow root}"
exec uv run --locked --no-sync python scripts/run_module_ut.py
