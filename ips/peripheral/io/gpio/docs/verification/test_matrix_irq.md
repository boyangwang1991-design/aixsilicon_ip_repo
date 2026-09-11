# GPIO 验证域：中断与方向事件

<!-- FEATURE_META
id: FL.GPIO.IRQ
name: 中断与方向事件
description: 中断与方向事件的可观察行为与验收证据
priority: must
req_ref:
- LRS.FUNC.GPIO.IRQ001.001
- LRS.FUNC.GPIO.IRQ002.001
- LRS.FUNC.GPIO.IRQ002.002
- LRS.FUNC.GPIO.IRQ003.001
- LRS.FUNC.GPIO.IRQ003.002
- LRS.FUNC.GPIO.IRQ004.001
- LRS.FUNC.GPIO.IRQ005.001
- LRS.FUNC.GPIO.IRQ006.001
- LRS.FUNC.GPIO.IRQ007.001
- LRS.FUNC.GPIO.IRQ007.002
- LRS.FUNC.GPIO.IRQ008.001
- LRS.FUNC.GPIO.IRQ008.002
- LRS.FUNC.GPIO.IRQ008.003
- LRS.FUNC.GPIO.IRQ009.001
- LRS.FUNC.GPIO.IRQ009.002
design_ref:
- HLD.MOD.GPIO.IRQ
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.IRQ.001
name: gpio_irq
type: directed
description: 中断与方向事件
priority: must
tier: regression
implementation: verification/tc/tc_gpio_irq.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.IRQ
design_ref:
- LLD.MOD.GPIO.IRQ
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 所有模式/分组/DETECT/ENABLE组合；持续电平清除、边沿同拍W1C、TEST、重配相同MODE、仅GROUP变化
expected_result:
- RM基于可观察有效输入的历史事件集合计算Pending/方向/路由；TEST及电平不产生FIFO事件
oracle: RM基于可观察有效输入的历史事件集合计算Pending/方向/路由；TEST及电平不产生FIFO事件
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：模式×有效性×DETECT×ENABLE×清除竞争×分组。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
