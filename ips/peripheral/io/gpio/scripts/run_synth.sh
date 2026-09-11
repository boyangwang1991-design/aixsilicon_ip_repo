#!/usr/bin/env bash
set -euo pipefail
export IP_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$IP_ROOT"
: "${UV_PROJECT:?set UV_PROJECT to the workflow root}"
export GPIO_PDK_SETUP="$IP_ROOT/build/rtl/pdk_setup.tcl"
export GPIO_SYNTH_SDC="$IP_ROOT/constraints/gpio_characterization.sdc"
export GPIO_SYNTH_PARAMETERS="${2:-N_GPIO=8}"
point="${1:-gpio8}"
[[ "$point" =~ ^[a-zA-Z0-9_]+$ ]] || exit 2
mkdir -p build/rtl
run_dir=$(mktemp -d "build/rtl/synth_${point}.XXXXXXXX")
printf 'Synthesis run: %s\nParameters: %s\n' "$run_dir" "$GPIO_SYNTH_PARAMETERS"
uv run --locked --no-sync fusesoc --cores-root=. --cores-root=build/cbb_adapter run \
  --target=synth --build-root="$run_dir" aixsilicon:ip:gpio:0.1.0 > "$run_dir/console.log" 2>&1
if ! rg -q 'GPIO_SYNTHESIS_COMPLETE' "$run_dir/console.log" || rg -q '^Error:|Error-[[]|^FATAL:|^Fatal:' "$run_dir/console.log"; then
  tail -40 "$run_dir/console.log"
  exit 1
fi
printf 'Completed synthesis: %s\n' "$run_dir"
