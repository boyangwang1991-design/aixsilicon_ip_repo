# AXI MPU - RTL Check Summary

> **IP**: `axi_mpu` · **Gate**: G3 (RTL Ready) · **Date**: 2026-09-10
> **Owner**: IP Development Suite - 07/09

## 1. 检查概述

| 项目 | 值 |
|---|---|
| lint | VCS `+lint=all`，0 error / 0 warning |
| elab | VCS compile+elab+link，0 error |
| synth | DCShell 28nm（sc9_cmos28lp_base_hvt tt_nominal_max_1p00v_25c），0 error、no latch |
| synth 结果 | Total cell area 25917.7 um^2；WNS -0.37 ns @4ns（G3 不做时序收敛判定，PPA 优化属 20-skill） |

## 2. RTL 文件清单

| 文件 | 模块 |
|---|---|
| `rtl/include/axi_mpu_defs.svh` | 参数/deny_reason/Request Context |
| `rtl/generated/axi_mpu_csr_pkg.sv` | PeakRDL CSR package |
| `rtl/generated/axi_mpu_csr.sv` | PeakRDL CSR |
| `rtl/axi_mpu_permission.sv` | 权限引擎 |
| `rtl/axi_mpu_read.sv` | Read path FSM + 本地 DECERR |
| `rtl/axi_mpu_write.sv` | Write path + WQ + 本地 DECERR |
| `rtl/axi_mpu.sv` | 顶层 |

## 3. 修复记录

- `rtl/axi_mpu_read.sv`：`master_id_sideband`/`cap_master_id` 由硬编码 16 位改为
  `MASTER_ID_WIDTH` 参数化（DC LINK-3/PCWM 缺陷修复，顶层端口位宽一致）。

<!-- REPORT_META
schema_version: '2.0'
ip_name: axi_mpu
report_type: rtl_check
status: pass
eda_profile: commercial-systemverilog
checks:
  lint:
    status: pass
    tool: vcs
    tool_version: W-2024.09-SP1_Full64
    command: vcs -full64 -sverilog -ntb_opts uvm-1.2 +lint=all -f rtl/filelist.f -top
      axi_mpu -o build/rtl/lint_simv
    exit_code: 0
    log: reports/lint/vcs_lint.log
    log_sha256: 07e0b5327bd35098268763f2be049038d877eb2c1cb96582d20e48977c66b174
  elab:
    status: pass
    tool: vcs
    tool_version: W-2024.09-SP1_Full64
    command: vcs -full64 -sverilog -ntb_opts uvm-1.2 -f rtl/filelist.f -top axi_mpu
      -o build/rtl/elab_simv
    exit_code: 0
    log: reports/elab/vcs_elab.log
    log_sha256: b813c1c25b5966cb8601591712ca93b05337124ae38407676b7104c38bca0b34
  synth:
    status: pass
    tool: dc_shell
    tool_version: V-2023.12-SP3
    command: dc_shell -f build/rtl/synth/axi_mpu_synth.tcl (cwd build/rtl/synth)
    exit_code: 0
    log: reports/synth/dc_shell.log
    log_sha256: 041f201b9dd850c7908169ce3020de7663e794133d6fdfc393808d437a2d6a07
    pdk_status: PDK_READY
    target_library: sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db
    operating_conditions: tt_nominal_max_1p00v_25c
artifacts:
- path: reports/lint/vcs_lint.log
  sha256: 07e0b5327bd35098268763f2be049038d877eb2c1cb96582d20e48977c66b174
- path: reports/elab/vcs_elab.log
  sha256: b813c1c25b5966cb8601591712ca93b05337124ae38407676b7104c38bca0b34
- path: reports/synth/dc_shell.log
  sha256: 041f201b9dd850c7908169ce3020de7663e794133d6fdfc393808d437a2d6a07
END_REPORT_META -->
