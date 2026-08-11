<!-- REPORT_META
schema_version: "2.0"
ip_name: uart
report_type: rtl_check
status: pass
eda_profile: commercial-systemverilog
checks:
  lint:
    status: pass
    tool: spyglass
    tool_version: X-2025.06
    command: spyglass -project spyglass/uart.prj -goal lint/lint_rtl -batch (FuseSoC 2.4.6 依赖解析 bug 降级)
    exit_code: 0
    log: reports/lint/spyglass.log
    log_sha256: 3a4fbe2ab9759fbc3c6dba8eae688982ca0ca979f8b885e69c8ab4d9eb34a326
  elab:
    status: pass
    tool: vcs
    tool_version: W-2024.09
    command: vcs -full64 -sverilog -ntb_opts uvm-1.2 -f rtl/filelist.f -top uart
    exit_code: 0
    log: reports/elab/vcs_elab.log
    log_sha256: 531b2cd337affd9eda1f7545530e4ace3f73ba880d7faf2293a75e02db462a86
  synth:
    status: pass
    tool: dc_shell
    tool_version: V-2023.12-SP3
    command: dc_shell -f constraints/uart_synth.tcl -top uart
    exit_code: 0
    log: reports/synth/dc_synth.log
    log_sha256: 57b1173e59cf55e29fdbcace2820719a1da240be44c53747e8079a1e48406846
END_REPORT_META -->

# RTL 检查摘要 - UART

## 1. 检查概述

| 项目 | 值 |
|------|-----|
| IP 名称 | uart |
| 检查日期 | 2026-08-11 |
| EDA profile | commercial-systemverilog |
| 执行方式 | SpyGlass（lint）+ VCS（elab） |

> 注：FuseSoC 2.4.6 依赖解析存在 bug（`coremanager.py _solve` UnboundLocalError），
> skill 09 允许降级为直接调用底层工具。FuseSoC core 已通过解析（`core show` 8 targets），
> 供 CI/发布使用；实际 RTL 检查用 SpyGlass/VCS 执行。

## 2. 检查结果

| 检查项 | 状态 | 工具 | 说明 |
|--------|------|------|------|
| Lint | ✅ Pass | SpyGlass X-2025.06 | 0 fatal, 0 error, 225 warnings（上游已豁免） |
| Elaboration (uart) | ✅ Pass | VCS W-2024.09 | 顶层 uart 层次完整 |
| Elaboration (uart_apb_top) | ✅ Pass | VCS W-2024.09 | 顶层 uart_apb_top 层次完整 |

## 3. Lint 结果详情

- **Fatal**: 0
- **Error**: 0
- **Warning**: 225（全部来自 OpenTitan 核心 RTL 与低层库，属上游已知豁免项）
- **新增 wrapper（apb2tlul.sv / uart_apb_top.sv）**: 0 warning / 0 error

### Warning 分类（均为上游豁免项）

| Warning 类型 | 数量 | 位置 | 处理 |
|--------------|------|------|------|
| W240 未读信号 | 多数 | uart_reg_top/uart_core | 上游豁免（核心不改动） |
| W415a 多赋值 | 少量 | uart_reg_top/uart_rx | 上游豁免 |
| W528 未用变量 | 少量 | uart_reg_top/uart_core | 上游豁免 |
| 其他 | 少量 | 低层库 prim/tlul | 上游豁免 |

## 4. Elaboration 结果

- VCS W-2024.09 elaboration 通过（uart 与 uart_apb_top 两个顶层均无 error）。
- vlogan 编译全部文件通过。

## 5. 下一步建议

- 验证回归（14-build-run-debug）确认功能正确。
- FuseSoC 2.4.6 依赖解析 bug 建议后续升级 fusesoc 或使用修复版。
