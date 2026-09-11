# 参数的架构影响

参数值域与命名夹具以 19-PC 模型为准，本册不增加参数。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.OUTPUT_ISOLATION_EN
config_ref: PARAM.APB_SECURE_DEMUX.OUTPUT_ISOLATION_EN
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.ROUTE
architecture_effect: 选择未选中负载信号零隔离或允许广播，但控制及身份有效始终隔离。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

OUTPUT_ISOLATION_EN：选择未选中负载信号零隔离或允许广播，但控制及身份有效始终隔离。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.POLICY_PARITY_EN
config_ref: PARAM.APB_SECURE_DEMUX.POLICY_PARITY_EN
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.ACCESS
  - HLD.MOD.APB_SECURE_DEMUX.POLICY
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 裁剪存储保护与合成完整性注入；关闭时仍保持普通安全权限。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

POLICY_PARITY_EN：裁剪存储保护与合成完整性注入；关闭时仍保持普通安全权限。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.DFX_EN
config_ref: PARAM.APB_SECURE_DEMUX.DFX_EN
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.DFX
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 裁剪统计/观测/注入寄存器，不裁剪日志时间戳或普通权限。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

DFX_EN：裁剪统计/观测/注入寄存器，不裁剪日志时间戳或普通权限。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.PUBLIC_ID_EN
config_ref: PARAM.APB_SECURE_DEMUX.PUBLIC_ID_EN
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 控制基本信息公开数据读例外，不放宽管理主体验证。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

PUBLIC_ID_EN：控制基本信息公开数据读例外，不放宽管理主体验证。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.EVENT_FIFO_DEPTH
config_ref: PARAM.APB_SECURE_DEMUX.EVENT_FIFO_DEPTH
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.EVENTS
architecture_effect: 改变日志队列容量；零深度保留 FIRST/LAST 和状态读取，POP/HEAD 未实现。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

EVENT_FIFO_DEPTH：改变日志队列容量；零深度保留 FIRST/LAST 和状态读取，POP/HEAD 未实现。

<!-- HLD_CONFIG_META
id: HLD.CFG.APB_SECURE_DEMUX.MGMT_MASTER_MASK
config_ref: PARAM.APB_SECURE_DEMUX.MGMT_MASTER_MASK
affects:
  modules:
  - HLD.MOD.APB_SECURE_DEMUX.ACCESS
  - HLD.MOD.APB_SECURE_DEMUX.POLICY
  - HLD.MOD.APB_SECURE_DEMUX.CSR
architecture_effect: 按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

MGMT_MASTER_MASK：按参数合同扩展所列模块容量、接口或静态映射；不改变权限优先级、原子提交或事务顺序。

