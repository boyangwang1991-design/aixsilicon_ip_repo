# Watchdog：寄存器字段行为 / commands

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## UNLOCK.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.UNLOCK.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].UNLOCK.value_0
behavior: atomic
sw_behavior: WO; read returns zero
hw_behavior: 推进来源绑定的两笔解锁；错误清旧序列/额度，不改监督年龄
collision: new fatal/supervision event wins; rejected operation has no requested side effect
update_timing: transaction_boundary
reset_semantics: POR clears mailbox/owned state per module reset; preset retains accepted command; warm cancels
  unexecuted command and retains completed result
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
applicability:
  expr: 'true'
END_LLD_REG_META -->

配置授权，不需旧额度。APB成功只代表接收，实际结果必须等待对应DONE_SEQ；忙拒绝不排队、不覆盖旧DONE。推进来源绑定的两笔解锁；错误清旧序列/额度，不改监督年龄。

## COMMAND.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.COMMAND.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].COMMAND.value_0
behavior: atomic
sw_behavior: WO; read returns zero
hw_behavior: 按操作码执行COMMIT/START/STOP/CANCEL/SNAPSHOT；未知码BAD_CONFIG；状态/锁/期限冲突按模块规则拒绝
collision: new fatal/supervision event wins; rejected operation has no requested side effect
update_timing: transaction_boundary
reset_semantics: POR clears mailbox/owned state per module reset; preset retains accepted command; warm cancels
  unexecuted command and retains completed result
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
applicability:
  expr: 'true'
END_LLD_REG_META -->

SNAPSHOT免配置授权，其他需配置授权；COMMIT/START/STOP消费额度。APB成功只代表接收，实际结果必须等待对应DONE_SEQ；忙拒绝不排队、不覆盖旧DONE。按操作码执行COMMIT/START/STOP/CANCEL/SNAPSHOT；未知码BAD_CONFIG；状态/锁/期限冲突按模块规则拒绝。

## LOCK_SET.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.LOCK_SET.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].LOCK_SET.value_0
behavior: atomic
sw_behavior: WO; read returns zero
hw_behavior: 四锁仅OR置位，POR才清；失败也消耗额度
collision: new fatal/supervision event wins; rejected operation has no requested side effect
update_timing: transaction_boundary
reset_semantics: POR clears mailbox/owned state per module reset; preset retains accepted command; warm cancels
  unexecuted command and retains completed result
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
applicability:
  expr: 'true'
END_LLD_REG_META -->

配置授权且消费额度。APB成功只代表接收，实际结果必须等待对应DONE_SEQ；忙拒绝不排队、不覆盖旧DONE。四锁仅OR置位，POR才清；失败也消耗额度。

## SERVICE.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.SERVICE.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].SERVICE.value_0
behavior: atomic
sw_behavior: WO; read returns zero
hw_behavior: 按SERVICE_SELECT捕获值执行完整算法/检查点；只有最终完整合法贡献推进service_seq/token/健康状态
collision: new fatal/supervision event wins; rejected operation has no requested side effect
update_timing: transaction_boundary
reset_semantics: POR clears mailbox/owned state per module reset; preset retains accepted command; warm cancels
  unexecuted command and retains completed result
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
applicability:
  expr: 'true'
END_LLD_REG_META -->

服务授权，路径/客户端/OWNER_SOURCE一致，不消费额度。APB成功只代表接收，实际结果必须等待对应DONE_SEQ；忙拒绝不排队、不覆盖旧DONE。按SERVICE_SELECT捕获值执行完整算法/检查点；只有最终完整合法贡献推进service_seq/token/健康状态。

## IRQ_ENABLE.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.IRQ_ENABLE.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].IRQ_ENABLE.value_0
behavior: atomic
sw_behavior: WO; read returns zero
hw_behavior: 替换允许的IRQ mask；不修改raw或活动故障/复位请求
collision: new fatal/supervision event wins; rejected operation has no requested side effect
update_timing: transaction_boundary
reset_semantics: POR clears mailbox/owned state per module reset; preset retains accepted command; warm cancels
  unexecuted command and retains completed result
hld_ref:
- HLD.MOD.WATCHDOG.BUS
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
applicability:
  expr: 'true'
END_LLD_REG_META -->

配置授权，不消费额度。APB成功只代表接收，实际结果必须等待对应DONE_SEQ；忙拒绝不排队、不覆盖旧DONE。替换允许的IRQ mask；不修改raw或活动故障/复位请求。

