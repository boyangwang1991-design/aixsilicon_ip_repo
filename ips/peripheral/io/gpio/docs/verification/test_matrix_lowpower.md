# GPIO 验证域：休眠和安全覆盖

<!-- FEATURE_META
id: FL.GPIO.LOWPOWER
name: 休眠和安全覆盖
description: 休眠和安全覆盖的可观察行为与验收证据
priority: must
req_ref:
- LRS.LP.GPIO.LP001.001
- LRS.LP.GPIO.LP001.002
- LRS.LP.GPIO.LP001.003
- LRS.LP.GPIO.LP002.001
- LRS.LP.GPIO.LP003.001
- LRS.LP.GPIO.LP003.002
- LRS.LP.GPIO.LP003.003
- LRS.LP.GPIO.LP004.001
- LRS.LP.GPIO.LP004.002
- LRS.LP.GPIO.LP005.001
- LRS.LP.GPIO.LP005.002
- LRS.LP.GPIO.LP006.001
- LRS.LP.GPIO.LP006.002
design_ref:
- HLD.MOD.GPIO.OUTPUT
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.LOWPOWER.001
name: gpio_lowpower
type: low_power
description: 休眠和安全覆盖
priority: must
tier: regression
implementation: verification/tc/tc_gpio_lowpower.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.LOWPOWER
design_ref:
- LLD.MOD.GPIO.OUTPUT
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- sleep进入同拍OUT写，保持/强低/强高/高阻，期间更新OUT，safe进入解除，短暂停主时钟
expected_result:
- RM捕获进入前物理输出；优先级reset/safe/sleep/normal；拥有权始终门控；断钟已锁存值保持
oracle: RM捕获进入前物理输出；优先级reset/safe/sleep/normal；拥有权始终门控；断钟已锁存值保持
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：模式×同拍写×safe×owned×停钟。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
