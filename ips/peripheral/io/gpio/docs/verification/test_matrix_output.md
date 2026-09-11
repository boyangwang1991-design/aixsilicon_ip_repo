# GPIO 验证域：输出原子更新

<!-- FEATURE_META
id: FL.GPIO.OUTPUT
name: 输出原子更新
description: 输出原子更新的可观察行为与验收证据
priority: must
req_ref:
- LRS.FUNC.GPIO.OUT001.001
- LRS.FUNC.GPIO.OUT001.002
- LRS.FUNC.GPIO.OUT002.001
- LRS.FUNC.GPIO.OUT002.002
- LRS.FUNC.GPIO.OUT002.003
- LRS.FUNC.GPIO.OUT003.001
- LRS.FUNC.GPIO.OUT004.001
- LRS.FUNC.GPIO.OUT004.002
- LRS.FUNC.GPIO.OUT005.001
- LRS.FUNC.GPIO.OUT005.002
- LRS.FUNC.GPIO.OUT005.003
- LRS.FUNC.GPIO.OUT006.001
- LRS.FUNC.GPIO.OUT006.002
- LRS.FUNC.GPIO.OUT007.001
design_ref:
- HLD.MOD.GPIO.OUTPUT
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.OUTPUT.001
name: gpio_output
type: random
description: 输出原子更新
priority: must
tier: regression
implementation: verification/tc/tc_gpio_output.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.OUTPUT
design_ref:
- LLD.MOD.GPIO.OUTPUT
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 随机数据/字节/半字掩码，全部OUT/OE别名，尾Bank，开漏/反相，OE开关时修改模式
expected_result:
- 位集合操作参考模型计算正常锁存与物理输出，错误不改变状态；单次Access沿更新
oracle: 位集合操作参考模型计算正常锁存与物理输出，错误不改变状态；单次Access沿更新
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：原子操作×mask边界×能力×拥有权×开漏×反相。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
