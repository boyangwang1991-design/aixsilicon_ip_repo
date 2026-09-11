# dfx 字段行为 1

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.DFX_STATUS.authorized

RO；管理及当前硬件授权。组合授权/武装/阈值状态；所有DFX关闭时未实现。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.DFX_STATUS.AUTHORIZED
register_ref: apb_secure_demux.DFX_STATUS.authorized
behavior: status
sw_behavior: RO；管理及当前硬件授权
hw_behavior: 组合授权/武装/阈值状态；所有DFX关闭时未实现
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.DFX_STATUS.deny_armed

RO；管理及当前硬件授权。组合授权/武装/阈值状态；所有DFX关闭时未实现。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.DFX_STATUS.DENY_ARMED
register_ref: apb_secure_demux.DFX_STATUS.deny_armed
behavior: status
sw_behavior: RO；管理及当前硬件授权
hw_behavior: 组合授权/武装/阈值状态；所有DFX关闭时未实现
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.DFX_STATUS.integrity_armed

RO；管理及当前硬件授权。组合授权/武装/阈值状态；所有DFX关闭时未实现。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.DFX_STATUS.INTEGRITY_ARMED
register_ref: apb_secure_demux.DFX_STATUS.integrity_armed
behavior: status
sw_behavior: RO；管理及当前硬件授权
hw_behavior: 组合授权/武装/阈值状态；所有DFX关闭时未实现
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.DFX_STATUS.wait_hit

RO；管理及当前硬件授权。组合授权/武装/阈值状态；所有DFX关闭时未实现。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.DFX_STATUS.WAIT_HIT
register_ref: apb_secure_demux.DFX_STATUS.wait_hit
behavior: status
sw_behavior: RO；管理及当前硬件授权
hw_behavior: 组合授权/武装/阈值状态；所有DFX关闭时未实现
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.WAIT_THRESHOLD.value

RW；零禁用，其余为本笔等待周期阈值。与增加后的本笔wait_count比较，第一次达到触发；不终止事务。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.WAIT_THRESHOLD.VALUE
register_ref: apb_secure_demux.WAIT_THRESHOLD.value
behavior: control
sw_behavior: RW；零禁用，其余为本笔等待周期阈值
hw_behavior: 与增加后的本笔wait_count比较，第一次达到触发；不终止事务
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.DFX_CLEAR.wait_hit

WO；写一清WAIT_HIT或解除武装。新阈值事件优先于清除；已捕获事务拒绝不撤销。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.DFX_CLEAR.WAIT_HIT
register_ref: apb_secure_demux.DFX_CLEAR.wait_hit
behavior: command
sw_behavior: WO；写一清WAIT_HIT或解除武装
hw_behavior: 新阈值事件优先于清除；已捕获事务拒绝不撤销
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.DFX_CLEAR.disarm

WO；写一清WAIT_HIT或解除武装。新阈值事件优先于清除；已捕获事务拒绝不撤销。竞争顺序：set_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.DFX_CLEAR.DISARM
register_ref: apb_secure_demux.DFX_CLEAR.disarm
behavior: command
sw_behavior: WO；写一清WAIT_HIT或解除武装
hw_behavior: 新阈值事件优先于清除；已捕获事务拒绝不撤销
collision: set_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INJECT_TARGET.port

RW；范围合法且无任何武装才可写。武装成功时另存armed_target；地址范围/主体检查均用完整数据字段。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INJECT_TARGET.PORT
register_ref: apb_secure_demux.INJECT_TARGET.port
behavior: control
sw_behavior: RW；范围合法且无任何武装才可写
hw_behavior: 武装成功时另存armed_target；地址范围/主体检查均用完整数据字段
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INJECT_TARGET.master

RW；范围合法且无任何武装才可写。武装成功时另存armed_target；地址范围/主体检查均用完整数据字段。竞争顺序：sw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INJECT_TARGET.MASTER
register_ref: apb_secure_demux.INJECT_TARGET.master
behavior: control
sw_behavior: RW；范围合法且无任何武装才可写
hw_behavior: 武装成功时另存armed_target；地址范围/主体检查均用完整数据字段
collision: sw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INJECT_CMD.synthetic

WO；忽略保留位后恰好一个有效位；arm需无现有武装；integrity需PARITY。合成事件在完成沿发出；武装只改变一次性注入状态；当前授权撤销优先返回未授权。竞争顺序：authorization_revoke_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INJECT_CMD.SYNTHETIC
register_ref: apb_secure_demux.INJECT_CMD.synthetic
behavior: command
sw_behavior: WO；忽略保留位后恰好一个有效位；arm需无现有武装；integrity需PARITY
hw_behavior: 合成事件在完成沿发出；武装只改变一次性注入状态；当前授权撤销优先返回未授权
collision: authorization_revoke_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

