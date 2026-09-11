# Smoke 与随机压力入口

默认smoke种子1，两种模式均执行；extended随机用1001..1010。所有入口必须核对RNTST与请求class一致，未实现时不计通过。

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.ACL.SMOKE
name: tc_apb_secure_demux_acl_smoke
type: directed
description: 复位后由管理主体启用一个端口并只给一个主体Secure特权读；顺序执行允许读、拒绝写和无效ID读。
priority: must
tier: smoke
implementation: verification/tc/tc_apb_secure_demux_acl_smoke.sv
feature_ref:
- FL.APB_SECURE_DEMUX.ACL
preconditions:
- 可信复位后已知初态；当前参数与构建身份一致
stimulus:
- 复位后由管理主体启用一个端口并只给一个主体Secure特权读；顺序执行允许读、拒绝写和无效ID读。
expected_result:
- 允许读完成一次；两笔拒绝首ACCESS读零/错误，副作用计数不变，管理身份无隐含端口权限。
timeout_policy: 200000 pclk cycles
param_config: CFG_TYPICAL_DIRECT
configuration_matrix:
- CFG_TYPICAL_DIRECT
- CFG_TYPICAL_REGISTER
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.CSR.SMOKE
name: tc_apb_secure_demux_csr_smoke
type: directed
description: 读取ID/CAP，合法管理写shadow再读回，非管理读写该shadow，读空洞。
priority: must
tier: smoke
implementation: verification/tc/tc_apb_secure_demux_csr_smoke.sv
feature_ref:
- FL.APB_SECURE_DEMUX.CSR
preconditions:
- 可信复位后已知初态；当前参数与构建身份一致
stimulus:
- 读取ID/CAP，合法管理写shadow再读回，非管理读写该shadow，读空洞。
expected_result:
- 参数镜像匹配，合法写成功，未授权访问读零且目标状态保持，空洞按优先级报错。
timeout_policy: 200000 pclk cycles
param_config: CFG_TYPICAL_DIRECT
configuration_matrix:
- CFG_TYPICAL_DIRECT
- CFG_TYPICAL_REGISTER
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.APB.SMOKE
name: tc_apb_secure_demux_apb_smoke
type: directed
description: 同一测试分别在direct/register配置访问零等待和3周期等待目标，再背靠背切换CSR和下游错误。
priority: must
tier: smoke
implementation: verification/tc/tc_apb_secure_demux_apb_smoke.sv
feature_ref:
- FL.APB_SECURE_DEMUX.APB
preconditions:
- 可信复位后已知初态；当前参数与构建身份一致
stimulus:
- 同一测试分别在direct/register配置访问零等待和3周期等待目标，再背靠背切换CSR和下游错误。
expected_result:
- 精确零/单额外等待，LOCAL首ACCESS完成；错误数据透传，等待保持，事务及事件无重复。
timeout_policy: 200000 pclk cycles
param_config: CFG_TYPICAL_DIRECT
configuration_matrix:
- CFG_TYPICAL_DIRECT
- CFG_TYPICAL_REGISTER
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.APB.RANDOM
name: tc_apb_secure_demux_random_stress
type: random
description: 在已知RM状态下交错随机权限更新、允许/拒绝访问、0..257周期目标等待、下游错误和可信复位；限制每笔合法输入稳定。
priority: must
tier: extended
implementation: verification/tc/tc_apb_secure_demux_random_stress.sv
feature_ref:
- FL.APB_SECURE_DEMUX.APB
preconditions:
- 可信复位后已知初态；当前参数与构建身份一致
stimulus:
- 在已知RM状态下交错随机权限更新、允许/拒绝访问、0..257周期目标等待、下游错误和可信复位；限制每笔合法输入稳定。
expected_result:
- 全部完成记录和RM一致；任何非法SETUP/身份错配/额外响应/丢失事务立即失败。
timeout_policy: 200000 pclk cycles
param_config: CFG_TYPICAL_DIRECT
configuration_matrix:
- CFG_TYPICAL_DIRECT
- CFG_TYPICAL_REGISTER
- CFG_MAX_DIRECT
- CFG_MAX_REGISTER
END_TESTCASE_META -->

