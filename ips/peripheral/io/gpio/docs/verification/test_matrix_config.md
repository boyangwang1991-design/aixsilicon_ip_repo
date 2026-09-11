# GPIO 验证域：配置与裁剪

<!-- FEATURE_META
id: FL.GPIO.CONFIG
name: 配置与裁剪
description: 配置与裁剪的可观察行为与验收证据
priority: must
req_ref:
- LRS.CFG.GPIO.PARAM.001
- LRS.CFG.GPIO.PARAM.002
- LRS.CFG.GPIO.PARAM.003
- LRS.CFG.GPIO.PARAM.004
- LRS.CFG.GPIO.PARAM.005
- LRS.CFG.GPIO.PARAM.006
- LRS.CFG.GPIO.PARAM.007
- LRS.CFG.GPIO.PARAM.008
- LRS.CFG.GPIO.PARAM.009
- LRS.CFG.GPIO.PARAM.010
- LRS.CFG.GPIO.PARAM.011
- LRS.CFG.GPIO.PARAM.012
- LRS.CFG.GPIO.PARAM.013
- LRS.CFG.GPIO.PARAM.014
- LRS.CFG.GPIO.PARAM.015
- LRS.CFG.GPIO.PARAM.016
- LRS.CFG.GPIO.PARAM.017
- LRS.CFG.GPIO.PARAM.018
- LRS.CFG.GPIO.PARAM.019
- LRS.CFG.GPIO.CFG001.001
- LRS.CFG.GPIO.CFG002.001
- LRS.CFG.GPIO.CFG003.001
design_ref:
- HLD.MOD.GPIO.TOP
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.CONFIG.001
name: gpio_config
type: boundary
description: 配置与裁剪
priority: must
tier: regression
implementation: verification/tc/tc_gpio_config.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.CONFIG
design_ref:
- LLD.MOD.GPIO.TOP
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 覆盖1/8/31/32/33/64/128引脚、能力混合、参数开关；遍历FEATURE/GEOMETRY、尾Bank与非法范围地址
expected_result:
- 由测试配置计算几何/能力和合法地址集合，裁剪地址保留且读0写忽略，非法实例拒绝
oracle: 由测试配置计算几何/能力和合法地址集合，裁剪地址保留且读0写忽略，非法实例拒绝
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：宽度×能力×可选功能×越界地址。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
