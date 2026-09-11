# GPIO 参数契约：定义 2

generation_profile: sv

本册为 LRS CFG 的机读定义，取值来自 contract §2.1；负数和高于 N_GPIO 的位均非法。
128 位最大值用四段不超过 64 的指数相乘表达，与 2^N_GPIO−1 完全等价。

## OUT_INV_EN

静态功能或启动策略开关。

<!-- PARAM_META
name: OUT_INV_EN
type: int
domain:
- 0
- 1
default: 1
category: compile_time
description: 静态功能或启动策略开关
END_PARAM_META -->

## AON_WAKE_EN

静态功能或启动策略开关。

<!-- PARAM_META
name: AON_WAKE_EN
type: int
domain:
- 0
- 1
default: 1
category: compile_time
description: 静态功能或启动策略开关
END_PARAM_META -->

## SNAPSHOT_EN

静态功能或启动策略开关。

<!-- PARAM_META
name: SNAPSHOT_EN
type: int
domain:
- 0
- 1
default: 1
category: compile_time
description: 静态功能或启动策略开关
END_PARAM_META -->

## STRAP_EN

静态功能或启动策略开关。

<!-- PARAM_META
name: STRAP_EN
type: int
domain:
- 0
- 1
default: 1
category: compile_time
description: 静态功能或启动策略开关
END_PARAM_META -->

## DIAG_EN

静态功能或启动策略开关。

<!-- PARAM_META
name: DIAG_EN
type: int
domain:
- 0
- 1
default: 1
category: compile_time
description: 静态功能或启动策略开关
END_PARAM_META -->

## ACCESS_CTRL_EN

静态功能或启动策略开关。

<!-- PARAM_META
name: ACCESS_CTRL_EN
type: int
domain:
- 0
- 1
default: 1
category: compile_time
description: 静态功能或启动策略开关
END_PARAM_META -->

## CFG_PARITY_EN

静态功能或启动策略开关。

<!-- PARAM_META
name: CFG_PARITY_EN
type: int
domain:
- 0
- 1
default: 0
category: compile_time
description: 静态功能或启动策略开关
END_PARAM_META -->

## BOOT_SECURE_ONLY

静态功能或启动策略开关。

<!-- PARAM_META
name: BOOT_SECURE_ONLY
type: int
domain:
- 0
- 1
default: 1
category: compile_time
description: 静态功能或启动策略开关
END_PARAM_META -->

## BOOT_PRIV_ONLY

静态功能或启动策略开关。

<!-- PARAM_META
name: BOOT_PRIV_ONLY
type: int
domain:
- 0
- 1
default: 1
category: compile_time
description: 静态功能或启动策略开关
END_PARAM_META -->

## EVENT_FIFO_DEPTH

FIFO 记录深度；0 表示裁剪。

<!-- PARAM_META
name: EVENT_FIFO_DEPTH
type: int
domain:
- 0
- 4
- 8
- 16
- 32
- 64
default: 16
category: compile_time
description: FIFO 记录深度；0 表示裁剪
END_PARAM_META -->

