# 独立数字诊断链：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.SAFETY.001
name: safety
type: error_injection
description: 独立数字诊断链
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_safety.sv
feature_ref:
- FL.WATCHDOG.SAFETY
req_ref:
- LRS.PERF.WATCHDOG.SAFETY.001
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
design_ref:
- LLD.MOD.WATCHDOG.SAFETY
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 六种受控注入及独立故障活动：主/影子计数、分频/tick、阈值/锁/状态、完整服务资格、到期比较、final保持；覆盖RUN/PAUSED/恢复。
expected_result:
- 注入必须经过真实检测路径；从可观测边沿起≤2WDT周期告警/最终保持；共享错误不可使两路同时刷新；最终保持不依赖普通状态选择；另做综合网表独立性检查。
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

Checker：注入必须经过真实检测路径；从可观测边沿起≤2WDT周期告警/最终保持；共享错误不可使两路同时刷新；最终保持不依赖普通状态选择；另做综合网表独立性检查。

覆盖采样：故障位置×状态×诊断授权×锁×检测延迟；未激活/共因明确不计覆盖。
