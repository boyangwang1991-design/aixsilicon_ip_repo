# Watchdog：寄存器字段行为 / client_snapshot

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## CLIENT_FLAGS_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_FLAGS_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_FLAGS_SNAP.value_0
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

镜像内容为所选客户端的selected/seen/sequence_pending/flow_active/last_step。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。CLIENT_SELECT只选已捕获的客户端项。

## CLIENT_TOKEN_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_TOKEN_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_TOKEN_SNAP.value_0
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

镜像内容为所选客户端token/challenge；未启用TOKEN/QA时0。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。CLIENT_SELECT只选已捕获的客户端项。

## CLIENT_ALIVE_COUNT_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_ALIVE_COUNT_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_ALIVE_COUNT_SNAP.value_0
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

镜像内容为所选客户端16位饱和ALIVE事件数，高位0。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。CLIENT_SELECT只选已捕获的客户端项。

## CLIENT_ELAPSED_LO_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_ELAPSED_LO_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_ELAPSED_LO_SNAP.value_0
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

镜像内容为所选客户端未分频FLOW年龄低字；非FLOW为0。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。CLIENT_SELECT只选已捕获的客户端项。

## CLIENT_ELAPSED_HI_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CLIENT_ELAPSED_HI_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].CLIENT_ELAPSED_HI_SNAP.value_0
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

镜像内容为所选客户端未分频FLOW年龄高字；非FLOW或未实现高位为0。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。CLIENT_SELECT只选已捕获的客户端项。

