# dfx 字段行为 2

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.INJECT_CMD.arm_deny

WO；忽略保留位后恰好一个有效位；arm需无现有武装；integrity需PARITY。合成事件在完成沿发出；武装只改变一次性注入状态；当前授权撤销优先返回未授权。竞争顺序：authorization_revoke_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INJECT_CMD.ARM_DENY
register_ref: apb_secure_demux.INJECT_CMD.arm_deny
behavior: command
sw_behavior: WO；忽略保留位后恰好一个有效位；arm需无现有武装；integrity需PARITY
hw_behavior: 合成事件在完成沿发出；武装只改变一次性注入状态；当前授权撤销优先返回未授权
collision: authorization_revoke_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INJECT_CMD.arm_integrity

WO；忽略保留位后恰好一个有效位；arm需无现有武装；integrity需PARITY。合成事件在完成沿发出；武装只改变一次性注入状态；当前授权撤销优先返回未授权。竞争顺序：authorization_revoke_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INJECT_CMD.ARM_INTEGRITY
register_ref: apb_secure_demux.INJECT_CMD.arm_integrity
behavior: command
sw_behavior: WO；忽略保留位后恰好一个有效位；arm需无现有武装；integrity需PARITY
hw_behavior: 合成事件在完成沿发出；武装只改变一次性注入状态；当前授权撤销优先返回未授权
collision: authorization_revoke_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

