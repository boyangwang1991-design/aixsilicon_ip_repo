# GPIO 参数契约：定义 1

generation_profile: sv

本册为 LRS CFG 的机读定义，取值来自 contract §2.1；负数和高于 N_GPIO 的位均非法。
128 位最大值用四段不超过 64 的指数相乘表达，与 2^N_GPIO−1 完全等价。

## N_GPIO

引脚数。

<!-- PARAM_META
name: N_GPIO
type: int
domain:
  min: 1
  max: 128
default: 32
category: compile_time
description: 引脚数
risk_values:
- 8
- 31
- 33
- 64
END_PARAM_META -->

## SYNC_STAGES

主输入同步级数。

<!-- PARAM_META
name: SYNC_STAGES
type: int
domain:
  min: 2
  max: 4
default: 2
category: compile_time
description: 主输入同步级数
END_PARAM_META -->

## INPUT_CAP_MASK

N_GPIO 位无符号位图；随 N_GPIO 检查宽度。

<!-- PARAM_META
name: INPUT_CAP_MASK
type: int
domain:
  min: 0
  max_expr: (2 ** (N_GPIO // 4)) ** 3 * (2 ** (N_GPIO - 3 * (N_GPIO // 4))) - 1
default: 4294967295
category: compile_time
description: N_GPIO 位无符号位图；随 N_GPIO 检查宽度
default_expr: (2 ** (N_GPIO // 4)) ** 3 * (2 ** (N_GPIO - 3 * (N_GPIO // 4))) - 1
END_PARAM_META -->

## OUTPUT_CAP_MASK

N_GPIO 位无符号位图；随 N_GPIO 检查宽度。

<!-- PARAM_META
name: OUTPUT_CAP_MASK
type: int
domain:
  min: 0
  max_expr: (2 ** (N_GPIO // 4)) ** 3 * (2 ** (N_GPIO - 3 * (N_GPIO // 4))) - 1
default: 4294967295
category: compile_time
description: N_GPIO 位无符号位图；随 N_GPIO 检查宽度
default_expr: (2 ** (N_GPIO // 4)) ** 3 * (2 ** (N_GPIO - 3 * (N_GPIO // 4))) - 1
END_PARAM_META -->

## RESET_OUT

N_GPIO 位无符号位图；随 N_GPIO 检查宽度。

<!-- PARAM_META
name: RESET_OUT
type: int
domain:
  min: 0
  max_expr: (2 ** (N_GPIO // 4)) ** 3 * (2 ** (N_GPIO - 3 * (N_GPIO // 4))) - 1
default: 0
category: compile_time
description: N_GPIO 位无符号位图；随 N_GPIO 检查宽度
END_PARAM_META -->

## RESET_OE

N_GPIO 位无符号位图；随 N_GPIO 检查宽度。

<!-- PARAM_META
name: RESET_OE
type: int
domain:
  min: 0
  max_expr: (2 ** (N_GPIO // 4)) ** 3 * (2 ** (N_GPIO - 3 * (N_GPIO // 4))) - 1
default: 0
category: compile_time
description: N_GPIO 位无符号位图；随 N_GPIO 检查宽度
END_PARAM_META -->

## RESET_IN_EN

N_GPIO 位无符号位图；随 N_GPIO 检查宽度。

<!-- PARAM_META
name: RESET_IN_EN
type: int
domain:
  min: 0
  max_expr: (2 ** (N_GPIO // 4)) ** 3 * (2 ** (N_GPIO - 3 * (N_GPIO // 4))) - 1
default: 4294967295
category: compile_time
description: N_GPIO 位无符号位图；随 N_GPIO 检查宽度
default_expr: INPUT_CAP_MASK
END_PARAM_META -->

## HW_SAFE_OUT

N_GPIO 位无符号位图；随 N_GPIO 检查宽度。

<!-- PARAM_META
name: HW_SAFE_OUT
type: int
domain:
  min: 0
  max_expr: (2 ** (N_GPIO // 4)) ** 3 * (2 ** (N_GPIO - 3 * (N_GPIO // 4))) - 1
default: 0
category: compile_time
description: N_GPIO 位无符号位图；随 N_GPIO 检查宽度
END_PARAM_META -->

## HW_SAFE_OE

N_GPIO 位无符号位图；随 N_GPIO 检查宽度。

<!-- PARAM_META
name: HW_SAFE_OE
type: int
domain:
  min: 0
  max_expr: (2 ** (N_GPIO // 4)) ** 3 * (2 ** (N_GPIO - 3 * (N_GPIO // 4))) - 1
default: 0
category: compile_time
description: N_GPIO 位无符号位图；随 N_GPIO 检查宽度
END_PARAM_META -->

## N_IRQ_GROUPS

IRQ 输出分组数。

<!-- PARAM_META
name: N_IRQ_GROUPS
type: int
domain:
  min: 1
  max: 4
default: 1
category: compile_time
description: IRQ 输出分组数
END_PARAM_META -->

