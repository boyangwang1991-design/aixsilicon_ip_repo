#!/usr/bin/env bash
# =============================================================================
# run_synth.sh — apb_cdc_bridge 28nm DC 综合执行入口（仓库卫生: 产物落 build/）
# 用法: ./scripts/run_synth.sh [CLK_PERIOD_NS]   （默认 2.5 ns = 400MHz）
# 依赖: model/pdk.yaml（PDK_READY）+ scripts/synth.tcl
# 产物: build/synth/{reports,outputs,work}/ + logs/dc_synth.log
# =============================================================================
set -e
cd "$(dirname "$0")/.."   # 切到 IP 工作区根

DC=/home/eda/app/synopsys/syn/V-2023.12-SP3/bin/dc_shell
CLK_PERIOD_NS="${1:-2.5}"

mkdir -p logs build/synth

echo "==> DC 综合启动 (28nm CMOS28LP HVT, ${CLK_PERIOD_NS}ns @ tt corner, $(pwd))"
"$DC" -f scripts/synth.tcl -x "set CLK_PERIOD_NS ${CLK_PERIOD_NS}" | tee logs/dc_synth.log

echo "==> 综合完成. 产物:"
ls -l build/synth/outputs/ 2>/dev/null
grep -hE "Total cell area|Number of ports|Number of nets|Number of cells" \
  build/synth/reports/area.rpt 2>/dev/null | head -6 || true