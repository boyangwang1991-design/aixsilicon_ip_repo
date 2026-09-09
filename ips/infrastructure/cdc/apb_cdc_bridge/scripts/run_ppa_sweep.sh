#!/usr/bin/env bash
# =============================================================================
# run_ppa_sweep.sh — apb_cdc_bridge 多配置 PPA Sweep（28nm DC 综合）
# -----------------------------------------------------------------------------
# 对齐 20-ppa-optimization：每个参数组合/配置 × 频率都做综合，每点写 run manifest。
# Sweep 维度：
#   - CDC_IMPL  : 0=HANDSHAKE, 1=ASYNC_FIFO
#   - REQ/RSP_DEPTH: FIFO 深度（HANDSHAKE 忽略；FIFO 支持 1/2）
#   - 频率       : 200MHz (5.0ns) / 400MHz (2.5ns) / 600MHz (1.667ns)
# 产物: build/synth/<run_tag>/{reports,outputs}/ + evidence/ppa/<run_id>/
#       evidence/ppa/<run_id>/sweep_summary.csv   # 所有扫描点汇总（供 PPA 报告/Pareto）
# =============================================================================
set -e
cd "$(dirname "$0")/.."

DC=/home/eda/app/synopsys/syn/V-2023.12-SP3/bin/dc_shell
RUN_ID="ppa_$(date +%Y%m%d_%H%M%S)"
EVIDENCE_DIR="evidence/ppa/${RUN_ID}"
mkdir -p "${EVIDENCE_DIR}"

# ---- Sweep 矩阵 ----
declare -a FREQ_NS=(5.0 2.5 1.667)          # 200/400/600MHz
declare -a CONFIGS=(
  "CDC_IMPL=0|REQ_DEPTH=1|RSP_DEPTH=1|hs"          # HANDSHAKE
  "CDC_IMPL=1|REQ_DEPTH=1|RSP_DEPTH=1|fifo_d1"     # ASYNC_FIFO depth1
  "CDC_IMPL=1|REQ_DEPTH=2|RSP_DEPTH=2|fifo_d2"     # ASYNC_FIFO depth2
)

echo "==> PPA Sweep 启动 (run_id=${RUN_ID})"
echo "==> 输出: build/synth/<tag>/ ; 摘要: ${EVIDENCE_DIR}/sweep_summary.csv"

echo "run_tag,clock_ns,freq_mhz,cdc_impl,req_depth,rsp_depth,total_area_um2,dyn_power_uW,wns_ns,tns_ns,violating_paths,slack_ns" > "${EVIDENCE_DIR}/sweep_summary.csv"

for cfg in "${CONFIGS[@]}"; do
  IFS='|' read -r c_impl c_req c_rsp c_name <<< "${cfg}"
  impl_val=${c_impl#*=}; req_val=${c_req#*=}; rsp_val=${c_rsp#*=}

  for ns in "${FREQ_NS[@]}"; do
    run_tag="${c_name}_$(echo ${ns} | tr -d '.')ns"
    freq_mhz=$(awk "BEGIN{printf \"%d\", 1000/${ns}+0.5}")
    echo ""
    echo "========== ${run_tag} (${c_impl}, ${c_req}, ${c_rsp}, ${freq_mhz}MHz) =========="

    "${DC}" -f scripts/synth.tcl -x "set CLK_PERIOD_NS ${ns}; set CDC_IMPL ${impl_val}; set REQ_DEPTH ${req_val}; set RSP_DEPTH ${rsp_val}; set RUN_TAG ${run_tag}" \
      > "${EVIDENCE_DIR}/${run_tag}.log" 2>&1 || { echo "!! FAIL ${run_tag} (see log)"; continue; }

    RPT="build/synth/${run_tag}/reports"
    area=$(grep -m1 "Total cell area" "${RPT}/area.rpt" | awk '{print $4}')
    dynp=$(grep -m1 "Total Dynamic Power" "${RPT}/power.rpt" | awk '{print $5}')
    wns=$(grep -m1 "Design  WNS" "${RPT}/qor.rpt" | awk '{print $3}')
    tns=$(grep -m1 "Design  WNS" "${RPT}/qor.rpt" | awk '{print $5}')
    viol=$(grep -m1 "Design  WNS" "${RPT}/qor.rpt" | awk '{print $10}')
    slack=$(grep -m1 "Critical Path Slack" "${RPT}/qor.rpt" | awk '{print $4}')
    echo "${run_tag},${ns},${freq_mhz},${impl_val},${req_val},${rsp_val},${area},${dynp},${wns},${tns},${viol},${slack}" >> "${EVIDENCE_DIR}/sweep_summary.csv"
    echo "    area=${area}um2  dyn_power=${dynp}uW  WNS=${wns}  slack=${slack}ns"
  done
done

echo ""
echo "===== Sweep 完成 (${RUN_ID}) ====="
echo "摘要: ${EVIDENCE_DIR}/sweep_summary.csv"
cat "${EVIDENCE_DIR}/sweep_summary.csv"