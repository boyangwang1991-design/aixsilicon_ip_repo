# APB Demux — 功能需求（FUNC）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 功能需求 / Functional Requirements

### 1.1 地址译码

#### LRS.FUNC.APB_DEMUX.01.001 独立地址映射区域

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.01.001
category: FUNC
feature: address_decode
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

每个下游 APB port 应具有独立的地址映射区域，由 `BASE_ADDR[i]` 与
`ADDR_MASK[i]` 定义。

#### Acceptance Criteria

- 每个下游端口拥有独立非重叠的地址窗口。

---

#### LRS.FUNC.APB_DEMUX.01.002 基于 PADDR 的地址译码

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.01.002
category: FUNC
feature: address_decode
priority: P0
status: active
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

地址译码应基于当前 APB transaction 的 `PADDR`，命中条件为
`hit[i] = (PADDR & ADDR_MASK[i]) == (BASE_ADDR[i] & ADDR_MASK[i])`。

#### Acceptance Criteria

- 合法地址访问命中唯一正确的下游端口。

---

#### LRS.FUNC.APB_DEMUX.01.003 单端口命中约束

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.01.003
category: FUNC
feature: address_decode
priority: P0
status: active
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

任意合法地址最多只能命中一个下游 port，即 `$onehot0(hit)` 必须成立。地址
overlap 应优先通过静态配置检查发现。

#### Acceptance Criteria

- 任意地址访问 `hit` 向量满足 onehot0；
- 地址重叠配置被配置校验拒绝。

---

#### LRS.FUNC.APB_DEMUX.01.004 地址区域对齐推荐

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.01.004
category: FUNC
feature: address_decode
priority: P1
status: active
verification_method:
  - review
  - static
END_LRS_META -->

#### Requirement

地址区域应满足 `size = power-of-two` 且 `base aligned to size`，以简化 decoder
逻辑。

#### Acceptance Criteria

- 配置校验检查 power-of-two 窗口与基地址对齐。

---

#### LRS.FUNC.APB_DEMUX.01.005 有效位比较优化

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.01.005
category: FUNC
feature: address_decode
priority: P1
status: active
verification_method:
  - review
END_LRS_META -->

#### Requirement

对于合法配置，地址译码应尽量减少无意义地址位比较。综合结果不应人为引入完整
地址加减比较路径。

#### Acceptance Criteria

- 综合报告显示 decoder 逻辑深度合理，无非必要全位宽比较。

---

### 1.2 请求路由

#### LRS.FUNC.APB_DEMUX.02.001 请求信号广播

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.02.001
category: FUNC
feature: request_routing
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

以下请求信号允许广播至所有下游 ports：`PADDR`、`PENABLE`、`PWRITE`、`PWDATA`、
`PSTRB`、`PPROT`。

#### Acceptance Criteria

- 广播信号对所有下游端口一致。

---

#### LRS.FUNC.APB_DEMUX.02.002 PSEL 命中门控

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.02.002
category: FUNC
feature: request_routing
priority: P0
status: active
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

只有地址命中的下游 port 可以接收到有效 `PSEL`，即
`M_PSEL[i] = upstream_PSEL & hit[i]`。未选中下游 port 的 `M_PSEL = 0`。

#### Acceptance Criteria

- 命中端口 `M_PSEL` 有效，未命中端口 `M_PSEL` 无效；
- `M_PSEL` 满足 onehot0 约束。

---

#### LRS.FUNC.APB_DEMUX.02.003 PENABLE 时序合规

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.02.003
category: FUNC
feature: request_routing
priority: P0
status: active
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

`M_PENABLE` 必须符合 APB protocol timing，不得产生 `PENABLE=1, PSEL=0` 的非法
下游 transaction。实现可通过 `M_PENABLE[i] = upstream_PENABLE` 配合
`M_PSEL[i]` 使用。

#### Acceptance Criteria

- 任意时刻不出现 `M_PENABLE=1` 且 `M_PSEL=0` 的组合；
- APB 断言检查通过。

---

### 1.3 APB 事务行为

#### LRS.FUNC.APB_DEMUX.03.001 APB 事务语义保持

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.03.001
category: FUNC
feature: transaction_behavior
priority: P0
status: active
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

IP 不得改变标准 APB transaction semantics。APB transaction 应包含 SETUP PHASE
（`PSEL=1, PENABLE=0`）与 ACCESS PHASE（`PSEL=1, PENABLE=1`）。

#### Acceptance Criteria

- 上游与下游均观察标准 SETUP/ACCESS 两相时序。

---

#### LRS.FUNC.APB_DEMUX.03.002 Wait-state 保持

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.03.002
category: FUNC
feature: transaction_behavior
priority: P0
status: active
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

当下游 `PREADY=0` 时，IP 必须保持 transaction 处于 ACCESS phase；wait-state
期间下游 selection 与返回 response source 不得改变。

#### Acceptance Criteria

- `PREADY=0` 时 `PSEL`/`PENABLE` 保持稳定；
- wait-state 期间被选端口不变。

