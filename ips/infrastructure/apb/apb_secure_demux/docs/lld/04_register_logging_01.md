# logging 字段行为 1

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.FAULT_CLEAR.first

WO；写一执行对应清除，写零无作用。先清后处理本周期新事件；first/last清除同时清快照。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FAULT_CLEAR.FIRST
register_ref: apb_secure_demux.FAULT_CLEAR.first
behavior: command
sw_behavior: WO；写一执行对应清除，写零无作用
hw_behavior: 先清后处理本周期新事件；first/last清除同时清快照
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.FAULT_CLEAR.last

WO；写一执行对应清除，写零无作用。先清后处理本周期新事件；first/last清除同时清快照。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FAULT_CLEAR.LAST
register_ref: apb_secure_demux.FAULT_CLEAR.last
behavior: command
sw_behavior: WO；写一执行对应清除，写零无作用
hw_behavior: 先清后处理本周期新事件；first/last清除同时清快照
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.FAULT_CLEAR.fifo

WO；写一执行对应清除，写零无作用。先清后处理本周期新事件；first/last清除同时清快照。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FAULT_CLEAR.FIFO
register_ref: apb_secure_demux.FAULT_CLEAR.fifo
behavior: command
sw_behavior: WO；写一执行对应清除，写零无作用
hw_behavior: 先清后处理本周期新事件；first/last清除同时清快照
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.FAULT_CLEAR.overflow

WO；写一执行对应清除，写零无作用。先清后处理本周期新事件；first/last清除同时清快照。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FAULT_CLEAR.OVERFLOW
register_ref: apb_secure_demux.FAULT_CLEAR.overflow
behavior: command
sw_behavior: WO；写一执行对应清除，写零无作用
hw_behavior: 先清后处理本周期新事件；first/last清除同时清快照
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.FIFO_STATUS.count

RO。队列占用及粘滞溢出镜像；depth0时count0/empty1/full0。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FIFO_STATUS.COUNT
register_ref: apb_secure_demux.FIFO_STATUS.count
behavior: status
sw_behavior: RO
hw_behavior: 队列占用及粘滞溢出镜像；depth0时count0/empty1/full0
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: count0/empty1/full0/overflow0
END_LLD_REG_META -->

## apb_secure_demux.FIFO_STATUS.empty

RO。队列占用及粘滞溢出镜像；depth0时count0/empty1/full0。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FIFO_STATUS.EMPTY
register_ref: apb_secure_demux.FIFO_STATUS.empty
behavior: status
sw_behavior: RO
hw_behavior: 队列占用及粘滞溢出镜像；depth0时count0/empty1/full0
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: count0/empty1/full0/overflow0
END_LLD_REG_META -->

## apb_secure_demux.FIFO_STATUS.full

RO。队列占用及粘滞溢出镜像；depth0时count0/empty1/full0。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FIFO_STATUS.FULL
register_ref: apb_secure_demux.FIFO_STATUS.full
behavior: status
sw_behavior: RO
hw_behavior: 队列占用及粘滞溢出镜像；depth0时count0/empty1/full0
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: count0/empty1/full0/overflow0
END_LLD_REG_META -->

## apb_secure_demux.FIFO_STATUS.overflow

RO。队列占用及粘滞溢出镜像；depth0时count0/empty1/full0。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FIFO_STATUS.OVERFLOW
register_ref: apb_secure_demux.FIFO_STATUS.overflow
behavior: status
sw_behavior: RO
hw_behavior: 队列占用及粘滞溢出镜像；depth0时count0/empty1/full0
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: count0/empty1/full0/overflow0
END_LLD_REG_META -->

## apb_secure_demux.FIFO_POP.pop

WO；深度0未实现；非空且有效POP位为一时弹出；空队列命令错误。先pop后push，满队列允许同沿补入；读HEAD不弹出。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.FIFO_POP.POP
register_ref: apb_secure_demux.FIFO_POP.pop
behavior: command
sw_behavior: WO；深度0未实现；非空且有效POP位为一时弹出；空队列命令错误
hw_behavior: 先pop后push，满队列允许同沿补入；读HEAD不弹出
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.ACCESS_DENY_COUNT.value

RO。32位饱和累加对应事件；LOST累加全部仲裁和FIFO丢失数量。竞争顺序：clear_then_increment。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.ACCESS_DENY_COUNT.VALUE
register_ref: apb_secure_demux.ACCESS_DENY_COUNT.value
behavior: counter
sw_behavior: RO
hw_behavior: 32位饱和累加对应事件；LOST累加全部仲裁和FIFO丢失数量
collision: clear_then_increment
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

