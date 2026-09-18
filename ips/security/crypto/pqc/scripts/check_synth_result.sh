#!/usr/bin/env bash
# Read-only validation of an existing FuseSoC DC result; never edits its evidence.
set -euo pipefail
pqc_synth_dir=${1:?usage: check_synth_result.sh BUILD_ROOT}
pqc_dc_reports="$pqc_synth_dir/aixsilicon_ip_pqc_0.1.0/synth-design_compiler/reports"
pqc_dc_log="$pqc_dc_reports/synth.log"
if [ ! -s "$pqc_dc_log" ] || ! grep -q '^PQC_SYNTHESIS_COMPLETE$' "$pqc_dc_log" ||
   ! grep -q '^PQC_SRAM_POLICY: 2 storage-only blackboxes' "$pqc_dc_log" ||
   grep -Eq '^Error:|Error-\[|^FATAL:|^Fatal:|Internal system error' "$pqc_dc_log"; then
  echo "PQC_SYNTH_RESULT_FAIL: missing completion/SRAM policy or DC error"
  exit 1
fi
for pqc_artifact in area.rpt timing.rpt power.rpt design_check.rpt constraints.rpt pqc_netlist.v pqc_mapped.sdc; do
  [ -s "$pqc_dc_reports/$pqc_artifact" ] || { echo "missing mapped artifact: $pqc_artifact"; exit 1; }
done
printf 'PQC_SYNTH_RESULT_PASS: %s\n' "$pqc_dc_reports"
# This validates execution/artifact presence only. Timing closure, warning review,
# SRAM macro binding and G3/G5 signoff are separate decisions.
