# 系统信任证据：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.SYSTEM.001
name: tc_apb_secure_demux_system
type: static
description: 系统信任证据
priority: must
tier: extended
implementation: scripts/verification/check_system_evidence.py
feature_ref:
- FL.APB_SECURE_DEMUX.SYSTEM
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
preconditions:
- 合法实例配置与当前源码构建身份一致
- 系统/工艺证据需由对应owner提供
stimulus:
- 核对集成方受控IHI0024版本审查、X2P读写身份/属性追踪、路径/别名保护清单、reset及DFX可信来源，包含缓冲/仲裁/CDC后的绑定证据。
expected_result:
- 每项系统需求有当前实例及输入哈希对应的实证；缺失或仅有自述则失败；不声称抵抗任意物理注入或满足未声明认证。
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

激励：核对集成方受控IHI0024版本审查、X2P读写身份/属性追踪、路径/别名保护清单、reset及DFX可信来源，包含缓冲/仲裁/CDC后的绑定证据。

期望：每项系统需求有当前实例及输入哈希对应的实证；缺失或仅有自述则失败；不声称抵抗任意物理注入或满足未声明认证。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
