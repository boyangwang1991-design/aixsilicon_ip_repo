# 28nm 综合报告 — apb_cdc_bridge

> **IP**: `apb_cdc_bridge` | **日期**: 2026-09-07 | **Gate**: G3 | **Report schema**: 2.0

## REPORT_META
<!-- REPORT_META
ip_name: apb_cdc_bridge
report_type: synth
status: pass
eda_profile: commercial-systemverilog
schema_version: "2.0"
tool: dc_shell
tool_version: "V-2023.12-SP3"
pdk_status: PDK_READY
target_library: sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db
operating_conditions: tt_nominal_max_1p00v_25c
clock_period_ns: 2.5
command: "dc_shell -f scripts/synth.tcl"
log: logs/dc_synth.log
log_sha256: 5187096a4da63967f94d46e0d2531eebe786d72cef8e555055f175f1189a7baf
END_REPORT_META -->

## 1. 工艺与工具

| 项 | 值 |
|---|---|
| 工艺 | GF CMOS28LP 28nm（ARM SC9 HVT 标准单元库） |
| 库 | `sc9_cmos28lp_base_hvt_tt_nominal_max_1p00v_25c.db`（tt corner, 1.00V / 25C） |
| 工具 | Synopsys DC `V-2023.12-SP3`（compile_ultra） |
| 时钟 | `s_pclk` / `m_pclk` 各 400MHz（2.5ns），异步域（set_clock_groups -asynchronous） |
| 工艺上下文 | `model/pdk.yaml`（`ip_pdk_scan.py` 固化, status=PDK_READY） |

## 2. 原始报告路径（build/ 运行产物，随回归可再生）

| 报告 | 路径 | SHA256 |
|---|---|---|
| DC 综合日志 | `logs/dc_synth.log` | `5187096a…` |
| QoR | `build/synth/reports/qor.rpt` | `a3eb29ff…` |
| Timing | `build/synth/reports/timing.rpt` | `f88c500c…` |
| Area | `build/synth/reports/area.rpt` | `b1350530…` |
| Power | `build/synth/reports/power.rpt` | `84ec111d…` |
| Constraint | `build/synth/reports/constraint.rpt` | — |
| Check Design | `build/synth/reports/check_design.rpt` | — |
| 门级网表 | `build/synth/outputs/apb_cdc_bridge_top_synth.v` | `eba0a34a…` |
| SDC | `build/synth/outputs/apb_cdc_bridge_top.sdc` | `ede2f691…` |
| SDF | `build/synth/outputs/apb_cdc_bridge_top.sdf` | — |

## 3. 结果摘要

| 指标 | 值 |
|---|---|
| **WNS / TNS** | **0.00 / 0.00**（400MHz 收敛） |
| Violating Paths | 0（无 slack 违例路径） |
| Critical Path | 0.77 ns（3 级逻辑） |
| Hold Violations | 0 |
| **Total Cell Area** | **1035.10 µm²** |
| － Combinational | 268.40 µm² |
| － Noncombinational / Sequential | 766.70 µm²（306 seq cells） |
| Macro / Black Box Area | **0**（无 unmapped） |
| Cells | 682（376 comb + 306 seq + 67 buf/inv） |
| **Total Dynamic Power** | **113.66 µW**（@400MHz tt） |
| Design Rules | Max Trans=0 / Max Cap=0 / Nets=794 |

## 4. 结论

**28nm DC 综合 PASS（G3 必要证据）** — compile_ultra @400MHz tt corner：
WNS/TNS=0、无 latch/组合环（check_design）、无 unmapped（Macro/Black Box=0）、
网表/SDC/SDF 写出，证据 SHA 齐全。满足 SKILL §5.9 "PDK_READY 时必须真实 28nm 综合"。

> 说明：`build/` 为运行产物（git 忽略），本报告为可追踪质量摘要；完整原始证据可在
> 重新运行 `./scripts/run_synth.sh` 后于 `build/synth/` 复查。