---

### 1.4 响应路由

#### LRS.FUNC.APB_DEMUX.04.001 选中端口响应返回

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.04.001
category: FUNC
feature: response_routing
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

被选中下游 port 的 `PRDATA`、`PREADY`、`PSLVERR` 必须返回至 upstream。未选中
下游 port 的 response 不得影响 upstream response。

#### Acceptance Criteria

- 读取访问返回正确数据；
- 未选中端口响应被屏蔽。

---

#### LRS.FUNC.APB_DEMUX.04.002 PSLVERR 透传

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.04.002
category: FUNC
feature: response_routing
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

当下游返回 `PSLVERR=1` 时，IP 必须向 upstream 透传 error response，不得屏蔽
下游 APB error。

#### Acceptance Criteria

- 下游 `PSLVERR=1` 时上游观察到 `PSLVERR=1`。

---

### 1.5 Decode Miss 错误处理

#### LRS.FUNC.APB_DEMUX.05.001 Decode Miss 检测

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.05.001
category: FUNC
feature: decode_error
priority: P0
status: active
verification_method:
  - simulation
  - formal
END_LRS_META -->

#### Requirement

若 `PSEL=1` 但当前 `PADDR` 未匹配任何下游 port，必须产生 Decode Error。

#### Acceptance Criteria

- 未命中地址访问产生 Decode Error 响应。

---

#### LRS.FUNC.APB_DEMUX.05.002 Decode Miss 响应

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.05.002
category: FUNC
feature: decode_error
priority: P0
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

Decode Miss 推荐响应为 `PREADY=1, PSLVERR=1, PRDATA=0`，即立即结束 transaction。

#### Acceptance Criteria

- Decode Miss 时上游观察到 `PREADY=1, PSLVERR=1, PRDATA=0`。

---

#### LRS.FUNC.APB_DEMUX.05.003 Decode Miss 不挂死

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.05.003
category: FUNC
feature: decode_error
priority: P0
status: active
verification_method:
  - simulation
  - assertion
END_LRS_META -->

#### Requirement

Decode Miss 不允许无限等待，禁止 `PREADY=0 forever`，否则可能导致整个 APB
fabric hang。

#### Acceptance Criteria

- Decode Miss 时 transaction 在有限周期内完成。

---

### 1.6 地址重映射（可选）

#### LRS.FUNC.APB_DEMUX.06.001 Remap 关闭透传

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.06.001
category: FUNC
feature: address_remap
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

`ADDR_REMAP_ENABLE=0` 时，`M_PADDR[i] = PADDR`（透传）。

#### Acceptance Criteria

- 关闭 remap 时下游地址与上游一致。

---

#### LRS.FUNC.APB_DEMUX.06.002 Remap 开启地址偏移

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.06.002
category: FUNC
feature: address_remap
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

`ADDR_REMAP_ENABLE=1` 时，`M_PADDR[i] = PADDR - BASE_ADDR[i]`，使下游看到
local offset 地址。例如上游 `0x4000_0120` → 下游 local `0x0000_0120`。

#### Acceptance Criteria

- 开启 remap 时下游地址为 `PADDR - BASE_ADDR[i]`。

---

### 1.7 Transaction Timeout（可选）

#### LRS.FUNC.APB_DEMUX.07.001 Timeout 终止

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.07.001
category: FUNC
feature: timeout
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

`TIMEOUT_ENABLE=1` 且下游 `PREADY` 持续为 0 达到 `TIMEOUT_CYCLES` 时，IP 可以
终止 transaction 并向 upstream 返回 `PREADY=1, PSLVERR=1`。

#### Acceptance Criteria

- 超时后 transaction 以 error 响应结束。

---

#### LRS.FUNC.APB_DEMUX.07.002 Timeout 计数条件

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.07.002
category: FUNC
feature: timeout
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

Timeout counter 仅在有效 ACCESS phase 且 `PREADY=0` 时计数。

#### Acceptance Criteria

- 非 ACCESS 或 `PREADY=1` 时计数不递增。

---

### 1.8 Response Register（可选）

#### LRS.FUNC.APB_DEMUX.08.001 低延迟组合响应

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.08.001
category: FUNC
feature: response_register
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

`OUTPUT_REGISTER=0`（默认）时，应采用低延迟组合 response path。

#### Acceptance Criteria

- 默认配置下响应延迟最低。

---

#### LRS.FUNC.APB_DEMUX.08.002 Response Register 插入

<!-- LRS_META
id: LRS.FUNC.APB_DEMUX.08.002
category: FUNC
feature: response_register
priority: P1
status: active
verification_method:
  - simulation
END_LRS_META -->

#### Requirement

`OUTPUT_REGISTER=1` 时，可通过插入 APB wait-state 增加一个或多个周期响应延迟，
但不得违反 APB protocol。该特性主要用于大 `NUM_SLAVES`、高频设计与 response mux
timing optimization。

#### Acceptance Criteria

- 开启后响应延迟增加，但 APB 协议断言通过。

---
