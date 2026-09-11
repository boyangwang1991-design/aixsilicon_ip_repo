# 诊断测试和中断路径：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.DFX.001
name: dfx
type: directed
description: 诊断测试和中断路径
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_dfx.sv
feature_ref:
- FL.WATCHDOG.DFX
req_ref:
- LRS.DFX.WATCHDOG.TST.001
- LRS.DFX.WATCHDOG.TST.002
- LRS.DFX.WATCHDOG.TST.003
- LRS.DFX.WATCHDOG.TST.004
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- IRQ_TEST与IRQ_ENABLE/W1C；短期限超时自检；注入使能/权限/锁/解锁条件；TEST_CONTEXT在同拍FIRST捕获；生产裁剪。
expected_result:
- IRQ_TEST仅置专用位，不喂狗也不证明超时比较；测试故障走真实请求；TEST_CONTEXT正确；生产未支持访问拒绝且无副作用。
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

Checker：IRQ_TEST仅置专用位，不喂狗也不证明超时比较；测试故障走真实请求；TEST_CONTEXT正确；生产未支持访问拒绝且无副作用。

覆盖采样：测试类别×授权×实例×IRQ屏蔽；真实故障与测试并发。
