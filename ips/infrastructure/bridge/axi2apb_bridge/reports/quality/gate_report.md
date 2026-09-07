# X2P 质量门禁报告（Gate Report）

## 门禁状态总览

| Gate | 状态 | 证据 |
|---|---|---|
| G0 (LRS Ready) | **PASS** | 42 需求抽取验证，`reports/quality/lrs_check.md` |
| G1 (HLD Ready) | **PASS** | 7 模块/42 需求覆盖，`extract_hld.py` 校验通过 |
| G2 (LLD Ready) | **PASS** | 7 模块/3 FSM/2 CDC，`extract_lld.py` 校验通过 |
| G3 (RTL Ready) | **PASS** | VCS lint + elab + DC synth 全通过（烧写 RTL candidate），formal exploratory |
| G4 (Verification Ready) | **FAIL** | smoke 读路径 R timeout（BUG-001）；验证环境编译与写路径通过 |
| G5 (Release Ready) | **NOT PASS** | G4 未通过，不能发布 |

## 关键证据

| 项 | 路径/结果 |
|---|---|
| LRS 抽取 | `model/requirements.yaml`（42 条） |
| HLD 抽取 | `model/architecture.yaml` 等 5 模型 |
| LLD 抽取 | `model/micro_design.yaml` |
| 验证方案 | `model/verification.yaml`（15 features/16 tc/13 as/9 cov） |
| RTL lint | `build/aixsilicon_ip_x2p_1.0.0/lint-vcs/vcs.log` PASS |
| RTL elab | `build/.../elab-vcs/vcs.log` PASS |
| RTL synth | `reports/synth/qor.rpt` + `SYNTH_OK` PASS |
| UVM 编译 | `verification/sim/run/compile.log` PASS |
| Smoke | `reports/smoke/smoke_summary.md` partial_fail（写 PASS/读 FAIL） |
| Trace | `trace/req_to_hld.yaml(43)` / `hld_to_lld(7)` / `lld_to_rtl(7)` / `req_to_test(91)` |

## Bug 清单（open）

| ID | 严重度 | 描述 | 状态 |
|---|---|---|---|
| BUG-001 | High | AXI 读请求 RVALID 永不建立（R timeout 10ms） | open |

## 结论

- G0-G3 达成：需求/架构/微架构/可综合 RTL 均已通过确定性校验。
- G4 未达成：读路径缺陷 BUG-001 未闭环，read 功能验证失败。
- 交付物为 **candidate**（含已知缺陷），不允许正式发布。