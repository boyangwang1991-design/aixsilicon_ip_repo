# APB Demux — 配置需求（CFG）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 0. 配置模型元数据

generation_profile: sv

### 0.1 命名配置（CONFIG_META）

<!-- CONFIG_META
id: CFG_BASE
purpose: "基础配置（默认参数，最小面积最低延迟）"
values:
  NUM_SLAVES: 4
  ADDR_WIDTH: 32
  DATA_WIDTH: 32
  APB_PROFILE: true
  ADDR_REMAP_ENABLE: false
  TIMEOUT_ENABLE: false
  OUTPUT_REGISTER: false
END_CONFIG_META -->

<!-- CONFIG_META
id: CFG_TIMEOUT
purpose: "使能 timeout 的配置"
values:
  NUM_SLAVES: 4
  TIMEOUT_ENABLE: true
  TIMEOUT_CYCLES: 16
  OUTPUT_REGISTER: false
END_CONFIG_META -->

<!-- CONFIG_META
id: CFG_PIPELINED
purpose: "插入 response register 的高频配置"
values:
  NUM_SLAVES: 8
  OUTPUT_REGISTER: true
  TIMEOUT_ENABLE: false
END_CONFIG_META -->

### 0.2 跨参数约束（CONSTRAINT_META）

<!-- CONSTRAINT_META
- "NUM_SLAVES > 0"
- "TIMEOUT_ENABLE == true -> TIMEOUT_CYCLES > 0"
END_CONSTRAINT_META -->

---

## 1. 配置需求 / Configuration Requirements

### 1.1 下游端口数量参数

#### LRS.CFG.APB_DEMUX.01.001 下游端口数量参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.01.001
category: CFG
feature: num_slaves
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

| 参数名 | 类型 | 合法值域 | 默认值 | 类别 | 约束 |
|--------|------|----------|--------|------|------|
| `NUM_SLAVES` | int | [1, 2, 4, 8, 16] | 4 | compile_time | NUM_SLAVES > 0 |

#### Requirement

IP 应提供可参数化的下游端口数量 `NUM_SLAVES`，默认值为 4，用于确定下游 APB
Master-facing interface 的数量。

#### Acceptance Criteria

- `NUM_SLAVES = 1/2/4/8/16` 均可合法实例化；
- 下游端口数量与参数一致。

---

### 1.2 地址宽度参数

#### LRS.CFG.APB_DEMUX.01.002 地址宽度参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.01.002
category: CFG
feature: addr_width
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

| 参数名 | 类型 | 合法值域 | 默认值 | 类别 | 约束 |
|--------|------|----------|--------|------|------|
| `ADDR_WIDTH` | int | 16..64 | 32 | compile_time | 无 |

#### Requirement

IP 应提供可参数化的地址宽度 `ADDR_WIDTH`，默认值为 32，用于确定 `PADDR`、
`BASE_ADDR`、`ADDR_MASK` 的位宽。

#### Acceptance Criteria

- `ADDR_WIDTH` 可配置且影响所有地址相关信号位宽。

---

### 1.3 数据宽度参数

#### LRS.CFG.APB_DEMUX.01.003 数据宽度参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.01.003
category: CFG
feature: data_width
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

| 参数名 | 类型 | 合法值域 | 默认值 | 类别 | 约束 |
|--------|------|----------|--------|------|------|
| `DATA_WIDTH` | int | [8, 16, 32, 64, 128] | 32 | compile_time | 无 |

#### Requirement

IP 应提供可参数化的数据宽度 `DATA_WIDTH`，默认值为 32，用于确定 `PWDATA`/
`PRDATA` 位宽。

#### Acceptance Criteria

- `DATA_WIDTH` 可配置且影响 `PWDATA`/`PRDATA` 位宽。

---

### 1.4 地址映射配置

#### LRS.CFG.APB_DEMUX.02.001 基地址数组参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.02.001
category: CFG
feature: base_addr
priority: P0
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

IP 应提供可参数化的下游端口基地址数组 `BASE_ADDR[NUM_SLAVES]`，每个下游端口
拥有独立的基地址。

#### Acceptance Criteria

- 每个下游端口可配置独立基地址；
- 基地址数组长度与 `NUM_SLAVES` 一致。

---

#### LRS.CFG.APB_DEMUX.02.002 地址掩码数组参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.02.002
category: CFG
feature: addr_mask
priority: P0
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

IP 应提供可参数化的地址掩码数组 `ADDR_MASK[NUM_SLAVES]`，用于定义每个下游
端口的地址窗口。

#### Acceptance Criteria

- 每个下游端口可配置独立地址掩码；
- 地址掩码数组长度与 `NUM_SLAVES` 一致；
- 推荐内部转换为 `BASE_ADDR + ADDR_MASK` 形式进行地址译码。

