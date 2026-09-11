# Watchdog：寄存器字段行为 / selectors

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## SERVICE_SELECT.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.SERVICE_SELECT.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].SERVICE_SELECT.value_0
behavior: selection
sw_behavior: RW
hw_behavior: APB accepted write selects indirect window; no WDT update
collision: interface reset wins
update_timing: immediate
reset_semantics: POR/preset zero; warm/local retain
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.FUNC.WATCHDOG.SRV.001
- LRS.FUNC.WATCHDOG.SRV.002
- LRS.FUNC.WATCHDOG.SRV.003
- LRS.FUNC.WATCHDOG.SRV.004
- LRS.FUNC.WATCHDOG.SRV.005
- LRS.FUNC.WATCHDOG.SRV.006
- LRS.FUNC.WATCHDOG.SRV.007
- LRS.FUNC.WATCHDOG.SRV.008
- LRS.FUNC.WATCHDOG.SRV.009
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.REG.WATCHDOG.CLIENT_WINDOW.001
applicability:
  expr: 'true'
END_LLD_REG_META -->

配置授权的本地选择器。客户端和event_type在SERVICE邮箱接收时捕获，之后选择器变化不改变在途服务。

## SERVICE_SELECT.value_8

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.SERVICE_SELECT.VALUE_8
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].SERVICE_SELECT.value_8
behavior: selection
sw_behavior: RW
hw_behavior: APB accepted write selects indirect window; no WDT update
collision: interface reset wins
update_timing: immediate
reset_semantics: POR/preset zero; warm/local retain
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.FUNC.WATCHDOG.SRV.001
- LRS.FUNC.WATCHDOG.SRV.002
- LRS.FUNC.WATCHDOG.SRV.003
- LRS.FUNC.WATCHDOG.SRV.004
- LRS.FUNC.WATCHDOG.SRV.005
- LRS.FUNC.WATCHDOG.SRV.006
- LRS.FUNC.WATCHDOG.SRV.007
- LRS.FUNC.WATCHDOG.SRV.008
- LRS.FUNC.WATCHDOG.SRV.009
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.REG.WATCHDOG.CLIENT_WINDOW.001
applicability:
  expr: 'true'
END_LLD_REG_META -->

配置授权的本地选择器。客户端和event_type在SERVICE邮箱接收时捕获，之后选择器变化不改变在途服务。

## CLIENT_SELECT.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_SELECT.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_SELECT.value_0
behavior: selection
sw_behavior: RW
hw_behavior: APB accepted write selects indirect window; no WDT update
collision: interface reset wins
update_timing: immediate
reset_semantics: POR/preset zero; warm/local retain
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.FUNC.WATCHDOG.SRV.001
- LRS.FUNC.WATCHDOG.SRV.002
- LRS.FUNC.WATCHDOG.SRV.003
- LRS.FUNC.WATCHDOG.SRV.004
- LRS.FUNC.WATCHDOG.SRV.005
- LRS.FUNC.WATCHDOG.SRV.006
- LRS.FUNC.WATCHDOG.SRV.007
- LRS.FUNC.WATCHDOG.SRV.008
- LRS.FUNC.WATCHDOG.SRV.009
- LRS.FUNC.WATCHDOG.SRV.010
- LRS.FUNC.WATCHDOG.SRV.011
- LRS.REG.WATCHDOG.CLIENT_WINDOW.001
applicability:
  expr: 'true'
END_LLD_REG_META -->

配置授权的本地选择器。只影响当前通道客户端staging/已保持镜像的间接窗口；不触发新快照。

