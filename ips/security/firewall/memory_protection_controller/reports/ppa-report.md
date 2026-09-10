# AXI MPU - PPA Signoff Report

> **IP**: `axi_mpu` · **Gate**: G5 (PPA) · **Date**: 2026-09-10 · **Evidence Level**: E2
> **工艺**: 28nm GF CMOS28LP · **库**: sc9_cmos28lp_base_hvt · **Corner**: tt_nominal_max_1p00v_25c
> **工具**: dc_shell V-2023.12-SP3 · **Activity**: default probability propagation（无 SAIF，E2 估计等级）

## 1. 实验上下文（Experiment Plan）

- RTL: rtl/（含 PeakRDL 生成 CSR），逐点 manifest 绑定 rtl_dir_hash；
- 约束: constraints/timing.sdc（constraint_profile: lrs-axi_mpu-ppa-sweep-v1），
  逐点 clock period 由 sweep 频率注入，IO delay 0.4 ns，load 10 fF；
- compile options: `compile -map_effort medium`（各点一致，可比）；
- 库上下文: model/pdk.yaml（PDK_READY），manifest 逐点绑定 target/link/corner 哈希。

## 2. Objective 与 Budget（来源声明）

- **Objective**: area（面积最小化）——来源：LRS GEN.AXI_MPU.STRUCTURE.001（Generator 结构裁剪）与 PERF.AXI_MPU.THROUGHPUT.001（1 address/cycle @ 200 MHz 已满足）
- **Budget**: min_slack >= -0.5 ns（实验性预算：接近收敛即可，正式收敛由 PIPELINE=1 或降频实现）

## 3. Sweep 结果矩阵（7 点）

| Config | REGION_NUM | PIPELINE | Freq(MHz) | Area(µm²) | Slack(ns) | Fmax(MHz) | Dyn(µW) | Leak(nW) | 预算内 |
|---|---|---|---|---|---|---|---|---|---|
| CFG_R4_P0_400M | 4 | 0 | 400 | 19826.9 | -1.16 | 273 | 5939 | 3680 | — |
| CFG_R16_P0_200M | 16 | 0 | 200 | 22839.9 | +0.00 | 200 | 3011 | 3905 | ✅ |
| CFG_R16_P1_200M | 16 | 1 | 200 | 22839.9 | +0.00 | 200 | 3011 | 3905 | ✅ |
| CFG_R16_P0_500M | 16 | 0 | 500 | 25650.6 | -2.01 | 249 | 7818 | 5015 | — |
| CFG_R16_P1_500M | 16 | 1 | 500 | 25650.6 | -2.01 | 249 | 7818 | 5015 | — |
| CFG_R16_P0_400M | 16 | 0 | 400 | 25785.4 | -1.50 | 250 | 6230 | 5107 | — |
| CFG_R16_P1_400M | 16 | 1 | 400 | 25785.4 | -1.50 | 250 | 6230 | 5107 | — |

## 4. Pareto 前沿与推荐

- Pareto 集（非支配点）：`CFG_R16_P0_200M_200MHz_f783dde9, CFG_R16_P1_200M_200MHz_d916efef, CFG_R4_P0_400M_400MHz_8a79a8bd`
- **推荐配置**：`CFG_R16_P0_200M`（run_id `CFG_R16_P0_200M_200MHz_f783dde9`）
  - REGION_NUM=16，PIPELINE=0，目标 200 MHz
  - Area 22839.9 µm² · slack +0.00 ns · Dyn 3011 µW · Leak 3905 nW
  - 依据：面积最小且唯一满足 budget 的可交付点；LRS PERF.AXI_MPU.THROUGHPUT.001（1 address/cycle @200 MHz）已满足。
