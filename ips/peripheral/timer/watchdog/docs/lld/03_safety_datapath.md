# Watchdog：独立故障归约

## 原始原因到保持请求

<!-- LLD_DATAPATH_META
id: LLD.DP.WATCHDOG.SAFETY.FINAL
module_ref: LLD.MOD.WATCHDOG.SAFETY
hld_ref:
- HLD.MOD.WATCHDOG.SAFETY
req_ref:
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
applicability:
  expr: 'true'
input_width: 19-bit events + independent compare flags
output_width: fatal causes + final_hold
latency: 1
signed: false
END_LLD_DATAPATH_META -->

受保护状态比较输出先归入各独立原因，按固定FATAL_MASK归约；不先经普通state
译码再决定是否报告。final_hold下一状态为旧hold OR真实致命/最终到期/直接系统
故障入口；可信warm允许清除但新事件置位优先。输出OR主final与hold，使其中一条
状态更新锥错误不能撤掉请求。源事件和副本稳定性分别进入静态和门级检查。

