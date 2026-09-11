# GPIO 验证域：APB事务与错误

<!-- FEATURE_META
id: FL.GPIO.APB
name: APB事务与错误
description: APB事务与错误的可观察行为与验收证据
priority: must
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
- LRS.REG.GPIO.BUS006.001
- LRS.REG.GPIO.BUS006.002
- LRS.REG.GPIO.MAP.001
- LRS.REG.GPIO.IDENTITY.002
- LRS.REG.GPIO.FAULT.003
- LRS.REG.GPIO.FIRST.004
design_ref:
- HLD.MOD.GPIO.APB
- HLD.MOD.GPIO.REG
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.APB.001
name: gpio_apb
type: register
description: APB事务与错误
priority: must
tier: smoke
implementation: verification/tc/tc_gpio_apb.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.APB
design_ref:
- LLD.MOD.GPIO.APB
- LLD.MOD.GPIO.REG
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 遍历16种PSTRB、8种PPROT、Setup停留、背靠背、未对齐、RO写、WO读、保留位、非法字段、命令零写
expected_result:
- 独立事务规则表判定错误；完成沿前读值、错误业务状态快照不变；首错误记录符合清除/新错误竞争
oracle: 独立事务规则表判定错误；完成沿前读值、错误业务状态快照不变；首错误记录符合清除/新错误竞争
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：方向×PSTRB×权限×地址类别×错误原因。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
