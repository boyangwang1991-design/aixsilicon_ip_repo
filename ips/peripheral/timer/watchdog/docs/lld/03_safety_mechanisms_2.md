# Watchdog：独立安全路径与检测边界

## SERVICE_PATH

<!-- LLD_SAFETY_META
id: LLD.SAFE.WATCHDOG.SERVICE_PATH
module_ref: LLD.MOD.WATCHDOG.SAFETY
hld_ref:
- HLD.SAFE.WATCHDOG.SERVICE_PATH
protected_objects:
- LLD.FSM.WATCHDOG.CHANNEL.SERVICE
- LLD.BUF.WATCHDOG.CHANNEL.CLIENTS
mechanism: independent complete acceptance qualification
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

独立服务资格路径重算原始cmd的授权/身份/路径、客户端选择、当前状态、算法结果、
序列时间、窗口、重复报到和模式边界，与主accepted/refresh/restart分别比较。
TOKEN/QA和FLOW同样纳入，不能只复制KEY1比较就声称完整服务控制已保护。独立路径
使用保护副本状态/配置，若主refresh翻转而原始输入不满足，置SERVICE_PATH_INTEGRITY；
不能让未经复核的单一refresh同时清两份计数。误拒绝也应因两路径差异报告。
合法锁/配置/启动动作采用受保护事务来源，任何未授权单点控制翻转不能静默停监督。

## FINAL_REQUEST

<!-- LLD_SAFETY_META
id: LLD.SAFE.WATCHDOG.FINAL_REQUEST
module_ref: LLD.MOD.WATCHDOG.SAFETY
hld_ref:
- HLD.SAFE.WATCHDOG.FINAL_REQUEST
protected_objects:
- LLD.ERR.WATCHDOG.CHANNEL.EVENTS
mechanism: independent set-dominant final latch
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

单独final_hold寄存器由原始致命原因OR、主/影子最终比较及直接系统故障入口置位，
独立于普通state/final_req数据选择路径。输出system/safe为普通final与final_hold的OR。
清除仅POR或可信warm且无本拍新故障/最终到期，置位优先；服务、IRQ清除、STOP及
状态非法恢复不能清该寄存器。配套反码/一致性监视防止保持路径单翻转悄然解除请求。
从可观察编码/比较异常到置告警及final_hold最多2个WDT边沿，组合检测后下一寄存
边沿锁存通常1拍。跨域同步、潜伏模拟故障和停钟不算已可观察数字异常。

