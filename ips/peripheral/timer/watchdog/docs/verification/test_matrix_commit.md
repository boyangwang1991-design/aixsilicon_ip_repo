# 配置原子提交与生效：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.COMMIT.001
name: commit
type: negative
description: 配置原子提交与生效
priority: must
tier: regression
proof_kind: uvm
implementation: verification/tc/tc_commit.sv
feature_ref:
- FL.WATCHDOG.COMMIT
req_ref:
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.007
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
- LRS.CONS.WATCHDOG.VER.005
design_ref:
- LLD.MOD.WATCHDOG.CHANNEL
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 多字阈值分步staging写；完整客户端表；非法模式/高位/mask/策略；RUN只改四类计时字段；pending后二次提交；旧窗口服务与故障边界。
expected_result:
- 独立配置验证规则生成预期错误；失败整组不变；成功提交按状态立即或旧配置成功刷新时整体生效；无混合阈值；故障丢弃pending。
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

Checker：独立配置验证规则生成预期错误；失败整组不变；成功提交按状态立即或旧配置成功刷新时整体生效；无混合阈值；故障丢弃pending。

覆盖采样：配置状态×合法性×锁×pending×版本；UNSUPPORTED与BAD_CONFIG优先级。
