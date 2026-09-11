# 软件集成与实现签核：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.DELIVERY.001
name: delivery
type: static
description: 软件集成与实现签核
priority: must
tier: extended
proof_kind: static
implementation: scripts/check_delivery.py
feature_ref:
- FL.WATCHDOG.DELIVERY
req_ref:
- LRS.DFX.WATCHDOG.TST.005
- LRS.CONS.WATCHDOG.NFR.001
- LRS.CONS.WATCHDOG.NFR.005
- LRS.CONS.WATCHDOG.NFR.006
- LRS.CONS.WATCHDOG.VER.006
- LRS.CONS.WATCHDOG.DELIVERY.001
- LRS.CONS.WATCHDOG.SOFTWARE.001
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 编译并执行C驱动mock总线错误/序号/互斥测试；比对RDL派生视图；SpyGlass lint/CDC/RDC；28nm三档DC/PPA和冗余网表检查；逐项交付链接检查。
expected_result:
- 软件超时不盲重发且只接收匹配DONE_SEQ；派生一致；静态零未处置错误/锁存/环；真实库映射及时序报告；安全说明列明未覆盖项且无无据认证。
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

聚合入口的每项子命令独立保留退出码和原始报告，不以文件存在代替工具通过。

Checker：软件超时不盲重发且只接收匹配DONE_SEQ；派生一致；静态零未处置错误/锁存/环；真实库映射及时序报告；安全说明列明未覆盖项且无无据认证。

覆盖采样：三个产品档×交付视图；所有静态/软件子检查必须分别有命令与原始结果。
