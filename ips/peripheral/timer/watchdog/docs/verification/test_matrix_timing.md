# 计时窗口与周期优先级：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.TIMING.001
name: timing
type: random
description: 计时窗口与周期优先级
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_timing.sv
feature_ref:
- FL.WATCHDOG.TIMING
req_ref:
- LRS.CFG.WATCHDOG.PAR.003
- LRS.FUNC.WATCHDOG.TIM.001
- LRS.FUNC.WATCHDOG.TIM.002
- LRS.FUNC.WATCHDOG.TIM.003
- LRS.FUNC.WATCHDOG.TIM.004
- LRS.FUNC.WATCHDOG.TIM.005
- LRS.FUNC.WATCHDOG.TIM.006
- LRS.PERF.WATCHDOG.TIME.001
- LRS.CONS.WATCHDOG.NFR.004
- LRS.CONS.WATCHDOG.VER.001
- LRS.CONS.WATCHDOG.VER.002
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 选择P=0/1/最大代表，短TIMEOUT；服务落WIN_MIN-1/WIN_MIN/TIMEOUT-1/TIMEOUT；PRETIMEOUT同拍服务；C/D饱和与多通道并行。
expected_result:
- oracle以周期起点绝对时间推算floor(elapsed/(P+1))，不读取RTL计数作为期望；timeout精确TIMEOUT*(P+1)；成功服务抑制当拍新预警。
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

Checker：oracle以周期起点绝对时间推算floor(elapsed/(P+1))，不读取RTL计数作为期望；timeout精确TIMEOUT*(P+1)；成功服务抑制当拍新预警。

覆盖采样：tick×窗口边界×预警×服务；宽度与分频端点。
