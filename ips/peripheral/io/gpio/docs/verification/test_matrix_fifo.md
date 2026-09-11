# GPIO 验证域：事件队列与时间戳

<!-- FEATURE_META
id: FL.GPIO.FIFO
name: 事件队列与时间戳
description: 事件队列与时间戳的可观察行为与验收证据
priority: must
req_ref:
- LRS.FUNC.GPIO.EVT001.001
- LRS.FUNC.GPIO.EVT001.002
- LRS.FUNC.GPIO.EVT002.001
- LRS.FUNC.GPIO.EVT003.001
- LRS.FUNC.GPIO.EVT003.002
- LRS.FUNC.GPIO.EVT004.001
- LRS.FUNC.GPIO.EVT004.002
- LRS.FUNC.GPIO.EVT004.003
- LRS.FUNC.GPIO.EVT005.001
- LRS.FUNC.GPIO.EVT005.002
- LRS.FUNC.GPIO.EVT005.003
- LRS.FUNC.GPIO.EVT006.001
- LRS.FUNC.GPIO.EVT006.002
- LRS.FUNC.GPIO.EVT007.001
- LRS.FUNC.GPIO.EVT007.002
- LRS.FUNC.GPIO.EVT007.003
- LRS.REG.GPIO.LOST.005
design_ref:
- HLD.MOD.GPIO.FIFO
- HLD.MOD.GPIO.REG
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.FIFO.001
name: gpio_fifo
type: stress
description: 事件队列与时间戳
priority: must
tier: regression
implementation: verification/tc/tc_gpio_fifo.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.FIFO
design_ref:
- LLD.MOD.GPIO.FIFO
- LLD.MOD.GPIO.REG
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 同拍多引脚事件，空/满POP+PUSH，FLUSH冲突，CLEAR_LOST竞争，LOST饱和，分离HEAD读取与DMA显式POP
expected_result:
- RM用无界事件列表加容量规则计算队列；排序选择最小pin，按未入队数量计丢失；四字HEAD不消费，时间戳匹配event周期
oracle: RM用无界事件列表加容量规则计算队列；排序选择最小pin，按未入队数量计丢失；四字HEAD不消费，时间戳匹配event周期
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：占用×POP×事件数×FLUSH×CLEAR_LOST×水位。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
