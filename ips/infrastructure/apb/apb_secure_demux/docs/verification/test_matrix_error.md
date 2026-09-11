# 多错误主原因排序：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.ERROR.001
name: tc_apb_secure_demux_error
type: negative
description: 多错误主原因排序
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_error.sv
feature_ref:
- FL.APB_SECURE_DEMUX.ERROR
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.ACCESS
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 构造每个相邻优先级对及三重冲突：地址/身份/完整性/禁用/指令/权限/注入，CSR授权/对齐/选通/存在/类型/锁/命令/完整性。
expected_result:
- 只记录最高优先主原因；未授权不泄露敏感存在性；COMMIT_STATUS可与日志不同，例锁+空掩码log CFG_LOCKED而诊断MASK。
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
END_TESTCASE_META -->

激励：构造每个相邻优先级对及三重冲突：地址/身份/完整性/禁用/指令/权限/注入，CSR授权/对齐/选通/存在/类型/锁/命令/完整性。

期望：只记录最高优先主原因；未授权不泄露敏感存在性；COMMIT_STATUS可与日志不同，例锁+空掩码log CFG_LOCKED而诊断MASK。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
