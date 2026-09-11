# interrupt 字段行为 3

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.INTR_MASKED.addr_miss

RO。raw和enable组合与。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_MASKED.ADDR_MISS
register_ref: apb_secure_demux.INTR_MASKED.addr_miss
behavior: status
sw_behavior: RO
hw_behavior: raw和enable组合与
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_MASKED.multi_hit

RO。raw和enable组合与。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_MASKED.MULTI_HIT
register_ref: apb_secure_demux.INTR_MASKED.multi_hit
behavior: status
sw_behavior: RO
hw_behavior: raw和enable组合与
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_MASKED.integrity_error

RO。raw和enable组合与。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_MASKED.INTEGRITY_ERROR
register_ref: apb_secure_demux.INTR_MASKED.integrity_error
behavior: status
sw_behavior: RO
hw_behavior: raw和enable组合与
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_MASKED.event_lost

RO。raw和enable组合与。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_MASKED.EVENT_LOST
register_ref: apb_secure_demux.INTR_MASKED.event_lost
behavior: status
sw_behavior: RO
hw_behavior: raw和enable组合与
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_MASKED.downstream_error

RO。raw和enable组合与。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_MASKED.DOWNSTREAM_ERROR
register_ref: apb_secure_demux.INTR_MASKED.downstream_error
behavior: status
sw_behavior: RO
hw_behavior: raw和enable组合与
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_MASKED.wait_exceeded

RO。raw和enable组合与。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_MASKED.WAIT_EXCEEDED
register_ref: apb_secure_demux.INTR_MASKED.wait_exceeded
behavior: status
sw_behavior: RO
hw_behavior: raw和enable组合与
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_MASKED.dfx_test

RO。raw和enable组合与。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_MASKED.DFX_TEST
register_ref: apb_secure_demux.INTR_MASKED.dfx_test
behavior: status
sw_behavior: RO
hw_behavior: raw和enable组合与
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.ALERT_ENABLE.access_denied

RW；管理授权，不受策略锁影响。只控制security_alert归约，不能旁路FATAL。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ALERT_ENABLE.ACCESS_DENIED
register_ref: apb_secure_demux.ALERT_ENABLE.access_denied
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制security_alert归约，不能旁路FATAL
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位为1
END_LLD_REG_META -->

## apb_secure_demux.ALERT_ENABLE.cfg_access_error

RW；管理授权，不受策略锁影响。只控制security_alert归约，不能旁路FATAL。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ALERT_ENABLE.CFG_ACCESS_ERROR
register_ref: apb_secure_demux.ALERT_ENABLE.cfg_access_error
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制security_alert归约，不能旁路FATAL
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位为1
END_LLD_REG_META -->

## apb_secure_demux.ALERT_ENABLE.addr_miss

RW；管理授权，不受策略锁影响。只控制security_alert归约，不能旁路FATAL。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ALERT_ENABLE.ADDR_MISS
register_ref: apb_secure_demux.ALERT_ENABLE.addr_miss
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制security_alert归约，不能旁路FATAL
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位为0
END_LLD_REG_META -->

