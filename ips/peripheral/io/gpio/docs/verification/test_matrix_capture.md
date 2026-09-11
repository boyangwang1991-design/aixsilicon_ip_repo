# GPIO 验证域：快照与Strap

<!-- FEATURE_META
id: FL.GPIO.CAPTURE
name: 快照与Strap
description: 快照与Strap的可观察行为与验收证据
priority: must
req_ref:
- LRS.FUNC.GPIO.CAP001.001
- LRS.FUNC.GPIO.CAP001.002
- LRS.FUNC.GPIO.CAP002.001
- LRS.FUNC.GPIO.CAP002.002
- LRS.FUNC.GPIO.CAP003.001
- LRS.FUNC.GPIO.CAP003.002
design_ref:
- HLD.MOD.GPIO.CAPTURE
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.CAPTURE.001
name: gpio_capture
type: boundary
description: 快照与Strap
priority: must
tier: regression
implementation: verification/tc/tc_gpio_capture.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.CAPTURE
design_ref:
- LLD.MOD.GPIO.CAPTURE
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 同拍软硬快照、跨Bank更新、连续覆盖、SEQ回绕；Strap过早、首次、重复、零输入能力和暖复位
expected_result:
- RM从沿前输入快照捕获全向量，SEQ单增；Strap使用物理同步值且只接受第一次全部就绪请求
oracle: RM从沿前输入快照捕获全向量，SEQ单增；Strap使用物理同步值且只接受第一次全部就绪请求
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：触发源×有效向量×序号边界×Strap时机。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
