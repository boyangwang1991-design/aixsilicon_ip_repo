#!/usr/bin/env bash
set -euo pipefail
IP_ROOT=$(cd "$(dirname "$0")/.." && pwd)
export UV_PROJECT=${AIX_WORKFLOW_ROOT:-$(cd "$IP_ROOT/../../../../../.." && pwd)}
export UV_CACHE_DIR=${UV_CACHE_DIR:-/tmp/watchdog-uv-cache}
cd "$IP_ROOT"
uv run --offline --locked --no-sync peakrdl regblock regs/watchdog.rdl -o rtl/generated \
  --cpuif passthrough --module-name watchdog_csr --package-name watchdog_csr_pkg \
  --default-reset arst_n --err-if-bad-addr
uv run --offline --locked --no-sync python scripts/generate_register_views.py
uv run --offline --locked --no-sync peakrdl ip-xact regs/watchdog.rdl -o verification/ral/watchdog.xml
uv run --offline --locked --no-sync peakrdl uvm regs/watchdog.rdl -o verification/ral/watchdog_ral.sv
uv run --offline --locked --no-sync python scripts/generate_package.py
