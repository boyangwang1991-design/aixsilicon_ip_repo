# 参数机读合同

本册仅将已批准参数范围及依赖转为 19-PC 所需注释，不改变产品行为。
集成必填字段的 default 只用于有界验证夹具，不允许 RTL 使用这些地址或主体掩码作为隐式产品默认值。
PORT_BASE 长度与端口数不匹配的自动组合由类型检查拒绝；端口边界由显式命名夹具完整提供。

## NUM_PORTS

输出端口数。

<!-- PARAM_META
name: NUM_PORTS
type: int
domain:
  min: 1
  max: 32
default: 8
category: structural
description: 输出端口数
risk_values: [3]
END_PARAM_META -->

## ADDR_WIDTH

字节地址位宽。

<!-- PARAM_META
name: ADDR_WIDTH
type: int
domain:
  min: 16
  max: 32
default: 32
category: structural
description: 字节地址位宽
END_PARAM_META -->

## DATA_WIDTH

固定 32 bit 数据。

<!-- PARAM_META
name: DATA_WIDTH
type: int
domain:
  min: 32
  max: 32
default: 32
category: structural
description: 固定 32 bit 数据
END_PARAM_META -->

## MASTER_ID_WIDTH

可信身份完整输入位宽。

<!-- PARAM_META
name: MASTER_ID_WIDTH
type: int
domain:
  min: 1
  max: 16
default: 4
category: structural
description: 可信身份完整输入位宽
END_PARAM_META -->

## NUM_MASTERS

主体表项数。

<!-- PARAM_META
name: NUM_MASTERS
type: int
domain:
  min: 1
  max: 64
default: 16
category: structural
description: 主体表项数
risk_values: [3]
END_PARAM_META -->

## REGISTER_MODE

契约 §2 的布尔裁剪/模式参数。

<!-- PARAM_META
name: REGISTER_MODE
type: bool
domain: [false, true]
default: false
category: compile_time
description: 契约 §2 的布尔裁剪/模式参数
END_PARAM_META -->

