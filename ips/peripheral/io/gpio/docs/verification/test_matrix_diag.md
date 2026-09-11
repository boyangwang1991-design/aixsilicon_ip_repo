# GPIO 验证域：物理回读诊断

<!-- FEATURE_META
id: FL.GPIO.DIAG
name: 物理回读诊断
description: 物理回读诊断的可观察行为与验收证据
priority: must
req_ref:
- LRS.SAFE.GPIO.DIAG001.001
- LRS.SAFE.GPIO.DIAG001.002
- LRS.SAFE.GPIO.DIAG002.001
- LRS.SAFE.GPIO.DIAG002.002
- LRS.SAFE.GPIO.DIAG002.003
- LRS.SAFE.GPIO.DIAG002.004
- LRS.SAFE.GPIO.DIAG003.001
- LRS.SAFE.GPIO.DIAG003.002
- LRS.SAFE.GPIO.DIAG004.001
- LRS.SAFE.GPIO.DIAG004.002
- LRS.SAFE.GPIO.DIAG007.001
- LRS.SAFE.GPIO.DIAG007.002
design_ref:
- HLD.MOD.GPIO.DIAG
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.DIAG.001
name: gpio_diag
type: error_injection
description: 物理回读诊断
priority: must
tier: regression
implementation: verification/tc/tc_gpio_diag.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.DIAG
design_ref:
- LLD.MOD.GPIO.DIAG
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 消隐阈值前后引入持续失配/恢复；safe/sleep/owned/available变化；开漏释放；TEST及清除同拍
expected_result:
- RM以输出变化时间与连续失配样本数计算诊断；无驱动不查；实时汇总不自动触发safe
oracle: RM以输出变化时间与连续失配样本数计算诊断；无驱动不查；实时汇总不自动触发safe
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：驱动状态×消隐边界×失配长度×W1C。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
