# 参数机读合同

本册仅将已批准参数范围及依赖转为 19-PC 所需注释，不改变产品行为。
集成必填字段的 default 只用于有界验证夹具，不允许 RTL 使用这些地址或主体掩码作为隐式产品默认值。
PORT_BASE 长度与端口数不匹配的自动组合由类型检查拒绝；端口边界由显式命名夹具完整提供。

## OUTPUT_ISOLATION_EN

契约 §2 的布尔裁剪/模式参数。

<!-- PARAM_META
name: OUTPUT_ISOLATION_EN
type: bool
domain: [false, true]
default: true
category: compile_time
description: 契约 §2 的布尔裁剪/模式参数
END_PARAM_META -->

## POLICY_PARITY_EN

契约 §2 的布尔裁剪/模式参数。

<!-- PARAM_META
name: POLICY_PARITY_EN
type: bool
domain: [false, true]
default: true
category: compile_time
description: 契约 §2 的布尔裁剪/模式参数
END_PARAM_META -->

## DFX_EN

契约 §2 的布尔裁剪/模式参数。

<!-- PARAM_META
name: DFX_EN
type: bool
domain: [false, true]
default: true
category: compile_time
description: 契约 §2 的布尔裁剪/模式参数
END_PARAM_META -->

## PUBLIC_ID_EN

契约 §2 的布尔裁剪/模式参数。

<!-- PARAM_META
name: PUBLIC_ID_EN
type: bool
domain: [false, true]
default: true
category: compile_time
description: 契约 §2 的布尔裁剪/模式参数
END_PARAM_META -->

## EVENT_FIFO_DEPTH

事件 FIFO 深度，0 表示不实现。

<!-- PARAM_META
name: EVENT_FIFO_DEPTH
type: int
domain:
  min: 0
  max: 32
default: 8
category: structural
description: 事件 FIFO 深度，0 表示不实现
risk_values: [1]
END_PARAM_META -->

## MGMT_MASTER_MASK

集成必填；default=1 仅是 PC 仿真夹具主体0。

<!-- PARAM_META
name: MGMT_MASTER_MASK
type: int
domain:
  min: 1
  max_expr: (2 ** NUM_MASTERS) - 1
default: 1
category: structural
description: 集成必填；default=1 仅是 PC 仿真夹具主体0
integration_required: true
END_PARAM_META -->

