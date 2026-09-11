#!/usr/bin/env bash
set -euo pipefail
IP_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
WORKFLOW_ROOT=${AIX_WORKFLOW_ROOT:-$(cd "$IP_ROOT/../../../../../.." && pwd)}
export UV_PROJECT="$WORKFLOW_ROOT"
export UV_CACHE_DIR=${UV_CACHE_DIR:-/tmp/watchdog-uv-cache}
cd "$IP_ROOT"
uv run --offline --locked --no-sync python scripts/run_validation.py "$@"
