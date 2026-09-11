# 原子更新与不可逆锁：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.UPDATE.001
name: tc_apb_secure_demux_update
type: directed
description: 原子更新与不可逆锁
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_update.sv
feature_ref:
- FL.APB_SECURE_DEMUX.UPDATE
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.POLICY
- LLD.MOD.APB_SECURE_DEMUX.DFX
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 对多端口写非均匀shadow，前后访问并读回；提交空/越界/含锁端口掩码和reload，组合全局锁/端口锁/完整性；背靠背提交后立即SETUP；锁写零及复位。
expected_result:
- shadow不直接生效；成功全量同沿更新及版本加一，失败全部保持；COMMIT_STATUS独立顺序；锁只收紧；下一SETUP用新版本，撤权不撤销外设后台动作。
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

激励：对多端口写非均匀shadow，前后访问并读回；提交空/越界/含锁端口掩码和reload，组合全局锁/端口锁/完整性；背靠背提交后立即SETUP；锁写零及复位。

期望：shadow不直接生效；成功全量同沿更新及版本加一，失败全部保持；COMMIT_STATUS独立顺序；锁只收紧；下一SETUP用新版本，撤权不撤销外设后台动作。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
