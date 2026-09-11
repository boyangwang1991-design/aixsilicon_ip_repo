# interrupt 字段行为 4

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.ALERT_ENABLE.multi_hit

RW；管理授权，不受策略锁影响。只控制security_alert归约，不能旁路FATAL。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ALERT_ENABLE.MULTI_HIT
register_ref: apb_secure_demux.ALERT_ENABLE.multi_hit
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制security_alert归约，不能旁路FATAL
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位为1
END_LLD_REG_META -->

## apb_secure_demux.ALERT_ENABLE.integrity_error

RW；管理授权，不受策略锁影响。只控制security_alert归约，不能旁路FATAL。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ALERT_ENABLE.INTEGRITY_ERROR
register_ref: apb_secure_demux.ALERT_ENABLE.integrity_error
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制security_alert归约，不能旁路FATAL
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位为1
END_LLD_REG_META -->

## apb_secure_demux.ALERT_ENABLE.event_lost

RW；管理授权，不受策略锁影响。只控制security_alert归约，不能旁路FATAL。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ALERT_ENABLE.EVENT_LOST
register_ref: apb_secure_demux.ALERT_ENABLE.event_lost
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制security_alert归约，不能旁路FATAL
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位为0
END_LLD_REG_META -->

## apb_secure_demux.ALERT_ENABLE.downstream_error

RW；管理授权，不受策略锁影响。只控制security_alert归约，不能旁路FATAL。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ALERT_ENABLE.DOWNSTREAM_ERROR
register_ref: apb_secure_demux.ALERT_ENABLE.downstream_error
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制security_alert归约，不能旁路FATAL
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位为0
END_LLD_REG_META -->

## apb_secure_demux.ALERT_ENABLE.wait_exceeded

RW；管理授权，不受策略锁影响。只控制security_alert归约，不能旁路FATAL。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ALERT_ENABLE.WAIT_EXCEEDED
register_ref: apb_secure_demux.ALERT_ENABLE.wait_exceeded
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制security_alert归约，不能旁路FATAL
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位为1
END_LLD_REG_META -->

## apb_secure_demux.ALERT_ENABLE.dfx_test

RW；管理授权，不受策略锁影响。只控制security_alert归约，不能旁路FATAL。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ALERT_ENABLE.DFX_TEST
register_ref: apb_secure_demux.ALERT_ENABLE.dfx_test
behavior: mask
sw_behavior: RW；管理授权，不受策略锁影响
hw_behavior: 只控制security_alert归约，不能旁路FATAL
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位为0
END_LLD_REG_META -->

## apb_secure_demux.INTR_TEST.dfx_test

WO；管理及当前硬件DFX授权。写有效测试位产生DFX_TEST通知，无日志/真实错误计数；写零无动作。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTR_TEST.DFX_TEST
register_ref: apb_secure_demux.INTR_TEST.dfx_test
behavior: command
sw_behavior: WO；管理及当前硬件DFX授权
hw_behavior: 写有效测试位产生DFX_TEST通知，无日志/真实错误计数；写零无动作
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

