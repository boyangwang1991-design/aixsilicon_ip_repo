# Watchdog：寄存器字段行为 / client_stage

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## CLIENT_DEADLINE_MAX_LO_STAGE.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_DEADLINE_MAX_LO_STAGE.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_DEADLINE_MAX_LO_STAGE.value_0
behavior: shadow
sw_behavior: RW
hw_behavior: No running-domain update of staging; full accepted APB write only
collision: interface reset wins; WDT never writes staging
update_timing: immediate
reset_semantics: POR/preset restore corresponding DEFAULT_CFG field; warm/local recovery preserve staging
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.REG.WATCHDOG.CFG.007
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
applicability:
  expr: 'true'
END_LLD_REG_META -->

所选客户端Deadline上界低字。需cfg_auth且完整合法APB写才更改本地项，运行值不受此写影响。CLIENT_SELECT选择当前通道独立客户端项；改变选择器不复制或覆盖其他客户端。 COMMIT捕获完整组并在WDT校验；跨低高字写不产生中间active值。

## CLIENT_DEADLINE_MAX_HI_STAGE.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_DEADLINE_MAX_HI_STAGE.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_DEADLINE_MAX_HI_STAGE.value_0
behavior: shadow
sw_behavior: RW
hw_behavior: No running-domain update of staging; full accepted APB write only
collision: interface reset wins; WDT never writes staging
update_timing: immediate
reset_semantics: POR/preset restore corresponding DEFAULT_CFG field; warm/local recovery preserve staging
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.REG.WATCHDOG.CFG.007
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
applicability:
  expr: 'true'
END_LLD_REG_META -->

所选客户端Deadline上界高字。需cfg_auth且完整合法APB写才更改本地项，运行值不受此写影响。CLIENT_SELECT选择当前通道独立客户端项；改变选择器不复制或覆盖其他客户端。 COMMIT捕获完整组并在WDT校验；跨低高字写不产生中间active值。

