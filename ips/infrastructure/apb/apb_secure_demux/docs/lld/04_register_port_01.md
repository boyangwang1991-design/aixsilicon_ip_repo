# port 字段行为 1

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.port[p].MAP_BASE.value

RO。PORT_BASE镜像、零扩展。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.MAP_BASE.VALUE
register_ref: apb_secure_demux.port[p].MAP_BASE.value
behavior: status
sw_behavior: RO
hw_behavior: PORT_BASE镜像、零扩展
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 对应实例参数不变
END_LLD_REG_META -->

## apb_secure_demux.port[p].MAP_LIMIT.value

RO。扩展运算BASE+SIZE-1的包含端点镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.MAP_LIMIT.VALUE
register_ref: apb_secure_demux.port[p].MAP_LIMIT.value
behavior: status
sw_behavior: RO
hw_behavior: 扩展运算BASE+SIZE-1的包含端点镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 对应实例参数不变
END_LLD_REG_META -->

## apb_secure_demux.port[p].PORT_LOCK.locked

RW1S；GLOBAL_LOCK后仍允许追加锁。成功置位不可逆；锁保护shadow、commit、reload。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.PORT_LOCK.LOCKED
register_ref: apb_secure_demux.port[p].PORT_LOCK.locked
behavior: lock
sw_behavior: RW1S；GLOBAL_LOCK后仍允许追加锁
hw_behavior: 成功置位不可逆；锁保护shadow、commit、reload
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 合法解锁编码01，对软件可见0
END_LLD_REG_META -->

## apb_secure_demux.port[p].CFG_SHADOW.enable

RW；全局/端口锁及完整性检查。shadow写不改变active；reload/commit分别整端口复制并同步校验。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.CFG_SHADOW.ENABLE
register_ref: apb_secure_demux.port[p].CFG_SHADOW.enable
behavior: shadow
sw_behavior: RW；全局/端口锁及完整性检查
hw_behavior: shadow写不改变active；reload/commit分别整端口复制并同步校验
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: RESET_PORT_CFG[p]，active和shadow一致
END_LLD_REG_META -->

## apb_secure_demux.port[p].CFG_SHADOW.instr_allow

RW；全局/端口锁及完整性检查。shadow写不改变active；reload/commit分别整端口复制并同步校验。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.CFG_SHADOW.INSTR_ALLOW
register_ref: apb_secure_demux.port[p].CFG_SHADOW.instr_allow
behavior: shadow
sw_behavior: RW；全局/端口锁及完整性检查
hw_behavior: shadow写不改变active；reload/commit分别整端口复制并同步校验
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: RESET_PORT_CFG[p]，active和shadow一致
END_LLD_REG_META -->

## apb_secure_demux.port[p].CFG_ACTIVE.enable

RO。shadow写不改变active；reload/commit分别整端口复制并同步校验。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.CFG_ACTIVE.ENABLE
register_ref: apb_secure_demux.port[p].CFG_ACTIVE.enable
behavior: atomic
sw_behavior: RO
hw_behavior: shadow写不改变active；reload/commit分别整端口复制并同步校验
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: RESET_PORT_CFG[p]，active和shadow一致
END_LLD_REG_META -->

## apb_secure_demux.port[p].CFG_ACTIVE.instr_allow

RO。shadow写不改变active；reload/commit分别整端口复制并同步校验。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.CFG_ACTIVE.INSTR_ALLOW
register_ref: apb_secure_demux.port[p].CFG_ACTIVE.instr_allow
behavior: atomic
sw_behavior: RO
hw_behavior: shadow写不改变active；reload/commit分别整端口复制并同步校验
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: RESET_PORT_CFG[p]，active和shadow一致
END_LLD_REG_META -->

## apb_secure_demux.port[p].PERM_SHADOW[m].permission

RW；全局/端口锁及完整性检查。每主体仅存8位；写高位忽略；复制时同步校验，索引p/m先检查配置域。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.PERM_SHADOW.PERMISSION
register_ref: apb_secure_demux.port[p].PERM_SHADOW[m].permission
behavior: shadow
sw_behavior: RW；全局/端口锁及完整性检查
hw_behavior: 每主体仅存8位；写高位忽略；复制时同步校验，索引p/m先检查配置域
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: RESET_PERM[p][m]，active和shadow一致
END_LLD_REG_META -->

## apb_secure_demux.port[p].PERM_ACTIVE[m].permission

RO。每主体仅存8位；写高位忽略；复制时同步校验，索引p/m先检查配置域。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.PERM_ACTIVE.PERMISSION
register_ref: apb_secure_demux.port[p].PERM_ACTIVE[m].permission
behavior: atomic
sw_behavior: RO
hw_behavior: 每主体仅存8位；写高位忽略；复制时同步校验，索引p/m先检查配置域
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: RESET_PERM[p][m]，active和shadow一致
END_LLD_REG_META -->

## apb_secure_demux.port[p].SUCCESS_COUNT.value

RO；仅DFX_EN及双重授权。计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量。竞争顺序：clear_then_increment_or_max。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.PORT.SUCCESS_COUNT.VALUE
register_ref: apb_secure_demux.port[p].SUCCESS_COUNT.value
behavior: counter
sw_behavior: RO；仅DFX_EN及双重授权
hw_behavior: 计数语义见03_dfx；WAIT_MAX完成沿取max，其余对应事件饱和增量
collision: clear_then_increment_or_max
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

