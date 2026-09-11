# GPIO 验证域：常开唤醒与命令

<!-- FEATURE_META
id: FL.GPIO.AON
name: 常开唤醒与命令
description: 常开唤醒与命令的可观察行为与验收证据
priority: must
req_ref:
- LRS.REG.GPIO.AONRESULT.006
- LRS.LP.GPIO.WAK001.001
- LRS.LP.GPIO.WAK001.002
- LRS.LP.GPIO.WAK001.003
- LRS.LP.GPIO.WAK002.001
- LRS.LP.GPIO.WAK002.002
- LRS.LP.GPIO.WAK003.001
- LRS.LP.GPIO.WAK004.001
- LRS.LP.GPIO.WAK004.002
- LRS.LP.GPIO.WAK005.001
- LRS.LP.GPIO.WAK005.002
- LRS.LP.GPIO.WAK005.003
- LRS.LP.GPIO.WAK006.001
- LRS.LP.GPIO.WAK007.001
- LRS.LP.GPIO.WAK007.002
- LRS.LP.GPIO.WAK007.003
- LRS.LP.GPIO.WAK008.001
- LRS.LP.GPIO.WAK008.002
- LRS.LP.GPIO.WAK009.001
- LRS.LP.GPIO.WAK009.002
- LRS.LP.GPIO.WAK010.001
- LRS.LP.GPIO.WAK010.002
- LRS.LP.GPIO.WAK010A.001
- LRS.LP.GPIO.WAK010A.002
- LRS.LP.GPIO.WAK011.001
- LRS.LP.GPIO.WAK012.001
- LRS.LP.GPIO.WAK012.002
design_ref:
- HLD.MOD.GPIO.AON
- HLD.MOD.GPIO.MAILBOX
- HLD.MOD.GPIO.REG
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.AON.001
name: gpio_aon
type: stress
description: 常开唤醒与命令
priority: must
tier: regression
implementation: verification/tc/tc_gpio_aon.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.AON
design_ref:
- LLD.MOD.GPIO.AON
- LLD.MOD.GPIO.MAILBOX
- LLD.MOD.GPIO.REG
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 异步时钟比2:3/3:7/7:2，相位偏移、停AON，COMMIT/SNAPSHOT/CLEAR/LOCK、锁定字段相同和改变、非法one-hot、超时迟到ACK；每握手阶段暖复位
expected_result:
- 独立AON域RM以接收命令编号记录执行次数，比较完整应答及活动配置；旧命令不重放，超时不释放槽；CLEAR置位优先
oracle: 独立AON域RM以接收命令编号记录执行次数，比较完整应答及活动配置；旧命令不重放，超时不释放槽；CLEAR置位优先
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：命令×时钟比×停钟×复位阶段×锁×超时。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
