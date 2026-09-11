# 参数边界与裁剪：用例

<!-- TESTCASE_META
id: TC.APB_SECURE_DEMUX.PARAM.001
name: tc_apb_secure_demux_param
type: boundary
description: 参数边界与裁剪
priority: must
tier: regression
implementation: verification/tc/tc_apb_secure_demux_param.sv
feature_ref:
- FL.APB_SECURE_DEMUX.PARAM
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
- LLD.MOD.APB_SECURE_DEMUX.DECODE
preconditions:
- 合法实例配置与当前源码构建身份一致
- 可信复位释放后由管理事务配置已知初态
stimulus:
- 软件checker与真实elaboration分别运行75个支持矩阵点；正例覆盖1/8/32端口、1/16/64主体、FIFO0/1/8/32、非二幂和全部开关；11负例逐项核对预期失败阶段。
expected_result:
- 合法配置可构建并执行；非法配置在指定阶段失败；完整MASTERID域、地址末端、重叠、数组长度不能静默截断。
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

激励：软件checker与真实elaboration分别运行75个支持矩阵点；正例覆盖1/8/32端口、1/16/64主体、FIFO0/1/8/32、非二幂和全部开关；11负例逐项核对预期失败阶段。

期望：合法配置可构建并执行；非法配置在指定阶段失败；完整MASTERID域、地址末端、重叠、数组长度不能静默截断。

本用例覆盖同名feature列出的全部需求，运行器必须遍历适用配置并报告每个子场景。新建入口并不表示已实现或已执行。
