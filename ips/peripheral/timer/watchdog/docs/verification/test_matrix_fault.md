# 故障记录与升级：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.FAULT.001
name: fault
type: error_injection
description: 故障记录与升级
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_fault.sv
feature_ref:
- FL.WATCHDOG.FAULT
req_ref:
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.FUNC.WATCHDOG.FLT.001
- LRS.FUNC.WATCHDOG.FLT.002
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
- LRS.CONS.WATCHDOG.VER.003
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 触发每类非致命及致命原因、同拍多原因；LOCAL_DELAY=0及FINAL_DELAY边界；FAULT期间服务/清IRQ/重复错误；FIRST与COUNT选择清除。
expected_result:
- 故障边沿保存旧状态/配置及候选年龄；主原因独立优先表；E用未分频绝对周期；最终保持；W1C不能清活动请求；FIRST首次锁存与set优先。
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

Checker：故障边沿保存旧状态/配置及候选年龄；主原因独立优先表；E用未分频绝对周期；最终保持；W1C不能清活动请求；FIRST首次锁存与set优先。

覆盖采样：故障位×策略×响应模式×清除；FIRST有效×多原因×计数饱和。
