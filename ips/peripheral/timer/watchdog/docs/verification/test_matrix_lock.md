# 权限解锁和只置位锁：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.LOCK.001
name: lock
type: negative
description: 权限解锁和只置位锁
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_lock.sv
feature_ref:
- FL.WATCHDOG.LOCK
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.SEC.WATCHDOG.AUTH.001
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 逐类权限拒绝；双解锁同源/异源；第二笔32周期边界与额度64周期；错误敏感命令消耗额度；四把锁及硬锁；warm/preset后查询。
expected_result:
- 可信侧带捕获后不随引脚变化；额度一次性；所有拒绝无喂狗；锁只能规定置位/POR清除；暂停与故障不能绕过。
timeout_policy: 仿真10ms/1000000 WDT边沿，进程600秒；静态每配置1800秒，超时失败
config_ref:
- CFGSET.WATCHDOG.STANDARD
- CFGSET.WATCHDOG.SAFETY
- CFGSET.WATCHDOG.SUPERVISOR
- CFGSET.WATCHDOG.PC_MATRIX
applicability:
  expr: 'true'
END_TESTCASE_META -->

各子场景以独立scenario名称记录运行配置、seed、刺激、预期与实际；任一子场景失败则整个TC失败。

UVM factory注册类名必须等于文件名stem；不得以空run_phase或调用只有打印PASS的任务充当执行。

Checker：可信侧带捕获后不随引脚变化；额度一次性；所有拒绝无喂狗；锁只能规定置位/POR清除；暂停与故障不能绕过。

覆盖采样：权限×命令×状态×信用年龄；同拍锁与后续命令。
