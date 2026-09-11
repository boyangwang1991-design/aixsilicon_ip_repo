# Watchdog：SAFETY 模块细化

<!-- LLD_MODULE_META
id: LLD.MOD.WATCHDOG.SAFETY
name: safety
parent_ref: HLD.MOD.WATCHDOG.SAFETY
hld_ref:
- HLD.MOD.WATCHDOG.SAFETY
req_ref:
- LRS.FUNC.WATCHDOG.FLT.001
- LRS.FUNC.WATCHDOG.FLT.002
- LRS.PERF.WATCHDOG.SAFETY.001
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
- LRS.LP.WATCHDOG.PWR.001
- LRS.LP.WATCHDOG.PWR.002
- LRS.LP.WATCHDOG.PWR.003
- LRS.LP.WATCHDOG.PWR.004
- LRS.LP.WATCHDOG.PWR.005
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
rtl_intent:
  separate_module: false
  suggested_name: watchdog_channel
clock_domains:
- HLD.DOM.CLK.WATCHDOG.WDT
reset_domains:
- HLD.DOM.RST.WATCHDOG.POR_WDT
END_LLD_MODULE_META -->

增强保护在 SAFETY_EN=1 实现，按每通道独立 C/D 影子、配置/锁反码、控制/客户端
完整性、状态合法性、双路径比较与独立最终保持状态分解。邮箱的 toggle/负载保护
在 top 形成跨域异常，通道保护在 channel 内形成原因；普通 FSM 错误不能屏蔽最终请求。

每个影子从自己的旧值演进；refresh/restart 是须独立核验的控制事件，不能盲用
主服务通过信号同时清两份计数。诊断从真实状态/比较异常进入事件 OR 和最终请求。
冗余属性只是综合意图，必须在后续实际网表检查证明未合并。
