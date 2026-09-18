#!/usr/bin/env bash
# =============================================================================
# run_synth.sh - PQC synthesis entry (G3 reachability / PPA characterization)
#
# Usage:
#   bash scripts/run_synth.sh [run-tag]
#
# The FuseSoC design_compiler backend cannot pass environment variables to the
# DC script by itself, so this wrapper resolves the PDK technology profile and
# the characterization SDC to absolute paths, then drives the canonical target
# `synth` of aixsilicon_ip_pqc.core. Outputs stay under build/rtl/.
# =============================================================================
set -euo pipefail
export LC_ALL=C

IP_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$IP_ROOT"

: "${UV_PROJECT:?set UV_PROJECT to the workflow root so uv uses the single managed environment}"

export IP_ROOT
export PQC_PDK_SETUP="$IP_ROOT/build/rtl/pdk_setup.tcl"
export PQC_SYNTH_SDC="$IP_ROOT/constraints/pqc_characterization.sdc"

[ -f "$PQC_PDK_SETUP" ] || { echo "missing $PQC_PDK_SETUP (run ip_pdk_scan.py + render_dc_setup.py first)"; exit 1; }
[ -f "$PQC_SYNTH_SDC" ] || { echo "missing $PQC_SYNTH_SDC"; exit 1; }

tag="${1:-pqc}"
[[ "$tag" =~ ^[a-zA-Z0-9_]+$ ]] || { echo "run-tag must be alphanumeric"; exit 2; }

mkdir -p build/rtl
touch build/FUSESOC_IGNORE
run_dir=$(mktemp -d "build/rtl/synth_${tag}.XXXXXXXX")
printf 'PQC synthesis run: %s\n' "$run_dir"

uv run --locked --no-sync fusesoc --cores-root=. run \
  --setup --build --target=synth --build-root="$run_dir" \
  aixsilicon:ip:pqc:0.1.0 > "$run_dir/console.log" 2>&1 || {
    tail -40 "$run_dir/console.log"; exit 1; }

# Edalize suppresses successful tool stdout in console.log. Validate the actual
# DC log and mapped artifacts, not the FuseSoC wrapper's informational output.
bash scripts/check_synth_result.sh "$run_dir" || exit 1

printf 'Completed synthesis: %s\n' "$run_dir"
