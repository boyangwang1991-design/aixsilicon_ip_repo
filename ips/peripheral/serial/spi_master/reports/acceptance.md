# SPI Master 实施与验收报告

本合同的可综合 IP、RDL 生成链、验证环境、驱动示例及复现入口已实现；本机动态测试和真实 28nm 综合通过。交付为 **1.0.0 experimental 候选实现**，G0–G5 结果见下文；交付范围为 IP 及 100 MHz / GF28nm 表征基线，不等于量产或板级冻结。

| 验收项 | 实测结果 |
|---|---|
| UVM 参数矩阵 | 4 配置 × 9 组 = 36/36 PASS |
| 追加随机 | seeds 17/101/2026，3/3 PASS；每 seed 32 次随机事务 |
| 模块 UT | FIFO 2,000 次随机周期；engine 精确超时/进展优先、等待原因切换、末沿中止保留 RX、九状态复位、DONE_COUNT 回绕，通过 |
| 非法参数 | 11/11 正确拒绝 |
| 软件 | C11 严格编译、长流和计数回绕、锁/屏障、总期限和恢复 mock 测试通过 |
| 功能覆盖 | 96/96 bins；其中模式×位宽×位序 72/72 |
| 手写 RTL 行覆盖 | top/engine/queues 均 100% |
| IP SVA | 6/6 有真实成功；全报告 assertion failure=0 |
| 静态 | SpyGlass 0 Fatal / 0 Error / 150 Warning，逐类分析，无工具 waiver |
| 综合 | small/default/max，真实 GF 28nm，全部通过 |
| 追踪 | 93 条 LRS → HLD → LLD → RTL 与 verification proof；由套件提取及 trace 工具生成 |

## 28nm PPA 表征

GF CMOS28LP sc9 base HVT，TT 1.00 V / 25°C，DC V-2023.12-SP3。目标库和 operating condition 由 model/pdk.yaml 与 build/rtl/pdk_setup.tcl 绑定。100 MHz PCLK、IO/负载假设见 constraints/characterization.sdc。

| 配置 | CS/TX/RX/CMD | cell area (µm²) | 最差 slack (ns) | dynamic power |
|---|---|---:|---:|---:|
| small | 1/4/4/2 | 9295.533 | 2.36 | 770.7318 uW |
| default | 4/32/32/4 | 16622.307 | 2.64 | 1.5612 mW |
| max | 8/256/256/16 | 72418.553 | 2.85 | 7.6922 mW |

三种配置均生成真实门级网表，零 violated constraints。功耗为默认概率传播的 vectorless 估计，未经工作负载 VCD/SAIF 标定；不等于实测功耗。无布局布线、Pad、PCB 或功耗门控签核。源/导出副本/网表哈希见各配置 source-binding.json。


## 交付与复现

入口 [README](../README.md)、[Makefile](../Makefile)、[集成指南](../docs/integration.md)。[回归证据](regression/regression_summary.md)、[覆盖率评审](coverage/coverage_summary.md)、[静态评审](quality/static-review.md)、[需求追踪](quality/trace_matrix.md)、[SKILL 改进报告](skill-improvement-report.md)。当前源码/工具脚本清单见 [delivery-manifest.json](quality/delivery-manifest.json)。CBB 源码与原始合同未由本次实现修改，只有原资产的构建元数据在 build 内适配。

## 验收边界与保留项

当前门禁（含明确记录的 SPI mixed-proof 本地适配）：G0=pass、G1=pass、G2=pass、G3=pass、G4=pass、G5=pass。全部 53 项实际执行 PASS。原始未适配套件结果另保存在 quality/upstream-gate-report.md，便于复核工具对 C/static proof 的支持缺口。

原始默认 DUT 行覆盖 91.62%、FSM 转移 75%、低 toggle 的空洞已记录；未将未覆盖项自动豁免。按用户授权，原始 DUT 行覆盖以 90% 为本次 G5 门槛；未达原暂定 95% 的差距仍保留。独立形式引擎未安装，专用 CDC/RDC 与布局后 recovery/removal 没有工具证明；已完成单时钟/复位结构审查及动态检查。

目标外设是否允许暂停、最终 PCLK/SCLK、Pad/板级 MISO 预算和负载未给定，100 MHz 只用于可复现表征。默认软件流式 API 仅适用于允许帧边界暂停的器件。

LRS/HLD/LLD 保留 draft，独立技术审查和项目冻结记录不伪造。[Gate 重算](quality/gate_report.md) 和 [适配器来源](quality/quality-evaluator-adapter.json) 记录本次工具执行结果；用户的自动执行授权不被当作技术审查签名。需要上游改进的 21 项发现及本地处理均已记录。
