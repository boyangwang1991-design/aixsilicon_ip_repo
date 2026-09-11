# 局部恢复与暖复位：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.RECOVERY.001
name: recovery
type: reset
description: 局部恢复与暖复位
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_recovery.sv
feature_ref:
- FL.WATCHDOG.RECOVERY
req_ref:
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- recovery_done在无请求/局部请求/最终边界，保持done跨下一次故障；预算0/1/255；warm在RUN/FAULT/RESET_PENDING/DISABLED。
expected_result:
- 只有合格实际恢复一次被接受；ack保持到done低；恢复清本轮、保留配置锁历史；预算超限立即最终；warm仅重启原活动通道。
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

Checker：只有合格实际恢复一次被接受；ack保持到done低；恢复清本轮、保留配置锁历史；预算超限立即最终；warm仅重启原活动通道。

覆盖采样：done阶段×最终边界×预算×BOOT；warm与新致命故障同拍。
