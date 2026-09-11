# 参数机读合同

本册仅将已批准参数范围及依赖转为 19-PC 所需注释，不改变产品行为。
集成必填字段的 default 只用于有界验证夹具，不允许 RTL 使用这些地址或主体掩码作为隐式产品默认值。
PORT_BASE 长度与端口数不匹配的自动组合由类型检查拒绝；端口边界由显式命名夹具完整提供。

## CSR_BASE

集成必填；default=0x4000 仅为 PC 仿真夹具。

<!-- PARAM_META
name: CSR_BASE
type: int
domain:
  schema: inline
schema:
  type: integer
  minimum: 0
  maximum: 4294967295
default: 16384
category: structural
description: 集成必填；default=0x4000 仅为 PC 仿真夹具
integration_required: true
END_PARAM_META -->

## PORT_BASE

集成必填；PC 夹具地址，按端口顺序。

<!-- PARAM_META
name: PORT_BASE
type: array
domain:
  schema: inline
default: [256, 512, 768, 1024, 1280, 1536, 1792, 2048]
category: structural
description: 集成必填；PC 夹具地址，按端口顺序
schema:
  type: array
  items:
    type: integer
    minimum: 0
    maximum: 4294967295
length_expr: NUM_PORTS
integration_required: true
END_PARAM_META -->

## PORT_SIZE

集成必填；PC 夹具长度为 256 字节。

<!-- PARAM_META
name: PORT_SIZE
type: array
domain:
  schema: inline
default: [256]
category: structural
description: 集成必填；PC 夹具长度为 256 字节
schema:
  type: array
  items:
    type: integer
    minimum: 0
    maximum: 4294967296
length_expr: NUM_PORTS
repeat_default_expr: NUM_PORTS
integration_required: true
END_PARAM_META -->

## RESET_PORT_CFG

逐端口复位配置，默认禁止。

<!-- PARAM_META
name: RESET_PORT_CFG
type: array
domain:
  schema: inline
default: [0]
category: structural
description: 逐端口复位配置，默认禁止
schema:
  type: array
  items:
    type: integer
    minimum: 0
    maximum: 3
length_expr: NUM_PORTS
repeat_default_expr: NUM_PORTS
END_PARAM_META -->

## RESET_PERM

二维权限按 p*NUM_MASTERS+m 扁平序列化；SV 对外仍按端口/主体表。

<!-- PARAM_META
name: RESET_PERM
type: array
domain:
  schema: inline
default: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
category: structural
description: 二维权限按 p*NUM_MASTERS+m 扁平序列化；SV 对外仍按端口/主体表
schema:
  type: array
  items:
    type: integer
    minimum: 0
    maximum: 255
length_expr: NUM_PORTS * NUM_MASTERS
END_PARAM_META -->

