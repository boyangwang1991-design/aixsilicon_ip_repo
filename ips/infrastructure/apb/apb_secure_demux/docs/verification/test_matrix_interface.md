# 接口稳定性与隔离：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.INTERFACE.001
name: tc_apb_secure_demux_interface
type: directed
description: 接口稳定性与隔离
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_interface.sv
feature_ref:
- FL.APB_SECURE_DEMUX.INTERFACE
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 上游身份/属性绑定请求，在SETUP、首ACCESS、长等待及背靠背端口切换观察全部信号；比较DFX授权高低和隔离开关。
expected_result:
- 下游原地址/身份/数据一致；未选master_valid始终零；等待稳定；无先行SETUP的ACCESS只报告协议违规且无下游选择。
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

激励：上游身份/属性绑定请求，在SETUP、首ACCESS、长等待及背靠背端口切换观察全部信号；比较DFX授权高低和隔离开关。

期望：下游原地址/身份/数据一致；未选master_valid始终零；等待稳定；无先行SETUP的ACCESS只报告协议违规且无下游选择。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
