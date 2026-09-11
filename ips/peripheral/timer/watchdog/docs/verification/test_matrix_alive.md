# 固定周期存活监督：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.ALIVE.001
name: alive
type: boundary
description: 固定周期存活监督
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_alive.sv
feature_ref:
- FL.WATCHDOG.ALIVE
req_ref:
- LRS.FUNC.WATCHDOG.SUP.004
- LRS.FUNC.WATCHDOG.SUP.005
- LRS.FUNC.WATCHDOG.SUP.006
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- MIN/MAX事件计数边界与溢出；TIMEOUT当拍服务；BOOT首周期；PRETIMEOUT时部分客户端欠报；持续高速报到。
expected_result:
- 按固定边沿窗口分桶，边界先评价旧桶；合格自动换周期；边界事件返回EPOCH_BOUNDARY且不计入；欠报/过报准确记录。
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

Checker：按固定边沿窗口分桶，边界先评价旧桶；合格自动换周期；边界事件返回EPOCH_BOUNDARY且不计入；欠报/过报准确记录。

覆盖采样：计数MIN-1/MIN/MAX/MAX+1×边界事件×BOOT/RUN；饱和。
