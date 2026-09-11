# 线性流程与独立期限：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.FLOW.001
name: flow
type: boundary
description: 线性流程与独立期限
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_flow.sv
feature_ref:
- FL.WATCHDOG.FLOW
req_ref:
- LRS.FUNC.WATCHDOG.SUP.007
- LRS.FUNC.WATCHDOG.SUP.008
- LRS.FUNC.WATCHDOG.SUP.009
- LRS.FUNC.WATCHDOG.SUP.010
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- START/STEP/END完整流程，跳步倒序重复及未开始END；多客户端交错；DEADLINE_MIN/MAX边界、暂停和主TIMEOUT先后。
expected_result:
- 独立预期检查点列表与绝对WDT时间戳检查顺序；END满足MIN≤elapsed<MAX及主窗口才完成；先到期限优先且同拍原因全保留。
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

Checker：独立预期检查点列表与绝对WDT时间戳检查顺序；END满足MIN≤elapsed<MAX及主窗口才完成；先到期限优先且同拍原因全保留。

覆盖采样：step首/中/末×错误类别×deadline边界×主窗口。
