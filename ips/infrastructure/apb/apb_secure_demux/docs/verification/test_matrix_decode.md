# 完整地址译码：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.DECODE.001
name: tc_apb_secure_demux_decode
type: boundary
description: 完整地址译码
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_decode.sv
feature_ref:
- FL.APB_SECURE_DEMUX.DECODE
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.DECODE
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 访问每端口首末字节及相邻空洞、本地CSR首末和扩展洞；关闭端口但保持命中；在verification中注入双端口或CSR+端口多命中。
expected_result:
- 全部有效地址位参与；无命中/多命中优先拒绝且零下游PSEL；唯一目标原地址透传，外设低位和PSTRB不被额外过滤。
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

激励：访问每端口首末字节及相邻空洞、本地CSR首末和扩展洞；关闭端口但保持命中；在verification中注入双端口或CSR+端口多命中。

期望：全部有效地址位参与；无命中/多命中优先拒绝且零下游PSEL；唯一目标原地址透传，外设低位和PSTRB不被额外过滤。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
