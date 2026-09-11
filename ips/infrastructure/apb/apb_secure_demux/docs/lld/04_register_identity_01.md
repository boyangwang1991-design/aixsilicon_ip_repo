# identity 字段行为 1

字段名称是后续 SystemRDL 结构的引用契约；数组 p/m/w 分别代表合法端口、主体和记录字。结构范围/偏移不在本文重复。所有软件写均需基本 CSR 授权、对齐、全选通及访问类型检查；失败仅允许审计副作用。

## apb_secure_demux.IP_ID.value

RO；公开读取仅PUBLIC_ID_EN且数据读、身份有效并在域内。静态标识，只读返回合同常量。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.IP_ID.VALUE
register_ref: apb_secure_demux.IP_ID.value
behavior: status
sw_behavior: RO；公开读取仅PUBLIC_ID_EN且数据读、身份有效并在域内
hw_behavior: 静态标识，只读返回合同常量
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 恒定IP标识，不受复位改变
END_LLD_REG_META -->

## apb_secure_demux.VERSION.major

RO；同IP_ID授权。静态语义版本只读。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.VERSION.MAJOR
register_ref: apb_secure_demux.VERSION.major
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 静态语义版本只读
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 恒定1.0.0，不受复位改变
END_LLD_REG_META -->

## apb_secure_demux.VERSION.minor

RO；同IP_ID授权。静态语义版本只读。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.VERSION.MINOR
register_ref: apb_secure_demux.VERSION.minor
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 静态语义版本只读
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 恒定1.0.0，不受复位改变
END_LLD_REG_META -->

## apb_secure_demux.VERSION.patch

RO；同IP_ID授权。静态语义版本只读。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.VERSION.PATCH
register_ref: apb_secure_demux.VERSION.patch
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 静态语义版本只读
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 恒定1.0.0，不受复位改变
END_LLD_REG_META -->

## apb_secure_demux.CAP0.num_ports

RO；同IP_ID授权。实际elaboration参数镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP0.NUM_PORTS
register_ref: apb_secure_demux.CAP0.num_ports
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration参数镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

## apb_secure_demux.CAP0.num_masters

RO；同IP_ID授权。实际elaboration参数镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP0.NUM_MASTERS
register_ref: apb_secure_demux.CAP0.num_masters
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration参数镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

## apb_secure_demux.CAP0.addr_width

RO；同IP_ID授权。实际elaboration参数镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP0.ADDR_WIDTH
register_ref: apb_secure_demux.CAP0.addr_width
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration参数镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

## apb_secure_demux.CAP0.master_id_width

RO；同IP_ID授权。实际elaboration参数镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP0.MASTER_ID_WIDTH
register_ref: apb_secure_demux.CAP0.master_id_width
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration参数镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

## apb_secure_demux.CAP1.register_mode

RO；同IP_ID授权。实际elaboration开关/容量镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP1.REGISTER_MODE
register_ref: apb_secure_demux.CAP1.register_mode
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration开关/容量镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

## apb_secure_demux.CAP1.isolation

RO；同IP_ID授权。实际elaboration开关/容量镜像。竞争顺序：hw_wins。

<!-- LLD_REG_META
id: LLD.REG.APB_SECURE_DEMUX.CAP1.ISOLATION
register_ref: apb_secure_demux.CAP1.isolation
behavior: status
sw_behavior: RO；同IP_ID授权
hw_behavior: 实际elaboration开关/容量镜像
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 由配置确定，复位不改变
END_LLD_REG_META -->

