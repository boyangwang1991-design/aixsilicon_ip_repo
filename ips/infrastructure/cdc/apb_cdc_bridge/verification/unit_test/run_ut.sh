#!/usr/bin/env bash
# =============================================================================
# run_ut.sh - 编译并运行 APB CDC Bridge 各模块 unit test（VCS）
# 用法: bash run_ut.sh [test_name]     (不带参数则运行全部)
#   可用测试: ut_sync_chain ut_handshake ut_async_fifo ut_source ut_dest ut_top_path
# 结果 PASS/FAIL 由各 testbench 自检打印。
# 仓库卫生约定：运行中间件一律入 <ip>/build/sim/run/ut/（verification/ 只放源码）
# =============================================================================
set -u
TOP=$(cd "$(dirname "$0")/../.." && pwd)
RTL="$TOP/rtl"
OUT="$TOP/build/sim/run/ut"
mkdir -p "$OUT"

# RTL 依赖
ALL_RTL="$RTL/apb_cdc_bridge_pkg.sv $RTL/apb_cdc_sync_chain.sv \
         $RTL/apb_cdc_handshake.sv $RTL/apb_cdc_async_fifo.sv \
         $RTL/apb_cdc_source.sv $RTL/apb_cdc_dest.sv \
         $RTL/apb_cdc_bridge_top.sv"

# test -> 需要的 RTL 集合
declare -A NEED=(
  [ut_sync_chain]="$RTL/apb_cdc_sync_chain.sv"
  [ut_handshake]="$RTL/apb_cdc_bridge_pkg.sv $RTL/apb_cdc_sync_chain.sv $RTL/apb_cdc_handshake.sv"
  [ut_async_fifo]="$RTL/apb_cdc_bridge_pkg.sv $RTL/apb_cdc_async_fifo.sv"
  [ut_source]="$RTL/apb_cdc_bridge_pkg.sv $RTL/apb_cdc_source.sv"
  [ut_dest]="$RTL/apb_cdc_bridge_pkg.sv $RTL/apb_cdc_dest.sv"
  [ut_top_path]="$ALL_RTL"
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
  for t in ut_sync_chain ut_handshake ut_async_fifo ut_source ut_dest ut_top_path; do
    run_one "$t"
  done
fi
