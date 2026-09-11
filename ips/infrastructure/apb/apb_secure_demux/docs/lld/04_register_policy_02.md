# policy 字段行为 2

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.COMMIT_STATUS.fail_port

RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态。commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COMMIT_STATUS.FAIL_PORT
register_ref: apb_secure_demux.COMMIT_STATUS.fail_port
behavior: status
sw_behavior: RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态
hw_behavior: commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.COMMIT_STATUS.fail_port_valid

RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态。commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COMMIT_STATUS.FAIL_PORT_VALID
register_ref: apb_secure_demux.COMMIT_STATUS.fail_port_valid
behavior: status
sw_behavior: RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态
hw_behavior: commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.SHADOW_RELOAD.ports

WO；同提交掩码/锁/完整性检查。同沿所选active复制到shadow和校验；不增加版本。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.SHADOW_RELOAD.PORTS
register_ref: apb_secure_demux.SHADOW_RELOAD.ports
behavior: atomic
sw_behavior: WO；同提交掩码/锁/完整性检查
hw_behavior: 同沿所选active复制到shadow和校验；不增加版本
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTEGRITY_STATUS.fatal

RO；PARITY关闭时读零。首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTEGRITY_STATUS.FATAL
register_ref: apb_secure_demux.INTEGRITY_STATUS.fatal
behavior: sticky
sw_behavior: RO；PARITY关闭时读零
hw_behavior: 首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTEGRITY_STATUS.location_valid

RO；PARITY关闭时读零。首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTEGRITY_STATUS.LOCATION_VALID
register_ref: apb_secure_demux.INTEGRITY_STATUS.location_valid
behavior: sticky
sw_behavior: RO；PARITY关闭时读零
hw_behavior: 首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTEGRITY_STATUS.port

RO；PARITY关闭时读零。首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTEGRITY_STATUS.PORT
register_ref: apb_secure_demux.INTEGRITY_STATUS.port
behavior: sticky
sw_behavior: RO；PARITY关闭时读零
hw_behavior: 首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTEGRITY_STATUS.master

RO；PARITY关闭时读零。首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTEGRITY_STATUS.MASTER
register_ref: apb_secure_demux.INTEGRITY_STATUS.master
behavior: sticky
sw_behavior: RO；PARITY关闭时读零
hw_behavior: 首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.INTEGRITY_STATUS.location_type

RO；PARITY关闭时读零。首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.INTEGRITY_STATUS.LOCATION_TYPE
register_ref: apb_secure_demux.INTEGRITY_STATUS.location_type
behavior: sticky
sw_behavior: RO；PARITY关闭时读零
hw_behavior: 首次检测锁存FATAL及优先位置；MASTER仅PERM位置有效；global位置PORT无效清零；不覆盖首个位置
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

