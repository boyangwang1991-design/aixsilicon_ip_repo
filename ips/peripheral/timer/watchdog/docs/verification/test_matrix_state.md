# 启动停止与启动期：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.STATE.001
name: state
type: directed
description: 启动停止与启动期
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_state.sv
feature_ref:
- FL.WATCHDOG.STATE
req_ref:
- LRS.FUNC.WATCHDOG.STA.001
- LRS.FUNC.WATCHDOG.STA.002
- LRS.FUNC.WATCHDOG.STA.003
- LRS.FUNC.WATCHDOG.STA.004
- LRS.FUNC.WATCHDOG.STA.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- AUTO_START与手动START；BOOT开启/关闭；BOOT首次完整服务；重复START；STOP在各状态、NO_STOP/ENABLE_LOCK开关；pclk停止自动启动。
expected_result:
- 启动边沿年龄/相位置零；BOOT只有一次宽限；非法START/STOP不重置监督；STOP仅授权解锁且允许状态成功；保留历史与锁。
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

Checker：启动边沿年龄/相位置零；BOOT只有一次宽限；非法START/STOP不重置监督；STOP仅授权解锁且允许状态成功；保留历史与锁。

覆盖采样：控制状态×命令×锁；POR与首个可用WDT边沿。
