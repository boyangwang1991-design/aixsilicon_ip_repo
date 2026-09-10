# AXI MPU - Module Unit Test Summary

> **IP**: `axi_mpu` · **Gate**: G3 (RTL Ready) · **Date**: 2026-09-10
> **Owner**: IP Development Suite - ut-module-level

## 1. 概述

对 `axi_mpu_permission` 模块（权限引擎）执行模块级单元测试，覆盖 Default Deny、
Region match/priority、Master/Security/Privilege/Operation 权限、非法 Master ID、
Burst 边界保护（13 项 directed check 全 PASS）。

## 2. 测试环境

- 仿真器：VCS `-full64 -sverilog -ntb_opts uvm-1.2`
- DUT：`axi_mpu_permission`（REGION_NUM=16, MASTER_NUM=8）
- Testbench：`verification/unit_test/ut_permission.sv`
- 编译日志：`reports/quality/ut_permission_compile.log`
- 运行日志：`reports/quality/ut_permission_run.log`

## 3. 结果

`UT_PERMISSION: PASS (errors=0)`（13/13 directed checks 通过，0 FAIL/0 TIMEOUT）

<!-- REPORT_META
schema_version: '2.0'
ip_name: axi_mpu
report_type: module_ut
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1_Full64
command: vcs -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps -debug_access+all
  -f rtl/filelist.f verification/unit_test/ut_permission.sv -o build/rtl/ut_permission64
  && build/rtl/ut_permission64
test_count: 1
checks:
  ut_permission:
    status: pass
    compile_log: reports/quality/ut_permission_compile.log
    run_log: reports/quality/ut_permission_run.log
artifacts:
- path: reports/quality/ut_permission_compile.log
  sha256: 41462dfa1e471d374d932ffd9f0948875b4115d9d3e51190217fee9d1e257e4d
- path: reports/quality/ut_permission_run.log
  sha256: 3d627bfe939ae62a92e2cad98a148aa334de75c9cbf8fc8ddb03d241a5469b30
END_REPORT_META -->
