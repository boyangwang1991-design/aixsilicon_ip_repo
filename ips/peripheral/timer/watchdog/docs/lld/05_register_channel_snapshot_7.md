# Watchdog：寄存器字段行为 / channel_snapshot

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## BOOT_TIMEOUT_HI_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.BOOT_TIMEOUT_HI_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].BOOT_TIMEOUT_HI_ACTIVE_SNAP.value_0
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

镜像内容为已生效配置中的启动周期期限高字。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## SEQ_LIMIT_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.SEQ_LIMIT_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].SEQ_LIMIT_ACTIVE_SNAP.value_0
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

镜像内容为已生效配置中的双密钥序列未分频周期期限，必须非零。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## REQUIRE_MASK_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.REQUIRE_MASK_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].REQUIRE_MASK_ACTIVE_SNAP.value_0
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

镜像内容为已生效配置中的必需客户端非零mask，不引用未实现客户端。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## FAULT_POLICY_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.FAULT_POLICY_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].FAULT_POLICY_ACTIVE_SNAP.value_0
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

镜像内容为已生效配置中的非致命事件到故障的策略，固定强制位在COMMIT检查。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

## LOCAL_DELAY_ACTIVE_SNAP.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.LOCAL_DELAY_ACTIVE_SNAP.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].LOCAL_DELAY_ACTIVE_SNAP.value_0
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

镜像内容为已生效配置中的局部请求未分频延迟。只在同一次原子SNAPSHOT捕获n后跨域发布，不逐字段跨域读。SNAP_VALID=0时读0，普通读不更新；未实现高位补0。

