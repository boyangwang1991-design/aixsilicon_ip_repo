# identity 字段行为 2

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.CAP1.parity

RO；同IP_ID授权。实际elaboration开关/容量镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP1.PARITY
register_ref: apb_secure_demux.CAP1.parity
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration开关/容量镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

## apb_secure_demux.CAP1.dfx

RO；同IP_ID授权。实际elaboration开关/容量镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP1.DFX
register_ref: apb_secure_demux.CAP1.dfx
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration开关/容量镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

## apb_secure_demux.CAP1.public_id

RO；同IP_ID授权。实际elaboration开关/容量镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP1.PUBLIC_ID
register_ref: apb_secure_demux.CAP1.public_id
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration开关/容量镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

## apb_secure_demux.CAP1.fifo_depth

RO；同IP_ID授权。实际elaboration开关/容量镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP1.FIFO_DEPTH
register_ref: apb_secure_demux.CAP1.fifo_depth
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration开关/容量镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

## apb_secure_demux.MGMT_MASK_LO.mask

RO；管理授权。固定掩码低字，未实现主体补零。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.MGMT_MASK_LO.MASK
register_ref: apb_secure_demux.MGMT_MASK_LO.mask
behavior: status
sw_behavior: RO；管理授权
hw_behavior: 固定掩码低字，未实现主体补零
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由MGMT_MASTER_MASK决定
END_LLD_REG_META -->

## apb_secure_demux.MGMT_MASK_HI.mask

RO；管理授权。固定掩码高字，未实现主体补零。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.MGMT_MASK_HI.MASK
register_ref: apb_secure_demux.MGMT_MASK_HI.mask
behavior: status
sw_behavior: RO；管理授权
hw_behavior: 固定掩码高字，未实现主体补零
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由MGMT_MASTER_MASK决定
END_LLD_REG_META -->

