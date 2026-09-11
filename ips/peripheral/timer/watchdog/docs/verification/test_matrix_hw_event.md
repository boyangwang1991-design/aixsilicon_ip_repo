# 硬件服务与公平仲裁：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.HW_EVENT.001
name: hw_event
type: stress
description: 硬件服务与公平仲裁
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_hw_event.sv
feature_ref:
- FL.WATCHDOG.HW_EVENT
req_ref:
- LRS.INTF.WATCHDOG.IF.003
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.PERF.WATCHDOG.COMMAND.001
- LRS.CONS.WATCHDOG.NFR.003
design_ref:
- LLD.MOD.WATCHDOG.DISPATCH
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 软件/硬件路径各运行；持续硬件valid与邮箱竞争；valid等待期间跨过窗口边界；warm取消时保持硬件事件；未支持配置访问。
expected_result:
- 轮询事务模型每WDT边沿最多消费一个；硬件ready前保持；以执行边沿判窗口；未消费不推进仲裁；可见命令无竞争≤2、有竞争≤3周期。
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

Checker：轮询事务模型每WDT边沿最多消费一个；硬件ready前保持；以执行边沿判窗口；未消费不推进仲裁；可见命令无竞争≤2、有竞争≤3周期。

覆盖采样：请求组合×轮询顺序×取消窗口×通道；硬件能力开/关。
