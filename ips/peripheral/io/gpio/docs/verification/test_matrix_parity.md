# GPIO 验证域：Parity与安全锁存

<!-- FEATURE_META
id: FL.GPIO.PARITY
name: Parity与安全锁存
description: Parity与安全锁存的可观察行为与验收证据
priority: must
req_ref:
- LRS.SAFE.GPIO.DIAG005.001
- LRS.SAFE.GPIO.DIAG005.002
- LRS.SAFE.GPIO.DIAG006.001
design_ref:
- HLD.MOD.GPIO.DIAG
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.PARITY.001
name: gpio_parity
type: error_injection
description: Parity与安全锁存
priority: must
tier: regression
implementation: verification/tc/tc_gpio_parity.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.PARITY
design_ref:
- LLD.MOD.GPIO.DIAG
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- CFG_FULL128下部分写后注入每Bank OUT_DATA校验位；检测前后暖复位、非法权限和GLOBAL_LOCK注入
expected_result:
- 独立偶校验函数核对受保护完整字；注入不改数据，一主周期内安全请求锁存至POR
oracle: 独立偶校验函数核对受保护完整字；注入不改数据，一主周期内安全请求锁存至POR
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_FULL128
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：Bank×部分写×注入权限×暖复位×安全输出。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
