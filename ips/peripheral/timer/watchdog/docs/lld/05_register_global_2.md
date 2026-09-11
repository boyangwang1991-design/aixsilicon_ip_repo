# Watchdog：寄存器字段行为 / global

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## ISSUED_SEQ.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.ISSUED_SEQ.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.ISSUED_SEQ.value_0
behavior: status
sw_behavior: RO
hw_behavior: 每个成功邮箱接收加一，自然回卷；同步拒绝不变
collision: HW owns value; SW write rejected
update_timing: immediate
reset_semantics: POR initializes declared identity/capability or zero transaction state; preset retains transaction
  records, clears only synchronized summary outputs; warm retains records
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
applicability:
  expr: 'true'
END_LLD_REG_META -->

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。每个成功邮箱接收加一，自然回卷；同步拒绝不变。

## DONE_SEQ.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.DONE_SEQ.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.DONE_SEQ.value_0
behavior: status
sw_behavior: RO
hw_behavior: 实际执行/取消应答发布时复制该命令seq
collision: HW owns value; SW write rejected
update_timing: immediate
reset_semantics: POR initializes declared identity/capability or zero transaction state; preset retains transaction
  records, clears only synchronized summary outputs; warm retains records
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
applicability:
  expr: 'true'
END_LLD_REG_META -->

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。实际执行/取消应答发布时复制该命令seq。

## DONE_INFO.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.DONE_INFO.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.DONE_INFO.value_0
behavior: status
sw_behavior: RO
hw_behavior: 最近完成的channel/client/opcode，来源是保持邮箱
collision: HW owns value; SW write rejected
update_timing: immediate
reset_semantics: POR initializes declared identity/capability or zero transaction state; preset retains transaction
  records, clears only synchronized summary outputs; warm retains records
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
applicability:
  expr: 'true'
END_LLD_REG_META -->

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。最近完成的channel/client/opcode，来源是保持邮箱。

## IRQ_SUMMARY.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.IRQ_SUMMARY.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.IRQ_SUMMARY.value_0
behavior: status
sw_behavior: RO
hw_behavior: APB域同步IRQ电平
collision: HW owns value; SW write rejected
update_timing: immediate
reset_semantics: POR initializes declared identity/capability or zero transaction state; preset retains transaction
  records, clears only synchronized summary outputs; warm retains records
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
applicability:
  expr: 'true'
END_LLD_REG_META -->

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。APB域同步IRQ电平。

## FAULT_SUMMARY.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.FAULT_SUMMARY.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.FAULT_SUMMARY.value_0
behavior: status
sw_behavior: RO
hw_behavior: APB域同步active_fault电平
collision: HW owns value; SW write rejected
update_timing: immediate
reset_semantics: POR initializes declared identity/capability or zero transaction state; preset retains transaction
  records, clears only synchronized summary outputs; warm retains records
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
applicability:
  expr: 'true'
END_LLD_REG_META -->

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。APB域同步active_fault电平。

