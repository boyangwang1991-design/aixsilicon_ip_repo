# logging 字段行为 2

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.CFG_DENY_COUNT.value

RO。32位饱和累加对应事件；LOST累加全部仲裁和FIFO丢失数量。竞争顺序：clear_then_increment。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CFG_DENY_COUNT.VALUE
register_ref: apb_secure_demux.CFG_DENY_COUNT.value
behavior: counter
sw_behavior: RO
hw_behavior: 32位饱和累加对应事件；LOST累加全部仲裁和FIFO丢失数量
collision: clear_then_increment
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.EVENT_LOST_COUNT.value

RO。32位饱和累加对应事件；LOST累加全部仲裁和FIFO丢失数量。竞争顺序：clear_then_increment。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.EVENT_LOST_COUNT.VALUE
register_ref: apb_secure_demux.EVENT_LOST_COUNT.value
behavior: counter
sw_behavior: RO
hw_behavior: 32位饱和累加对应事件；LOST累加全部仲裁和FIFO丢失数量
collision: clear_then_increment
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.DOWNSTREAM_ERR_COUNT.value

RO。32位饱和累加对应事件；LOST累加全部仲裁和FIFO丢失数量。竞争顺序：clear_then_increment。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.DOWNSTREAM_ERR_COUNT.VALUE
register_ref: apb_secure_demux.DOWNSTREAM_ERR_COUNT.value
behavior: counter
sw_behavior: RO
hw_behavior: 32位饱和累加对应事件；LOST累加全部仲裁和FIFO丢失数量
collision: clear_then_increment
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.COUNTER_CLEAR.access_deny

WO；写一清对应计数。清零优先执行，随后加入本周期增量。竞争顺序：clear_then_increment。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COUNTER_CLEAR.ACCESS_DENY
register_ref: apb_secure_demux.COUNTER_CLEAR.access_deny
behavior: command
sw_behavior: WO；写一清对应计数
hw_behavior: 清零优先执行，随后加入本周期增量
collision: clear_then_increment
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.COUNTER_CLEAR.cfg_deny

WO；写一清对应计数。清零优先执行，随后加入本周期增量。竞争顺序：clear_then_increment。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COUNTER_CLEAR.CFG_DENY
register_ref: apb_secure_demux.COUNTER_CLEAR.cfg_deny
behavior: command
sw_behavior: WO；写一清对应计数
hw_behavior: 清零优先执行，随后加入本周期增量
collision: clear_then_increment
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.COUNTER_CLEAR.event_lost

WO；写一清对应计数。清零优先执行，随后加入本周期增量。竞争顺序：clear_then_increment。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COUNTER_CLEAR.EVENT_LOST
register_ref: apb_secure_demux.COUNTER_CLEAR.event_lost
behavior: command
sw_behavior: WO；写一清对应计数
hw_behavior: 清零优先执行，随后加入本周期增量
collision: clear_then_increment
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.COUNTER_CLEAR.downstream_error

WO；写一清对应计数。清零优先执行，随后加入本周期增量。竞争顺序：clear_then_increment。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COUNTER_CLEAR.DOWNSTREAM_ERROR
register_ref: apb_secure_demux.COUNTER_CLEAR.downstream_error
behavior: command
sw_behavior: WO；写一清对应计数
hw_behavior: 清零优先执行，随后加入本周期增量
collision: clear_then_increment
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.FIRST_FAULT[w].data

RO；w=0成功读刷新本记录整条快照，w=1..7读对应快照。读0取沿前当前记录并同沿捕获快照；新事件写本体不改变已有快照；清对应记录同时清快照。竞争顺序：snapshot_pre_edge_record_then_event。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FIRST_FAULT.DATA
register_ref: apb_secure_demux.FIRST_FAULT[w].data
behavior: snapshot
sw_behavior: RO；w=0成功读刷新本记录整条快照，w=1..7读对应快照
hw_behavior: 读0取沿前当前记录并同沿捕获快照；新事件写本体不改变已有快照；清对应记录同时清快照
collision: snapshot_pre_edge_record_then_event
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.LAST_FAULT[w].data

RO；w=0成功读刷新本记录整条快照，w=1..7读对应快照。读0取沿前当前记录并同沿捕获快照；新事件写本体不改变已有快照；清对应记录同时清快照。竞争顺序：snapshot_pre_edge_record_then_event。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.LAST_FAULT.DATA
register_ref: apb_secure_demux.LAST_FAULT[w].data
behavior: snapshot
sw_behavior: RO；w=0成功读刷新本记录整条快照，w=1..7读对应快照
hw_behavior: 读0取沿前当前记录并同沿捕获快照；新事件写本体不改变已有快照；清对应记录同时清快照
collision: snapshot_pre_edge_record_then_event
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.FIFO_HEAD[w].data

RO；读取无副作用，depth0未实现。当前队头字，空队列返回零；仅POP/清空改变旧队头。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FIFO_HEAD.DATA
register_ref: apb_secure_demux.FIFO_HEAD[w].data
behavior: fifo
sw_behavior: RO；读取无副作用，depth0未实现
hw_behavior: 当前队头字，空队列返回零；仅POP/清空改变旧队头
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

