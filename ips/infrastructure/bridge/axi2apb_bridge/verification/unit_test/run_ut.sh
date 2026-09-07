#!/usr/bin/env bash
# =============================================================================
# run_ut.sh - 编译并运行 X2P 各模块 unit test（VCS）
# 用法: bash run_ut.sh [test_name]     (不带参数则运行全部)
#   可用测试: ut_req_mgr ut_scheduler ut_transfer_engine ut_apb_engine
#             ut_rsp_mgr ut_read_path
# 结果 PASS/FAIL 由各 testbench 自检打印。
# =============================================================================
set -u
TOP=$(cd "$(dirname "$0")/../.." && pwd)          # ip_x2p/
RTL="$TOP/rtl"
# 仓库卫生约定：运行中间件一律入 <ip>/build/（verification/ 只放源码）
OUT="$TOP/build/sim/run/ut"
mkdir -p "$OUT"

ALL_RTL="$RTL/x2p_pkg.sv $RTL/x2p_req_mgr.sv $RTL/x2p_scheduler.sv \
         $RTL/x2p_transfer_engine.sv $RTL/x2p_cdc.sv $RTL/x2p_apb_engine.sv \
         $RTL/x2p_rsp_mgr.sv $RTL/x2p_axi_frontend.sv $RTL/x2p_top.sv"

# test -> 需要的 RTL 集合
declare -A NEED=(
  [ut_req_mgr]="$RTL/x2p_pkg.sv $RTL/x2p_req_mgr.sv"
  [ut_scheduler]="$RTL/x2p_pkg.sv $RTL/x2p_scheduler.sv"
  [ut_transfer_engine]="$ALL_RTL"
  [ut_apb_engine]="$RTL/x2p_pkg.sv $RTL/x2p_apb_engine.sv"
  [ut_rsp_mgr]="$RTL/x2p_pkg.sv $RTL/x2p_rsp_mgr.sv"
  [ut_read_path]="$ALL_RTL"
)

run_one() {
  local t="$1"
  local rtl="${NEED[$t]}"
  if [ -z "${rtl:-}" ]; then echo "unknown test: $t"; return 1; fi
  echo "============== $t =============="
  # cd 到 $OUT 再编译：VCS 的 csrc/ 生成在当前工作目录，若不 cd 会落在源码目录
  # verification/unit_test/csrc（violation）。simv 与 csrc 统一进 build/sim/run/ut/。
  if (cd "$OUT" && vcs -sverilog -timescale=1ns/1ps -full64 -notice +vcs+flush+all \
        $rtl "$TOP/verification/unit_test/$t.sv" -o "${t}_simv" > "$t.compile.log" 2>&1); then
    :
  else
    echo "COMPILE FAIL for $t (see $OUT/$t.compile.log)"
    grep -iE "Error|Warning-" "$OUT/$t.compile.log" | head -20
    return 1
  fi
  timeout 120 "$OUT/${t}_simv" 2>&1 | grep -E "PASS|FAIL|TIMEOUT" | tail -20
}

if [ $# -ge 1 ]; then
  run_one "$1"
else
  for t in ut_req_mgr ut_scheduler ut_transfer_engine ut_apb_engine ut_rsp_mgr ut_read_path; do
    run_one "$t"
  done
fi
