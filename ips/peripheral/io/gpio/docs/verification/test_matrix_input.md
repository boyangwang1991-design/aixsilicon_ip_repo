# GPIO 验证域：输入有效性

<!-- FEATURE_META
id: FL.GPIO.INPUT
name: 输入有效性
description: 输入有效性的可观察行为与验收证据
priority: must
req_ref:
- LRS.FUNC.GPIO.IN001.001
- LRS.FUNC.GPIO.IN002.001
- LRS.FUNC.GPIO.IN002.002
- LRS.FUNC.GPIO.IN003.001
- LRS.FUNC.GPIO.IN004.001
- LRS.FUNC.GPIO.IN005.001
design_ref:
- HLD.MOD.GPIO.INPUT
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.INPUT.001
name: gpio_input
type: directed
description: 输入有效性
priority: must
tier: regression
implementation: verification/tc/tc_gpio_input.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.INPUT
design_ref:
- LLD.MOD.GPIO.INPUT
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 输入在时钟不同相位翻转，初始高低，撤销并恢复available/IN_ENABLE，输入反相及输出同时采样
expected_result:
- RM按样本队列计算同步填充；前提失效即无效/读0，首次有效建立基线且无伪边沿
oracle: RM按样本队列计算同步填充；前提失效即无效/读0，首次有效建立基线且无伪边沿
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：初始值×相位×同步深度×有效性原因。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
