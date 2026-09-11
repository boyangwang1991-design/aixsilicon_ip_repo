# policy 字段行为 1

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.STATUS.integrity_fatal

RO；管理授权。各owner状态组合镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.STATUS.INTEGRITY_FATAL
register_ref: apb_secure_demux.STATUS.integrity_fatal
behavior: status
sw_behavior: RO；管理授权
hw_behavior: 各owner状态组合镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位后均零
END_LLD_REG_META -->

## apb_secure_demux.STATUS.global_lock

RO；管理授权。各owner状态组合镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.STATUS.GLOBAL_LOCK
register_ref: apb_secure_demux.STATUS.global_lock
behavior: status
sw_behavior: RO；管理授权
hw_behavior: 各owner状态组合镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位后均零
END_LLD_REG_META -->

## apb_secure_demux.STATUS.first_valid

RO；管理授权。各owner状态组合镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.STATUS.FIRST_VALID
register_ref: apb_secure_demux.STATUS.first_valid
behavior: status
sw_behavior: RO；管理授权
hw_behavior: 各owner状态组合镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位后均零
END_LLD_REG_META -->

## apb_secure_demux.STATUS.last_valid

RO；管理授权。各owner状态组合镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.STATUS.LAST_VALID
register_ref: apb_secure_demux.STATUS.last_valid
behavior: status
sw_behavior: RO；管理授权
hw_behavior: 各owner状态组合镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信复位后均零
END_LLD_REG_META -->

## apb_secure_demux.POLICY_VERSION.value

RO。仅成功COMMIT递增，模32位自然回绕。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.POLICY_VERSION.VALUE
register_ref: apb_secure_demux.POLICY_VERSION.value
behavior: atomic
sw_behavior: RO
hw_behavior: 仅成功COMMIT递增，模32位自然回绕
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.GLOBAL_LOCK.locked

RW1S；写一收紧，写零不变。POLICY更新互补编码，只能可信复位解锁。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.GLOBAL_LOCK.LOCKED
register_ref: apb_secure_demux.GLOBAL_LOCK.locked
behavior: lock
sw_behavior: RW1S；写一收紧，写零不变
hw_behavior: POLICY更新互补编码，只能可信复位解锁
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 合法解锁编码01，对软件可见0
END_LLD_REG_META -->

## apb_secure_demux.COMMIT_MASK.ports

WO；有效掩码非空且无越界，所有选中端口均未锁，GLOBAL未锁，无完整性错误才接受。同一完成沿复制所有选中shadow到active并更新校验；失败全保持。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COMMIT_MASK.PORTS
register_ref: apb_secure_demux.COMMIT_MASK.ports
behavior: atomic
sw_behavior: WO；有效掩码非空且无越界，所有选中端口均未锁，GLOBAL未锁，无完整性错误才接受
hw_behavior: 同一完成沿复制所有选中shadow到active并更新校验；失败全保持
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.COMMIT_STATUS.last_ok

RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态。commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COMMIT_STATUS.LAST_OK
register_ref: apb_secure_demux.COMMIT_STATUS.last_ok
behavior: status
sw_behavior: RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态
hw_behavior: commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.COMMIT_STATUS.last_fail

RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态。commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COMMIT_STATUS.LAST_FAIL
register_ref: apb_secure_demux.COMMIT_STATUS.last_fail
behavior: status
sw_behavior: RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态
hw_behavior: commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

## apb_secure_demux.COMMIT_STATUS.fail_reason

RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态。commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.COMMIT_STATUS.FAIL_REASON
register_ref: apb_secure_demux.COMMIT_STATUS.fail_reason
behavior: status
sw_behavior: RO；未通过管理授权/对齐/选通/存在性/访问类型的COMMIT不影响状态
hw_behavior: commit_attempt更新结果；诊断独立按掩码、全局锁、端口锁、完整性排序；失败端口只对端口锁有效，其余清零
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 可信 preset_ni 清零；不存在软件复位
END_LLD_REG_META -->

