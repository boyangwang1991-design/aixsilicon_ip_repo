# 两模式APB周期：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.APB.001
name: tc_apb_secure_demux_apb
type: stress
description: 两模式APB周期
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_apb.sv
feature_ref:
- FL.APB_SECURE_DEMUX.APB
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.ROUTE
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 使用零/1/17/257周期等待下游，轮转端口、读写、CSR与拒绝，PSEL保持高形成背靠背；下游错误携带非零PRDATA；等待期间改变策略原始保护位或撤销DFX授权。
expected_result:
- direct零额外等待、register恰好一拍额外等待，LOCAL首ACCESS完成；无posted成功或撤销PSEL；下游错误及数据透传，空闲响应零，一笔只完成一次。
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

激励：使用零/1/17/257周期等待下游，轮转端口、读写、CSR与拒绝，PSEL保持高形成背靠背；下游错误携带非零PRDATA；等待期间改变策略原始保护位或撤销DFX授权。

期望：direct零额外等待、register恰好一拍额外等待，LOCAL首ACCESS完成；无posted成功或撤销PSEL；下游错误及数据透传，空闲响应零，一笔只完成一次。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
