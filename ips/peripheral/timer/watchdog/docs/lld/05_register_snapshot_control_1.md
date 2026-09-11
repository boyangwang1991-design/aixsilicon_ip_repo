# Watchdog：寄存器字段行为 / snapshot_control

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## SNAP_META.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.SNAP_META.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].SNAP_META.value_0
behavior: status
sw_behavior: RO
hw_behavior: successful SNAPSHOT reply atomically publishes valid/sequence
collision: reply publication wins over stale mirror
update_timing: transaction_boundary
reset_semantics: POR zero; preset/warm/local retain held mirror metadata
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
applicability:
  expr: 'true'
END_LLD_REG_META -->

当前保持镜像的有效性/序号，只在成功SNAPSHOT应答发布时一起更新。失败或取消不替换；普通读无副作用。

## SNAP_SEQ.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.SNAP_SEQ.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].SNAP_SEQ.value_0
behavior: status
sw_behavior: RO
hw_behavior: successful SNAPSHOT reply atomically publishes valid/sequence
collision: reply publication wins over stale mirror
update_timing: transaction_boundary
reset_semantics: POR zero; preset/warm/local retain held mirror metadata
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
applicability:
  expr: 'true'
END_LLD_REG_META -->

当前保持镜像的有效性/序号，只在成功SNAPSHOT应答发布时一起更新。失败或取消不替换；普通读无副作用。

