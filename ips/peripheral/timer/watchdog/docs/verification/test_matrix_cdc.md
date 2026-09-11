# 单在途邮箱与跨域：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.CDC.001
name: cdc
type: stress
description: 单在途邮箱与跨域
priority: must
tier: extended
proof_kind: uvm
implementation: verification/tc/tc_cdc.sv
feature_ref:
- FL.WATCHDOG.CDC
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.CONS.WATCHDOG.NFR.002
- LRS.CONS.WATCHDOG.VER.004
design_ref:
- LLD.MOD.WATCHDOG.TRANSPORT
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 两时钟相位扫描、源快/目的快、停WDT后读状态；邮箱忙时重复写；请求经过每一级同步时施加preset或warm；序号回卷。
expected_result:
- 事务队列以APB接受事件建账；EXEC或CANCEL恰一次且序号对应；preset不重发；warm取消未执行者；停WDT仍可读APB；负载全程稳定。
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

Checker：事务队列以APB接受事件建账；EXEC或CANCEL恰一次且序号对应；preset不重发；warm取消未执行者；停WDT仍可读APB；负载全程稳定。

覆盖采样：同步级数×时钟比×复位相位×忙/完成；取消边界前/当拍/后一拍。