---

### 1.5 可选特性参数

#### LRS.CFG.APB_DEMUX.03.001 地址重映射使能参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.03.001
category: CFG
feature: addr_remap_enable
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

| 参数名 | 类型 | 合法值域 | 默认值 | 类别 | 约束 |
|--------|------|----------|--------|------|------|
| `ADDR_REMAP_ENABLE` | bool | [true, false] | false | compile_time | 无 |

#### Requirement

IP 应提供可参数化的地址重映射使能 `ADDR_REMAP_ENABLE`，默认值为 0。开启时，
下游 `M_PADDR[i]` 为 `PADDR - BASE_ADDR[i]`（静态 offset）；关闭时
`M_PADDR[i] = PADDR`。

#### Acceptance Criteria

- `ADDR_REMAP_ENABLE = 0` 时 `M_PADDR[i] = PADDR`；
- `ADDR_REMAP_ENABLE = 1` 时 `M_PADDR[i] = PADDR - BASE_ADDR[i]`；
- 地址重映射为静态配置，V1.0 不支持 runtime programmable remap。

---

#### LRS.CFG.APB_DEMUX.03.002 超时使能参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.03.002
category: CFG
feature: timeout_enable
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

| 参数名 | 类型 | 合法值域 | 默认值 | 类别 | 约束 |
|--------|------|----------|--------|------|------|
| `TIMEOUT_ENABLE` | bool | [true, false] | false | compile_time | 无 |

#### Requirement

IP 应提供可参数化的超时使能 `TIMEOUT_ENABLE`，默认值为 0。当 `TIMEOUT_ENABLE=1`
且下游 `PREADY` 持续为 0 达到 `TIMEOUT_CYCLES` 周期时，IP 应终止 transaction
并向 upstream 返回 `PREADY=1, PSLVERR=1`。

#### Acceptance Criteria

- `TIMEOUT_ENABLE=0` 时不引入有效 timeout counter 逻辑；
- `TIMEOUT_ENABLE=1` 且 `TIMEOUT_CYCLES>0` 时超时行为正确。

---

#### LRS.CFG.APB_DEMUX.03.003 超时周期参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.03.003
category: CFG
feature: timeout_cycles
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

| 参数名 | 类型 | 合法值域 | 默认值 | 类别 | 约束 |
|--------|------|----------|--------|------|------|
| `TIMEOUT_CYCLES` | int | 2..1024 | 16 | compile_time | TIMEOUT_ENABLE == true -> TIMEOUT_CYCLES > 0 |

#### Requirement

IP 应提供可参数化的超时周期 `TIMEOUT_CYCLES`。当 `TIMEOUT_ENABLE=1` 时，
`TIMEOUT_CYCLES` 必须大于 0。

#### Acceptance Criteria

- `TIMEOUT_ENABLE=1` 时 `TIMEOUT_CYCLES > 0` 校验通过；
- `TIMEOUT_CYCLES=0` 且 `TIMEOUT_ENABLE=1` 时配置校验应报错。

---

#### LRS.CFG.APB_DEMUX.03.004 响应寄存器使能参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.03.004
category: CFG
feature: output_register
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

| 参数名 | 类型 | 合法值域 | 默认值 | 类别 | 约束 |
|--------|------|----------|--------|------|------|
| `OUTPUT_REGISTER` | bool | [true, false] | false | compile_time | 无 |

#### Requirement

IP 应提供可参数化的响应寄存器使能 `OUTPUT_REGISTER`，默认值为 0。开启时可通过
插入 APB wait-state 增加响应延迟以优化 timing。

#### Acceptance Criteria

- `OUTPUT_REGISTER=0` 时采用低延迟组合响应路径；
- `OUTPUT_REGISTER=1` 时响应延迟增加但不得违反 APB protocol。

---

### 1.6 APB 协议 Profile

#### LRS.CFG.APB_DEMUX.04.001 APB Profile 参数

<!-- LRS_META
id: LRS.CFG.APB_DEMUX.04.001
category: CFG
feature: apb_profile
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

| 参数名 | 类型 | 合法值域 | 默认值 | 类别 | 约束 |
|--------|------|----------|--------|------|------|
| `APB_PROFILE` | bool | [true, false] | true | compile_time | 无 |

#### Requirement

IP 应支持 APB3 与 APB4 两种协议 profile。APB4 时额外提供 `PSTRB`、`PPROT`
信号通路；APB3 时相关逻辑应裁剪。

#### Acceptance Criteria

- APB4 profile 下 `PSTRB`/`PPROT` 正确透传；
- APB3 profile 下无 `PSTRB`/`PPROT` 数据通路残留。

---
