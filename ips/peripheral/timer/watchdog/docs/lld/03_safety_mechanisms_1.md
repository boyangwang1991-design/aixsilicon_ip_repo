# Watchdog：独立安全路径与检测边界

## TIMEBASE

<!-- LLD_SAFETY_META
id: LLD.SAFE.WATCHDOG.TIMEBASE
module_ref: LLD.MOD.WATCHDOG.SAFETY
hld_ref:
- HLD.SAFE.WATCHDOG.TIMEBASE
protected_objects:
- LLD.DP.WATCHDOG.CHANNEL.AGE
mechanism: independent complemented counters
fault_detection_latency: 1
fault_reaction_latency: 1
req_ref:
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
- LRS.DFX.WATCHDOG.TST.001
- LRS.DFX.WATCHDOG.TST.002
- LRS.DFX.WATCHDOG.TST.003
- LRS.DFX.WATCHDOG.TST.004
- LRS.DFX.WATCHDOG.TST.005
applicability:
  expr: SAFETY_EN == 1
END_LLD_SAFETY_META -->

主C/D与反码影子Cbar/Dbar独立寄存；影子从~自身旧值、~配置副本计算tick/候选年龄。
每拍比较C==~Cbar、D==~Dbar及tick==tick_shadow；饱和时各自保持极值。暂停两条时间
路径均保持，但比较仍继续。初始化首个正常检查前两条均有效；不能用主tick同时
使能两条路径。计数/分频单寄存翻转产生COUNTER_MISMATCH并直接最终升级。

## CONFIG_CONTROL

<!-- LLD_SAFETY_META
id: LLD.SAFE.WATCHDOG.CONFIG_CONTROL
module_ref: LLD.MOD.WATCHDOG.SAFETY
hld_ref:
- HLD.SAFE.WATCHDOG.CONFIG_CONTROL
protected_objects:
- LLD.BUF.WATCHDOG.CHANNEL.CONFIG
- LLD.FSM.WATCHDOG.CHANNEL.UNLOCK
mechanism: complement and parity
fault_detection_latency: 1
fault_reaction_latency: 1
req_ref:
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
- LRS.DFX.WATCHDOG.TST.001
- LRS.DFX.WATCHDOG.TST.002
- LRS.DFX.WATCHDOG.TST.003
- LRS.DFX.WATCHDOG.TST.004
- LRS.DFX.WATCHDOG.TST.005
applicability:
  expr: SAFETY_EN == 1
END_LLD_SAFETY_META -->

active配置、pending配置、四锁使用反码副本，在相应合法整组写入事件生成副本并
持续比较；pending只在valid时参与比较，但valid和版本/额度/解锁源/年龄属于控制保护。
客户端状态使用独立奇偶校验检测单比特翻转；不能仅保护token而漏掉pending/seen/elapsed。
邮箱req/ack反码与payload奇偶校验覆盖完整command/config，源异常通过保持型事件跨域。
检测不纠正状态、不依赖软件处理；错误先置原因并阻断对应服务/提交，再最终保持。

## COMPARE_STATE

<!-- LLD_SAFETY_META
id: LLD.SAFE.WATCHDOG.COMPARE_STATE
module_ref: LLD.MOD.WATCHDOG.SAFETY
hld_ref:
- HLD.SAFE.WATCHDOG.COMPARE_STATE
protected_objects:
- LLD.FSM.WATCHDOG.CHANNEL.CONTROL
- LLD.DP.WATCHDOG.CHANNEL.AGE
mechanism: diverse comparators and encoded state
fault_detection_latency: 1
fault_reaction_latency: 1
req_ref:
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
- LRS.DFX.WATCHDOG.TST.001
- LRS.DFX.WATCHDOG.TST.002
- LRS.DFX.WATCHDOG.TST.003
- LRS.DFX.WATCHDOG.TST.004
- LRS.DFX.WATCHDOG.TST.005
applicability:
  expr: SAFETY_EN == 1
END_LLD_SAFETY_META -->

状态3位合法0..5，反码不符或6/7均STATE_INVALID；resume_state/初始化使能也纳入
控制保护。窗口、主超时、最终E比较有独立输入副本和不同逻辑表达的比较路径。
一条主超时成立即进入超时处理；双路径不同本身致命。最终E/Ebar分别未分频饱和
演进，不用主E的取反赋值替代第二条时间链。PAUSED仍比较配置/状态/请求完整性。

