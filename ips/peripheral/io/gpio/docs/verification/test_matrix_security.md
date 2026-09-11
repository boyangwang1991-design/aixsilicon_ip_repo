# GPIO 验证域：锁与访问策略

<!-- FEATURE_META
id: FL.GPIO.SECURITY
name: 锁与访问策略
description: 锁与访问策略的可观察行为与验收证据
priority: must
req_ref:
- LRS.SEC.GPIO.SEC001.001
- LRS.SEC.GPIO.SEC002.001
- LRS.SEC.GPIO.SEC002.002
- LRS.SEC.GPIO.SEC002A.001
- LRS.SEC.GPIO.SEC002A.002
- LRS.SEC.GPIO.SEC002A.003
- LRS.SEC.GPIO.SEC003.001
- LRS.SEC.GPIO.SEC003.002
- LRS.SEC.GPIO.SEC004.001
- LRS.SEC.GPIO.SEC005.001
- LRS.SEC.GPIO.SEC005.002
- LRS.SEC.GPIO.SEC006.001
- LRS.SEC.GPIO.SEC006.002
design_ref:
- HLD.MOD.GPIO.SECURITY
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

<!-- TESTCASE_META
id: TC.GPIO.SECURITY.001
name: gpio_security
type: negative
description: 锁与访问策略
priority: must
tier: regression
implementation: verification/tc/tc_gpio_security.sv
proof_kind: uvm
feature_ref:
- FL.GPIO.SECURITY
design_ref:
- LLD.MOD.GPIO.SECURITY
preconditions:
- 冷复位及同步释放完成；按本用例建立初始状态
stimulus:
- 遍历每个被保护写入口，混合锁定位、相同值写、空mask，降低策略后再写锁，暖复位再访问
expected_result:
- 表驱动权限/目标集合判断整笔接受或拒绝；POR前锁单调，暖复位策略保持，GLOBAL豁免符合合同
oracle: 表驱动权限/目标集合判断整笔接受或拒绝；POR前锁单调，暖复位策略保持，GLOBAL豁免符合合同
timeout_policy: 40000000主周期及120秒独立watchdog，超时失败
seeds:
- 1
- 17
- 101
param_config: CFG_BASE
applicability:
  expr: 'true'
END_TESTCASE_META -->

覆盖交叉：锁种类×别名×mask×权限×暖复位。每项断言失败记录cycle、pin/Bank、事务及期望/实际值。
