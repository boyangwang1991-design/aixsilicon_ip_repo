# 多客户端组监督：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.GROUP.001
name: group
type: boundary
description: 多客户端组监督
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_group.sv
feature_ref:
- FL.WATCHDOG.GROUP
req_ref:
- LRS.FUNC.WATCHDOG.SUP.001
- LRS.FUNC.WATCHDOG.SUP.002
- LRS.FUNC.WATCHDOG.SUP.003
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 不同source/client报到；未要求客户端、早到、重复、最后必需客户端；多个通道不同timeout并发。
expected_result:
- 集合oracle仅接受当前轮合法成员；最后成员才刷新；重复不换token；超时missing=REQUIRE_MASK减已见集合；其他通道独立计时。
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

Checker：集合oracle仅接受当前轮合法成员；最后成员才刷新；重复不换token；超时missing=REQUIRE_MASK减已见集合；其他通道独立计时。

覆盖采样：客户端首/末×重复×窗口；require稀疏/全置位。
