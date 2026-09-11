# Watchdog：参数对架构的影响

每个 config_ref 引用 PC canonical 的参数 ID；产品配置引用同一参数空间，不另发明旋钮。

## DEFAULT_CFG

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.DEFAULT_CFG
config_ref: PARAM.WATCHDOG.DEFAULT_CFG
affects:
  modules:
  - HLD.MOD.WATCHDOG.BUS
  - HLD.MOD.WATCHDOG.CHANNEL
  - HLD.MOD.WATCHDOG.SAFETY
architecture_effect: 按每通道完整逻辑配置初始化活动/暂存与保护值；客户端默认及覆盖项在构建时展开并验证。
req_ref:
- LRS.CFG.WATCHDOG.DEFAULT_CFG.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

按每通道完整逻辑配置初始化活动/暂存与保护值；客户端默认及覆盖项在构建时展开并验证。

## AUTO_START_MASK

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.AUTO_START_MASK
config_ref: PARAM.WATCHDOG.AUTO_START_MASK
affects:
  modules:
  - HLD.MOD.WATCHDOG.INTEGRATION
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 选定 POR 释放后独立启动通道，必须有合法 DEFAULT_CFG，不依赖 pclk。
req_ref:
- LRS.CFG.WATCHDOG.AUTO_START_MASK.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

选定 POR 释放后独立启动通道，必须有合法 DEFAULT_CFG，不依赖 pclk。

## NO_STOP_MASK

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.NO_STOP_MASK
config_ref: PARAM.WATCHDOG.NO_STOP_MASK
affects:
  modules:
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 决定启动后不可软件停止的通道，动态默认覆盖全部已实现通道。
req_ref:
- LRS.CFG.WATCHDOG.NO_STOP_MASK.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

决定启动后不可软件停止的通道，动态默认覆盖全部已实现通道。

## HARD_CFG_LOCK_MASK

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.HARD_CFG_LOCK_MASK
config_ref: PARAM.WATCHDOG.HARD_CFG_LOCK_MASK
affects:
  modules:
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 设定 POR 配置锁初值；锁只影响配置控制，不取消已有合法服务。
req_ref:
- LRS.CFG.WATCHDOG.HARD_CFG_LOCK_MASK.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

设定 POR 配置锁初值；锁只影响配置控制，不取消已有合法服务。

## NUM_CHANNELS

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.NUM_CHANNELS
config_ref: PARAM.WATCHDOG.NUM_CHANNELS
affects:
  modules:
  - HLD.MOD.WATCHDOG.INTEGRATION
  - HLD.MOD.WATCHDOG.BUS
  - HLD.MOD.WATCHDOG.CHANNEL
architecture_effect: 复制独立监督通道与逐通道状态/快照，扩大选择与请求汇总；不得改变单通道计时周期。
req_ref:
- LRS.CFG.WATCHDOG.NUM_CHANNELS.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

复制独立监督通道与逐通道状态/快照，扩大选择与请求汇总；不得改变单通道计时周期。

## COUNTER_WIDTH

<!-- HLD_CONFIG_META
id: HLD.CFG.WATCHDOG.COUNTER_WIDTH
config_ref: PARAM.WATCHDOG.COUNTER_WIDTH
affects:
  modules:
  - HLD.MOD.WATCHDOG.CHANNEL
  - HLD.MOD.WATCHDOG.SAFETY
architecture_effect: 调整计时/阈值/Deadline 和独立保护路径位宽；软件高低字容器与地址保持稳定，拒绝高于实现宽度的配置。
req_ref:
- LRS.CFG.WATCHDOG.COUNTER_WIDTH.001
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

调整计时/阈值/Deadline 和独立保护路径位宽；软件高低字容器与地址保持稳定，拒绝高于实现宽度的配置。

