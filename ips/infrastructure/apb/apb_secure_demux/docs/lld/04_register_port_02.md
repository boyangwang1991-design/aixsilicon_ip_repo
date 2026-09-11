# port 字段行为 2

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.port[p].DENY_COUNT.value

RO；仅DFX_EN及双重授权。计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.DENY_COUNT.VALUE
register_ref: apb_secure_demux.port[p].DENY_COUNT.value
behavior: counter
sw_behavior: RO；仅DFX_EN及双重授权
hw_behavior: 计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.port[p].SLVERR_COUNT.value

RO；仅DFX_EN及双重授权。计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.SLVERR_COUNT.VALUE
register_ref: apb_secure_demux.port[p].SLVERR_COUNT.value
behavior: counter
sw_behavior: RO；仅DFX_EN及双重授权
hw_behavior: 计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.port[p].WAIT_TOTAL.value

RO；仅DFX_EN及双重授权。计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.WAIT_TOTAL.VALUE
register_ref: apb_secure_demux.port[p].WAIT_TOTAL.value
behavior: counter
sw_behavior: RO；仅DFX_EN及双重授权
hw_behavior: 计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.port[p].WAIT_MAX.value

RO；仅DFX_EN及双重授权。计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.WAIT_MAX.VALUE
register_ref: apb_secure_demux.port[p].WAIT_MAX.value
behavior: counter
sw_behavior: RO；仅DFX_EN及双重授权
hw_behavior: 计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.port[p].DFX_COUNTER_CLEAR.success

WO；仅DFX_EN及双重授权。先清所选计数再处理本周期事件。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.DFX_COUNTER_CLEAR.SUCCESS
register_ref: apb_secure_demux.port[p].DFX_COUNTER_CLEAR.success
behavior: command
sw_behavior: WO；仅DFX_EN及双重授权
hw_behavior: 先清所选计数再处理本周期事件
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.port[p].DFX_COUNTER_CLEAR.deny

WO；仅DFX_EN及双重授权。先清所选计数再处理本周期事件。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.DFX_COUNTER_CLEAR.DENY
register_ref: apb_secure_demux.port[p].DFX_COUNTER_CLEAR.deny
behavior: command
sw_behavior: WO；仅DFX_EN及双重授权
hw_behavior: 先清所选计数再处理本周期事件
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.port[p].DFX_COUNTER_CLEAR.slverr

WO；仅DFX_EN及双重授权。先清所选计数再处理本周期事件。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.DFX_COUNTER_CLEAR.SLVERR
register_ref: apb_secure_demux.port[p].DFX_COUNTER_CLEAR.slverr
behavior: command
sw_behavior: WO；仅DFX_EN及双重授权
hw_behavior: 先清所选计数再处理本周期事件
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.port[p].DFX_COUNTER_CLEAR.wait_total

WO；仅DFX_EN及双重授权。先清所选计数再处理本周期事件。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.DFX_COUNTER_CLEAR.WAIT_TOTAL
register_ref: apb_secure_demux.port[p].DFX_COUNTER_CLEAR.wait_total
behavior: command
sw_behavior: WO；仅DFX_EN及双重授权
hw_behavior: 先清所选计数再处理本周期事件
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.port[p].DFX_COUNTER_CLEAR.wait_max

WO；仅DFX_EN及双重授权。先清所选计数再处理本周期事件。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.DFX_COUNTER_CLEAR.WAIT_MAX
register_ref: apb_secure_demux.port[p].DFX_COUNTER_CLEAR.wait_max
behavior: command
sw_behavior: WO；仅DFX_EN及双重授权
hw_behavior: 先清所选计数再处理本周期事件
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

