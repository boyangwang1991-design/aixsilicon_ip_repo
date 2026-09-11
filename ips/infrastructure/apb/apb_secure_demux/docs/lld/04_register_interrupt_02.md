# interrupt 字段行为 2

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.INTR_ENABLE.cfg_access_error

RW；管理授权，不受策略锁影响。只控制irq归约，不影响事件捕获。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_ENABLE.CFG_ACCESS_ERROR
register_ref: apb_secure_demux.INTR_ENABLE.cfg_access_error
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制irq归约，不影响事件捕获
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_ENABLE.addr_miss

RW；管理授权，不受策略锁影响。只控制irq归约，不影响事件捕获。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_ENABLE.ADDR_MISS
register_ref: apb_secure_demux.INTR_ENABLE.addr_miss
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制irq归约，不影响事件捕获
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_ENABLE.multi_hit

RW；管理授权，不受策略锁影响。只控制irq归约，不影响事件捕获。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_ENABLE.MULTI_HIT
register_ref: apb_secure_demux.INTR_ENABLE.multi_hit
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制irq归约，不影响事件捕获
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_ENABLE.integrity_error

RW；管理授权，不受策略锁影响。只控制irq归约，不影响事件捕获。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_ENABLE.INTEGRITY_ERROR
register_ref: apb_secure_demux.INTR_ENABLE.integrity_error
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制irq归约，不影响事件捕获
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_ENABLE.event_lost

RW；管理授权，不受策略锁影响。只控制irq归约，不影响事件捕获。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_ENABLE.EVENT_LOST
register_ref: apb_secure_demux.INTR_ENABLE.event_lost
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制irq归约，不影响事件捕获
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_ENABLE.downstream_error

RW；管理授权，不受策略锁影响。只控制irq归约，不影响事件捕获。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_ENABLE.DOWNSTREAM_ERROR
register_ref: apb_secure_demux.INTR_ENABLE.downstream_error
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制irq归约，不影响事件捕获
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_ENABLE.wait_exceeded

RW；管理授权，不受策略锁影响。只控制irq归约，不影响事件捕获。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_ENABLE.WAIT_EXCEEDED
register_ref: apb_secure_demux.INTR_ENABLE.wait_exceeded
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制irq归约，不影响事件捕获
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_ENABLE.dfx_test

RW；管理授权，不受策略锁影响。只控制irq归约，不影响事件捕获。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_ENABLE.DFX_TEST
register_ref: apb_secure_demux.INTR_ENABLE.dfx_test
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制irq归约，不影响事件捕获
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_MASKED.access_denied

RO。raw和enable组合与。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_MASKED.ACCESS_DENIED
register_ref: apb_secure_demux.INTR_MASKED.access_denied
behavior: status
sw_behavior: RO
hw_behavior: raw和enable组合与
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_MASKED.cfg_access_error

RO。raw和enable组合与。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_MASKED.CFG_ACCESS_ERROR
register_ref: apb_secure_demux.INTR_MASKED.cfg_access_error
behavior: status
sw_behavior: RO
hw_behavior: raw和enable组合与
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

