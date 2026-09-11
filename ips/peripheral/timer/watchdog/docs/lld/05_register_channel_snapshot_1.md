# Watchdog：寄存器字段行为 / channel_snapshot

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## STATUS_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.STATUS_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].STATUS_SNAP.value_0
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

镜像内容为更新后state、active_fault、本轮prewarn、pending、credit、故障计数饱和、四锁及实际暂停来源。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## CFG_VERSION_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CFG_VERSION_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CFG_VERSION_SNAP.value_0
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

镜像内容为更新后active版本，不是最近提交但未应用版本。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## COUNT_LO_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.COUNT_LO_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].COUNT_LO_SNAP.value_0
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

镜像内容为更新后C的低容器字。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## COUNT_HI_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.COUNT_HI_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].COUNT_HI_SNAP.value_0
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

镜像内容为更新后C的高容器字，未实现高位补0。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## EVENT_RAW_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.EVENT_RAW_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].EVENT_RAW_SNAP.value_0
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

镜像内容为更新后raw事件位图，含本拍置位优先于清除的结果。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

