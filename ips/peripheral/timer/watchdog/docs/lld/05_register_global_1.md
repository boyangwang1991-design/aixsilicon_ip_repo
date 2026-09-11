# Watchdog：寄存器字段行为 / global

结构路径采用ch[]表示所有实例；offset/bit/access/reset数值由SystemRDL提供，不在此重复位表。

## IP_ID.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.IP_ID.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.IP_ID.value_0
behavior: status
sw_behavior: RO
hw_behavior: 只读固定IP身份
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

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。只读固定IP身份。

## VERSION.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.VERSION.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.VERSION.value_0
behavior: status
sw_behavior: RO
hw_behavior: 只读版本标识
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

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。只读版本标识。

## CAPABILITY0.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CAPABILITY0.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.CAPABILITY0.value_0
behavior: status
sw_behavior: RO
hw_behavior: 实际NUM_CHANNELS/NUM_CLIENTS/COUNTER_WIDTH/PRESCALE_WIDTH编码
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

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。实际NUM_CHANNELS/NUM_CLIENTS/COUNTER_WIDTH/PRESCALE_WIDTH编码。

## CAPABILITY1.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CAPABILITY1.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.CAPABILITY1.value_0
behavior: status
sw_behavior: RO
hw_behavior: 实际增强功能存在性与SYNC_STAGES编码，不报告不存在的硬件
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

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。实际增强功能存在性与SYNC_STAGES编码，不报告不存在的硬件。

## CMD_STATUS.value_0

<!-- LLD_REG_META
id: LLD.REG.WATCHDOG.CMD_STATUS.VALUE_0
module_ref: LLD.MOD.WATCHDOG.BUS
register_ref: watchdog_regs.CMD_STATUS.value_0
behavior: status
sw_behavior: RO
hw_behavior: busy、exec_done、最近完成result；新接收清done，目的应答发布置done
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

普通读取无副作用，返回本地域值，不等待WDT；能力反映实例参数。busy、exec_done、最近完成result；新接收清done，目的应答发布置done。

