# Watchdog：PC 结构化参数表示

本册将已冻结的 AUTO_START_MASK / NO_STOP_MASK / HARD_CFG_LOCK_MASK / DEFAULT_CFG
要求补成可抽取类型；不增删需求或改变原合法空间。来源是同目录 configuration_profiles
中的四条要求。通道位图为整数编码，宽度由 NUM_CHANNELS 限定。
DEFAULT_CFG 在配置输入中采用逐通道数组和命名属性，不在这里定义寄存器 offset/bit。
LLD/寄存器适配负责将命名属性映射到实际硬件字段，不能反向改变需求。

## 通道位图

<!-- PARAM_META
name: AUTO_START_MASK
type: int
category: compile_time
default: 0
domain:
  min: 0
  max_expr: (2 ** NUM_CHANNELS) - 1
depends_on: []
description: NUM_CHANNELS 位 AUTO_START_MASK，不得引用未实现通道
END_PARAM_META -->

<!-- PARAM_META
name: NO_STOP_MASK
type: int
category: compile_time
default: 1
domain:
  min: 0
  max_expr: (2 ** NUM_CHANNELS) - 1
depends_on: []
description: NUM_CHANNELS 位 NO_STOP_MASK，不得引用未实现通道
default_expr: (2 ** NUM_CHANNELS) - 1
END_PARAM_META -->

<!-- PARAM_META
name: HARD_CFG_LOCK_MASK
type: int
category: compile_time
default: 0
domain:
  min: 0
  max_expr: (2 ** NUM_CHANNELS) - 1
depends_on: []
description: NUM_CHANNELS 位 HARD_CFG_LOCK_MASK，不得引用未实现通道
END_PARAM_META -->

