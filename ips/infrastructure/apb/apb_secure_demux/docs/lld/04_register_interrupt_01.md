# interrupt 字段行为 1

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.INTR_RAW.access_denied

RW1C；成功写一清对应粘滞位。捕获所有候选；FATAL持续强置integrity_error。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_RAW.ACCESS_DENIED
register_ref: apb_secure_demux.INTR_RAW.access_denied
behavior: w1c
sw_behavior: RW1C；成功写一清对应粘滞位
hw_behavior: 捕获所有候选；FATAL持续强置integrity_error
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_RAW.cfg_access_error

RW1C；成功写一清对应粘滞位。捕获所有候选；FATAL持续强置integrity_error。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_RAW.CFG_ACCESS_ERROR
register_ref: apb_secure_demux.INTR_RAW.cfg_access_error
behavior: w1c
sw_behavior: RW1C；成功写一清对应粘滞位
hw_behavior: 捕获所有候选；FATAL持续强置integrity_error
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_RAW.addr_miss

RW1C；成功写一清对应粘滞位。捕获所有候选；FATAL持续强置integrity_error。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_RAW.ADDR_MISS
register_ref: apb_secure_demux.INTR_RAW.addr_miss
behavior: w1c
sw_behavior: RW1C；成功写一清对应粘滞位
hw_behavior: 捕获所有候选；FATAL持续强置integrity_error
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_RAW.multi_hit

RW1C；成功写一清对应粘滞位。捕获所有候选；FATAL持续强置integrity_error。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_RAW.MULTI_HIT
register_ref: apb_secure_demux.INTR_RAW.multi_hit
behavior: w1c
sw_behavior: RW1C；成功写一清对应粘滞位
hw_behavior: 捕获所有候选；FATAL持续强置integrity_error
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_RAW.integrity_error

RW1C；成功写一清对应粘滞位。捕获所有候选；FATAL持续强置integrity_error。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_RAW.INTEGRITY_ERROR
register_ref: apb_secure_demux.INTR_RAW.integrity_error
behavior: w1c
sw_behavior: RW1C；成功写一清对应粘滞位
hw_behavior: 捕获所有候选；FATAL持续强置integrity_error
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_RAW.event_lost

RW1C；成功写一清对应粘滞位。捕获所有候选；FATAL持续强置integrity_error。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_RAW.EVENT_LOST
register_ref: apb_secure_demux.INTR_RAW.event_lost
behavior: w1c
sw_behavior: RW1C；成功写一清对应粘滞位
hw_behavior: 捕获所有候选；FATAL持续强置integrity_error
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_RAW.downstream_error

RW1C；成功写一清对应粘滞位。捕获所有候选；FATAL持续强置integrity_error。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_RAW.DOWNSTREAM_ERROR
register_ref: apb_secure_demux.INTR_RAW.downstream_error
behavior: w1c
sw_behavior: RW1C；成功写一清对应粘滞位
hw_behavior: 捕获所有候选；FATAL持续强置integrity_error
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_RAW.wait_exceeded

RW1C；成功写一清对应粘滞位。捕获所有候选；FATAL持续强置integrity_error。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_RAW.WAIT_EXCEEDED
register_ref: apb_secure_demux.INTR_RAW.wait_exceeded
behavior: w1c
sw_behavior: RW1C；成功写一清对应粘滞位
hw_behavior: 捕获所有候选；FATAL持续强置integrity_error
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_RAW.dfx_test

RW1C；成功写一清对应粘滞位。捕获所有候选；FATAL持续强置integrity_error。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_RAW.DFX_TEST
register_ref: apb_secure_demux.INTR_RAW.dfx_test
behavior: w1c
sw_behavior: RW1C；成功写一清对应粘滞位
hw_behavior: 捕获所有候选；FATAL持续强置integrity_error
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTR_ENABLE.access_denied

RW；管理授权，不受策略锁影响。只控制irq归约，不影响事件捕获。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_ENABLE.ACCESS_DENIED
register_ref: apb_secure_demux.INTR_ENABLE.access_denied
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制irq归约，不影响事件捕获
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

