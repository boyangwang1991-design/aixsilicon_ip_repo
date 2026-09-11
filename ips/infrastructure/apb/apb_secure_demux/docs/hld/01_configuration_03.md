# 参数的架构影响

参数值域与命名夹具以 19-PC 模型为准，本册不增加参数。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.CSR_BASE
config_ref: PARAM.APB_SECURE_DEMUX.CSR_BASE
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.DECODE
  - HLD.MOD.APB_SECURE_DEMUX.ROUTE
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

CSR_BASE：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.PORT_BASE
config_ref: PARAM.APB_SECURE_DEMUX.PORT_BASE
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.DECODE
  - HLD.MOD.APB_SECURE_DEMUX.ROUTE
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

PORT_BASE：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.PORT_SIZE
config_ref: PARAM.APB_SECURE_DEMUX.PORT_SIZE
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.DECODE
  - HLD.MOD.APB_SECURE_DEMUX.ROUTE
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

PORT_SIZE：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.RESET_PORT_CFG
config_ref: PARAM.APB_SECURE_DEMUX.RESET_PORT_CFG
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.ACCESS
  - HLD.MOD.APB_SECURE_DEMUX.POLICY
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

RESET_PORT_CFG：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.RESET_PERM
config_ref: PARAM.APB_SECURE_DEMUX.RESET_PERM
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.ACCESS
  - HLD.MOD.APB_SECURE_DEMUX.POLICY
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

RESET_PERM：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

