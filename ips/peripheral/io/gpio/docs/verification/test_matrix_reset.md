# GPIO 验证域：复位矩阵

<!-- FEATURE_META
id: FL.GPIO.RESET
name: 复位矩阵
description: 复位矩阵的可观察行为与验收证据
priority: must
req_ref:
- LRS.FUNC.GPIO.RACE.001
- LRS.FUNC.GPIO.RACE.002
- LRS.FUNC.GPIO.RACE.003
- LRS.FUNC.GPIO.RACE.004
- LRS.FUNC.GPIO.RACE.005
- LRS.FUNC.GPIO.RACE.006
- LRS.FUNC.GPIO.RACE.007
- LRS.FUNC.GPIO.RACE.008
- LRS.FUNC.GPIO.RACE.009
- LRS.FUNC.GPIO.RACE.010
- LRS.REG.GPIO.DEFAULT.007
- LRS.RESET.GPIO.STATE.001
- LRS.RESET.GPIO.STATE.002
- LRS.RESET.GPIO.STATE.003
- LRS.RESET.GPIO.STATE.004
- LRS.RESET.GPIO.STATE.005
- LRS.RESET.GPIO.STATE.006
design_ref:
- HLD.MOD.GPIO.REG
- HLD.MOD.GPIO.TOP
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.RESET.001
name: gpio_reset
type: reset
description: 复位矩阵
priority: must
tier: regression
implementation: verification/tc/tc_gpio_reset.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.RESET
design_ref:
- LLD.MOD.GPIO.REG
- LLD.MOD.GPIO.TOP
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- POR/主暖复位穿插非零配置、Pending、FIFO、Strap、sleep、锁和AON outstanding；同步复位APB上游
expected_result:
- 按合同状态复位表检查每个状态，主状态恢复默认，锁/策略/parity/AON保持；复位内无业务完成
oracle: 按合同状态复位表检查每个状态，主状态恢复默认，锁/策略/parity/AON保持；复位内无业务完成
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：复位种类×状态类别×事务阶段。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
