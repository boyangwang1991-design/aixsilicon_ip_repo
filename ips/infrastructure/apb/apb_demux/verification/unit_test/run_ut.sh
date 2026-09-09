#!/usr/bin/env bash
# run_ut.sh - APB Demux 模块级单元测试（VCS）
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IP_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
UT_BUILD="$IP_ROOT/build/rtl/ut"
mkdir -p "$UT_BUILD"
cd "$UT_BUILD"
vcs -sverilog -timescale=1ns/1ps -full64 -quiet \
  "$IP_ROOT/rtl/apb_demux_top.sv" \
  "$SCRIPT_DIR/ut_apb_demux.sv" \
  -o ut_simv 2>&1 | tee ut_compile.log
./ut_simv 2>&1 | tee ut_run.log
grep -qE "^UT_[A-Za-z0-9_]+: PASS \(errors=0\)" ut_run.log
echo "UT_apb_demux: PASS (errors=0)"
