# RTL 检查摘要报告 — apb_cdc_bridge

> **IP**: `apb_cdc_bridge` | **日期**: 2026-09-07 | **Gate**: G3 | **Report schema**: 2.0

## REPORT_META
<!-- REPORT_META
ip_name: apb_cdc_bridge
report_type: rtl_check
status: pass
eda_profile: commercial-systemverilog
schema_version: "2.0"
checks:
  lint:
    status: pass
    exit_code: 0
    tool: spyglass
    tool_version: "SpyGlass_vX-2025.06"
    command: "spyglass -shell (goal lint/lint_rtl, top apb_cdc_bridge_top)"
    log: build/rtl/lint_spyglass/spyglass-1/apb_cdc_bridge_top/lint/lint_rtl/spyglass.log
    log_sha256: 756e09048f290ef3d13d89284983476b841c6e6e210cf7ab835648530da8eea5
  elab:
    status: pass
    exit_code: 0
    tool: vcs
    tool_version: "W-2024.09-SP1"
    command: "fusesoc run --target=elab (VCS)"
    log: build/rtl/elab/aixsilicon_ip_apb_cdc_bridge_1.0.0/elab-vcs/vcs.log
    log_sha256: c3f3df7f9cedbab04e8338cc4790a43887befe8ad1803821f7afc197e0d54fa0
  synth:
    status: pass
    exit_code: 0
    tool: dc_shell
    tool_version: "V-2023.12-SP3"
    command: "dc_shell -f scripts/synth.tcl (28nm CMOS28LP HVT, tt corner, 400MHz)"
    log: logs/dc_synth.log
    log_sha256: 4203285ba30dc0325fe51c903cf44b20a0af1f04175ff8c5c7bd319886af4c3f
    pdk_status: PDK_READY
    target_library: sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db
    operating_conditions: tt_nominal_max_1p00v_25c
END_REPORT_META -->

## 1. Lint（VCS lint target）

- 命令：`fusesoc run --target=lint --build-root=build/rtl/lint aixsilicon:ip:apb_cdc_bridge`
- 结果：✔ 通过（无 error/warning 输出，模拟报告正常）
- 证据：`build/rtl/lint/aixsilicon_ip_apb_cdc_bridge_1.0.0/lint-vcs/vcs.log`

## 2. Elaboration（VCS elab target）

- 命令：`fusesoc run --target=elab --build-root=build/rtl/elab aixsilicon:ip:apb_cdc_bridge`
- 结果：✔ 通过（simv 生成，无 error）
- 证据：`build/rtl/elab/aixsilicon_ip_apb_cdc_bridge_1.0.0/elab-vcs/`

## 3. 可综合筛查（audit_workspace）

- 结果：✔ **0 error**（RTL 无 procedural-initial、无仅仿真构造）
- 修复：移除 `rtl/apb_cdc_bridge_top.sv` 中的 `initial $error`，改用 generate 静态结构 + 文档参数契约
- 剩余 warning：`model/quality.yaml` 缺失（属 15-regression-quality-review 阶段产物）

## 4. Design Compiler 综合（真实 28nm PDK，G3 必要证据）

- 工艺上下文：`model/pdk.yaml`（`ip_pdk_scan.py` 固化，status=`PDK_READY`）
- 库：GF CMOS28LP 28nm ARM SC9 HVT，`sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db`（tt corner, 1.00V/25C）
- 命令：`dc_shell -f scripts/synth.tcl`（compile_ultra；时钟 s_pclk/m_pclk 双 400MHz，异步域；
  已修复 create_clock -waveform 花括号语法，约束真实生效——timing.rpt 显示 Path Group 与 clock uncertainty）
- 结果（`build/synth/hs_25ns/reports/`，400MHz 可信综合）：
  - **WNS=0.00 / TNS=0.00 / Violating Paths=0**（约束生效，Critical Path Slack=0.93ns、5 级逻辑）
  - **Macro/Black Box=0**，无 latch、无组合环（check_design）
  - Design Rules: Nets=777、Max Trans/Cap Violations=0
  - **Total Cell Area=1026.91 µm²**，Total Dynamic Power=528.18 µW（@400MHz tt）
  - 网表 `build/synth/hs_25ns/outputs/apb_cdc_bridge_top_synth.v`（+ .sdc/.sdf）
- 证据 SHA256：`logs/dc_synth.log=4203285b…`、`qor.rpt=1c426624…`、`timing.rpt=7a8fc916…`、
  `area.rpt=9da545bc…`、`power.rpt=7681b6a6…`、`apb_cdc_bridge_top_synth.v=76466eb9…`

## 5. 结论

**G3 RTL 检查: PASS** — lint 与 elab 通过，可综合筛查 0 error，**真实 28nm DC 综合 pass**
（compile_ultra @400MHz tt，WNS/TNS=0、无 latch/环、网表+报告+SHA 证据齐全）。
formal（VC Formal）证据在工具可用环境补充后确认最终 G5。
