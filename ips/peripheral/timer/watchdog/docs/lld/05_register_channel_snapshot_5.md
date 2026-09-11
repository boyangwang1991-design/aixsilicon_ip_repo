# Watchdog：寄存器字段行为 / channel_snapshot

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## FIRST_STATE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.FIRST_STATE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].FIRST_STATE_SNAP.value_0
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

镜像内容为首次故障之前旧状态编码。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## CTRL_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CTRL_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CTRL_ACTIVE_SNAP.value_0
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

镜像内容为已生效配置中的窗口/预警/BOOT、服务/监督模式、响应/恢复、暂停、wake与服务路径。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## PRESCALE_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.PRESCALE_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].PRESCALE_ACTIVE_SNAP.value_0
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

镜像内容为已生效配置中的分频比较阈值，提交时拒绝超PRESCALE_WIDTH位。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## WIN_MIN_LO_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.WIN_MIN_LO_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].WIN_MIN_LO_ACTIVE_SNAP.value_0
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

镜像内容为已生效配置中的主窗口下界低字。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## WIN_MIN_HI_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.WIN_MIN_HI_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].WIN_MIN_HI_ACTIVE_SNAP.value_0
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

镜像内容为已生效配置中的主窗口下界高字。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

