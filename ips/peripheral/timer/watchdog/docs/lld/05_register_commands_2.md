# Watchdog：寄存器字段行为 / commands

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## IRQ_CLEAR.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.IRQ_CLEAR.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].IRQ_CLEAR.value_0
behavior: w1c
sw_behavior: WO; read returns zero
hw_behavior: 对raw做W1C，硬件新事件置位优先；不清active_fault/local/final
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

诊断授权，不消费额度。APB成功只代表接收，实际结果必须等待对应DONE_SEQ；忙拒绝不排队、不覆盖旧DONE。对raw做W1C，硬件新事件置位优先；不清active_fault/local/final。硬件set与SW clear同拍最终set保持。

## IRQ_TEST.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.IRQ_TEST.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].IRQ_TEST.value_0
behavior: atomic
sw_behavior: WO; read returns zero
hw_behavior: 数据使能时只置DIAG_TEST_EVENT并标记测试上下文；不刷新计时
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

诊断授权，不消费额度。APB成功只代表接收，实际结果必须等待对应DONE_SEQ；忙拒绝不排队、不覆盖旧DONE。数据使能时只置DIAG_TEST_EVENT并标记测试上下文；不刷新计时。

## DIAG_CLEAR.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.DIAG_CLEAR.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].DIAG_CLEAR.value_0
behavior: atomic
sw_behavior: WO; read returns zero
hw_behavior: 只按数据选择清FIRST_FAULT有效记录与FAULT_COUNT；不清锁/恢复次数/活动请求；新故障同拍优先
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

诊断授权并消费额度，要求无活动故障。APB成功只代表接收，实际结果必须等待对应DONE_SEQ；忙拒绝不排队、不覆盖旧DONE。只按数据选择清FIRST_FAULT有效记录与FAULT_COUNT；不清锁/恢复次数/活动请求；新故障同拍优先。

## FAULT_INJECT.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.FAULT_INJECT.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ch[].FAULT_INJECT.value_0
behavior: atomic
sw_behavior: WO; read returns zero
hw_behavior: 目标与索引合法才对一次真实状态/比较路径注错；不直接伪造故障结果；未实现检测对象UNSUPPORTED
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

配置和诊断授权、test_auth、DIAG_INJECT_EN、未DIAG_LOCK并消费额度。APB成功只代表接收，实际结果必须等待对应DONE_SEQ；忙拒绝不排队、不覆盖旧DONE。目标与索引合法才对一次真实状态/比较路径注错；不直接伪造故障结果；未实现检测对象UNSUPPORTED。

