# 复位分域与外部假设：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.RESET.001
name: reset
type: reset
description: 复位分域与外部假设
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_reset.sv
feature_ref:
- FL.WATCHDOG.RESET
req_ref:
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.004
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- POR异步断言不同相位释放；preset在各APB/mailbox阶段；pclk停止后故障/唤醒；同步释放2/3/4；初始化期注入及释放后注入。
expected_result:
- POR才清留痕；preset仅接口镜像复位并重同步IRQ；安全输出不依赖pclk；初始化诊断屏蔽不超过SYNC_STAGES+2；裸异步输入由集成规则拒绝。
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

Checker：POR才清留痕；preset仅接口镜像复位并重同步IRQ；安全输出不依赖pclk；初始化诊断屏蔽不超过SYNC_STAGES+2；裸异步输入由集成规则拒绝。

覆盖采样：复位域×握手阶段×安全状态×时钟停止；外部停钟/失电责任单独审阅。
