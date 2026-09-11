# 两模式典型最大表征：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.PPA.001
name: tc_apb_secure_demux_ppa
type: static
description: 两模式典型最大表征
priority: must
tier: extended
implementation: scripts/verification/check_ppa_evidence.py
feature_ref:
- FL.APB_SECURE_DEMUX.PPA
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.ROUTE
preconditions:
- 合法实例配置与当前源码构建身份一致
- 系统/工艺证据需由对应owner提供
stimulus:
- 在受控PDK/corner/SDC下运行典型/最大×direct/register四点，检查全部输入输出与完整性准入路径约束、资源位宽和latch/多驱动；提取工具原始面积/关键路径。
expected_result:
- 报告与配置/RTL/工具/库hash绑定；无未约束关键路径、额外等待或虚构性能数值；数据区与保护开销分别披露。
timeout_policy: 200000 pclk cycles for simulation; 1200 s tool timeout
param_config: CFG_TYPICAL_DIRECT
configuration_matrix:
- CFG_TYPICAL_DIRECT
- CFG_TYPICAL_REGISTER
- CFG_MAX_DIRECT
- CFG_MAX_REGISTER
- CFG_MIN_NOFIFO
- CFG_MIN_FIFO1
- CFG_NONPOWER
- CFG_TRIMMED
proof_kind: static
END_TESTCASE_META -->

激励：在受控PDK/corner/SDC下运行典型/最大×direct/register四点，检查全部输入输出与完整性准入路径约束、资源位宽和latch/多驱动；提取工具原始面积/关键路径。

期望：报告与配置/RTL/工具/库hash绑定；无未约束关键路径、额外等待或虚构性能数值；数据区与保护开销分别披露。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
