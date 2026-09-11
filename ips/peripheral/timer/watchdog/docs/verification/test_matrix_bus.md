# APB4与寄存器访问：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.BUS.001
name: bus
type: register
description: APB4与寄存器访问
priority: must
tier: smoke
proof_kind: uvm
implementation: verification/tc/tc_bus.sv
feature_ref:
- FL.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.PORTS.001
- LRS.REG.WATCHDOG.ACCESS.001
- LRS.REG.WATCHDOG.IDENTITY.001
design_ref:
- LLD.MOD.WATCHDOG.BUS
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- POR后读ID/能力；逐个实现地址执行访问属性检查；随机读PSTRB；写部分strobes、未对齐、RO、越界与保留位；保持ACCESS直到完成。
expected_result:
- 独立APB monitor计数每笔只接受一次；ACCESS最多2周期；拒绝返回PSLVERR且无状态修改；读WO及保留位为零。
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

Checker：独立APB monitor计数每笔只接受一次；ACCESS最多2周期；拒绝返回PSLVERR且无状态修改；读WO及保留位为零。

覆盖采样：读写×地址类别×strobes×权限×等待周期；错误访问与邮箱忙同拍。
