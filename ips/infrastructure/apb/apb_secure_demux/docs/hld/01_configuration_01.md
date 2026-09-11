# 参数的架构影响

参数值域与命名夹具以 19-PC 模型为准，本册不增加参数。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.NUM_PORTS
config_ref: PARAM.APB_SECURE_DEMUX.NUM_PORTS
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.DECODE
  - HLD.MOD.APB_SECURE_DEMUX.ROUTE
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

NUM_PORTS：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.ADDR_WIDTH
config_ref: PARAM.APB_SECURE_DEMUX.ADDR_WIDTH
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.DECODE
  - HLD.MOD.APB_SECURE_DEMUX.ROUTE
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

ADDR_WIDTH：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.DATA_WIDTH
config_ref: PARAM.APB_SECURE_DEMUX.DATA_WIDTH
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.FRONTEND
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

DATA_WIDTH：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.MASTER_ID_WIDTH
config_ref: PARAM.APB_SECURE_DEMUX.MASTER_ID_WIDTH
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.ACCESS
  - HLD.MOD.APB_SECURE_DEMUX.POLICY
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

MASTER_ID_WIDTH：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.NUM_MASTERS
config_ref: PARAM.APB_SECURE_DEMUX.NUM_MASTERS
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.ACCESS
  - HLD.MOD.APB_SECURE_DEMUX.POLICY
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

NUM_MASTERS：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.REGISTER_MODE
config_ref: PARAM.APB_SECURE_DEMUX.REGISTER_MODE
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.ROUTE
architecture_effect: 选择直接组合准入转发或请求寄存转发，不改变本地响应延迟。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

REGISTER_MODE：选择直接组合准入转发或请求寄存转发，不改变本地响应延迟。

