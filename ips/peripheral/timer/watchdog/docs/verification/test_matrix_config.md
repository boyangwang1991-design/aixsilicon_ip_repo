# 构建参数与能力：执行方案

<!-- TESTCASE_META
id: TC.WATCHDOG.CONFIG.001
name: config
type: static
description: 构建参数与能力
priority: must
tier: extended
proof_kind: static
implementation: scripts/run_parameter_verification.py
feature_ref:
- FL.WATCHDOG.CONFIG
req_ref:
- LRS.CFG.WATCHDOG.NUM_CHANNELS.001
- LRS.CFG.WATCHDOG.COUNTER_WIDTH.001
- LRS.CFG.WATCHDOG.PRESCALE_WIDTH.001
- LRS.CFG.WATCHDOG.NUM_CLIENTS.001
- LRS.CFG.WATCHDOG.SOURCE_WIDTH.001
- LRS.CFG.WATCHDOG.SYNC_STAGES.001
- LRS.CFG.WATCHDOG.SUPPORT_TOKEN_QA.001
- LRS.CFG.WATCHDOG.SUPPORT_SUPERVISION.001
- LRS.CFG.WATCHDOG.SUPPORT_HW_EVENT.001
- LRS.CFG.WATCHDOG.SAFETY_EN.001
- LRS.CFG.WATCHDOG.ALLOW_RUNTIME_UPDATE.001
- LRS.CFG.WATCHDOG.DIAG_INJECT_EN.001
- LRS.CFG.WATCHDOG.AUTO_START_MASK.001
- LRS.CFG.WATCHDOG.NO_STOP_MASK.001
- LRS.CFG.WATCHDOG.HARD_CFG_LOCK_MASK.001
- LRS.CFG.WATCHDOG.DEFAULT_CFG.001
- LRS.CFG.WATCHDOG.PROFILE.001
- LRS.CFG.WATCHDOG.PROFILE.002
- LRS.CFG.WATCHDOG.PROFILE.003
- LRS.CFG.WATCHDOG.PAR.001
- LRS.CFG.WATCHDOG.PAR.002
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
preconditions:
- POR完成；采用参数空间的合法配置；依据当前能力选择正向或UNSUPPORTED负向场景
stimulus:
- 遍历PC全部188配置；合法配置真实elaborate并读能力；非法配置以独立预期核对拒绝原因；三个产品档均做功能代表运行。
expected_result:
- 无静默截断；合法配置能力与实际实例一致；非法值或结构依赖错误必须在构建时失败。
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

Checker：无静默截断；合法配置能力与实际实例一致；非法值或结构依赖错误必须在构建时失败。

覆盖采样：参数×合法性×能力裁剪；通道1/16、客户端1/32、W32/48/64、同步2/3/4及16参数风险组合。
