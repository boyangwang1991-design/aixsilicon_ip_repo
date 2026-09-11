# Watchdog：寄存器字段行为 / channel_stage

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## RECOVERY_LIMIT_STAGE.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.RECOVERY_LIMIT_STAGE.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].RECOVERY_LIMIT_STAGE.value_0
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

warm之间最大局部恢复次数。需cfg_auth且完整合法APB写才更改本地项，运行值不受此写影响。 COMMIT捕获完整组并在WDT校验；跨低高字写不产生中间active值。