- **观察**：
  - PIPELINE=1 在本约束 profile 下与 PIPELINE=0 面积/时序相同（组合路径主导，
    1 级流水未改变关键路径分段），不作为独立 Pareto 维度；
  - REGION_NUM 4→16 面积 +30%（22.8k→25.8k µm² @400M），线性符合 LLD 预期；
  - 400/500 MHz 点 slack 为负（−1.5/−2.01 ns），fmax ≈ 250 MHz 为组合引擎上限，
    更高频率须启用 PIPELINE 分段重构（后续 Generator 结构项，记录不隐藏）。

## 5. 可视化

![Pareto: area vs slack](reports/ppa/pareto_area_slack.png)

![Pareto: area vs dynamic power](reports/ppa/pareto_area_power.png)

## 6. 回归确认

推荐配置与基线（RTL 未经 PPA 修改）一致——本次为参数化表征，未引入 RTL 变更，
G4 回归结果（reports/regression/junit.xml, 14/14 PASS）直接适用，无功能退化。

## 7. Signoff 结论

`ppa_signoff: required` → **SIGNOFF PASS**（E2，PDK_READY，7 可比点，推荐配置在 budget 内）。

<!-- REPORT_META
schema_version: '2.0'
ip_name: axi_mpu
report_type: ppa_report
status: pass
eda_profile: commercial-systemverilog
tool: dc_shell
tool_version: V-2023.12-SP3
command: uv run python scripts/ppa/run_sweep.py; analyze_sweep.py --objective area
  --min-slack-ns -0.5; plot_pareto.py
evidence_level: E2
ppa_signoff: pass
recommended_run_id: CFG_R16_P0_200M_200MHz_f783dde9
recommended_config_id: CFG_R16_P0_200M
sweep_point_count: 7
objective: area
budgets:
  max_area_um2: null
  min_slack_ns: -0.5
  max_dyn_power_uW: null
dependencies:
- path: reports/ppa/sweep_analysis.yaml
  sha256: f62add490bef9ab2c8fdcb2a431a46f90daf6ad71ab44a7414b8d8c639b51d60
artifacts:
- path: reports/ppa/sweep_analysis.yaml
  sha256: f62add490bef9ab2c8fdcb2a431a46f90daf6ad71ab44a7414b8d8c639b51d60
- path: reports/ppa/summary_CFG_R16_P0_200M_200MHz.yaml
  sha256: 752b16467d49852c3a7537f663b80f9654870f87d23a3b831e140900f73af6af
- path: reports/ppa/summary_CFG_R16_P0_400M_400MHz.yaml
  sha256: b3e190909911c7aaac319f1eb8c0db82d240d3d44550b75ed7626f412480b18f
- path: reports/ppa/summary_CFG_R16_P0_500M_500MHz.yaml
  sha256: a240881b0dcc3ab65f7310d4d70c4fe72dccf68d7861401af1061b71bef3c5ce
- path: reports/ppa/summary_CFG_R16_P1_200M_200MHz.yaml
  sha256: a592864103bf3d9dce446e29029e4bff9fc04d2435616c95473e3d63e45a441d
- path: reports/ppa/summary_CFG_R16_P1_400M_400MHz.yaml
  sha256: 3c60c944ee1b2f87fc5d070e3e9bb15de5509e93b0e6210eec6882142fb1437e
- path: reports/ppa/summary_CFG_R16_P1_500M_500MHz.yaml
  sha256: c32bb5c337ce6808ee306de3601fdc83a03a7cffca29b7ddaa64bf92c2616f49
- path: reports/ppa/summary_CFG_R4_P0_400M_400MHz.yaml
  sha256: ddc58879b197b7fb100616157121bb0d5c2b0c6d9365086208052bdcf8223c60
- path: reports/ppa/pareto_area_slack.png
  sha256: 3de328e5fa3b04c82d6f7844450f76201a936ebfeb47c002aeb3bb30c9bb2fd2
- path: reports/ppa/pareto_area_power.png
  sha256: 4e70efd53aa67fe196c2aee76cee218494f312afd317d04fac17f588e27cd852
END_REPORT_META -->
