# Watchdog：寄存器字段行为 / client_snapshot

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_DEADLINE_MAX_LO_ACTIVE_SNAP.value_0
behavior: snapshot
sw_behavior: RO
hw_behavior: publish held post-update snapshot only after successful response
collision: snapshot contains same-edge post-update state; first-fault fields retain historical capture
update_timing: transaction_boundary
reset_semantics: POR invalid/zero; preset/warm/local retain last successful mirror
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
applicability:
  expr: 'true'
END_LLD_REG_META -->

镜像内容为已生效配置中的所选客户端Deadline上界低字。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。CLIENT_SELECT只选已捕获的客户端项。

## CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_DEADLINE_MAX_HI_ACTIVE_SNAP.value_0
behavior: snapshot
sw_behavior: RO
hw_behavior: publish held post-update snapshot only after successful response
collision: snapshot contains same-edge post-update state; first-fault fields retain historical capture
update_timing: transaction_boundary
reset_semantics: POR invalid/zero; preset/warm/local retain last successful mirror
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
applicability:
  expr: 'true'
END_LLD_REG_META -->

镜像内容为已生效配置中的所选客户端Deadline上界高字。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。CLIENT_SELECT只选已捕获的客户端项。

