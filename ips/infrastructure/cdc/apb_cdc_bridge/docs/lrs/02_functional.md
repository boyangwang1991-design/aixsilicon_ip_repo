# APB CDC Bridge — 功能需求（FUNC）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 事务语义 / Transaction Semantics

### 1.1 上游捕获

#### LRS.FUNC.APB_CDC_BRIDGE.01.001 上游事务捕获

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.01.001
category: FUNC
feature: upstream_capture
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Bridge 仅在合法 APB transfer 下接受事务：`s_psel = 1 && s_penable = 1`。
2. 捕获时应锁存 Request payload：`PADDR`、`PWRITE`、`PWDATA`、`PSTRB`（APB4）、`PPROT`（APB4）。
3. 仅对当前 profile 有效字段进行存储。

##### 验证关注点

1. SETUP 阶段（PSEL=1, PENABLE=0）不触发捕获。
2. ACCESS 阶段（PSEL=1, PENABLE=1）正确捕获。

---

#### LRS.FUNC.APB_CDC_BRIDGE.01.002 单事务语义

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.01.002
category: FUNC
feature: upstream_capture
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. V1.0 任一时刻最多允许一个跨 Bridge 的 APB transaction active。
2. 上游 `s_pready = 1` 只能在以下两类情况出现：下游 APB transaction 已完成；
   或 Bridge 本地已确定错误且无需访问下游。
3. 不得在下游尚未完成时提前返回成功（No spurious PREADY）。

##### 验证关注点

1. 上游 wait-state 期间 PREADY 保持 0。
2. 下游完成前 PREADY 不为 1。

---

#### LRS.FUNC.APB_CDC_BRIDGE.01.003 请求负载稳定

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.01.003
category: FUNC
feature: upstream_capture
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Request payload 跨域期间必须保持稳定，直至下游安全捕获。
2. 禁止将 multi-bit bus 每 bit 独立双触发器同步。

##### 验证关注点

1. 跨域期间 payload 不变（SVA）。
2. 无 multi-bit 逐 bit 2FF（CDC lint）。

---

### 1.2 下游重新生成

#### LRS.FUNC.APB_CDC_BRIDGE.02.001 下游 SETUP/ACCESS

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.02.001
category: FUNC
feature: downstream_regeneration
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Bridge 必须在 m_pclk 域重新生成合法 APB transaction，状态流为 IDLE → SETUP → ACCESS → COMPLETE。
2. SETUP 阶段必须先产生 `m_psel = 1, m_penable = 0`。
3. 下一 m_pclk 周期进入 ACCESS 阶段 `m_psel = 1, m_penable = 1`，并保持直到 `m_pready = 1`。

##### 验证关注点

1. 下游 APB 时序合法（SETUP 先于 ACCESS）。
2. 重新生成的地址/数据/控制与捕获的 payload 一致。

---

#### LRS.FUNC.APB_CDC_BRIDGE.02.002 下游等待状态

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.02.002
category: FUNC
feature: downstream_regeneration
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 当 `m_pready = 0` 时，下游必须保持 `m_psel`、`m_penable`、`m_paddr`、`m_pwrite`、`m_pwdata`、`m_pstrb`、`m_pprot` 稳定。
2. 支持任意数量的 wait state。

##### 验证关注点

1. wait-state 期间下游输出稳定。
2. 长等待/随机等待下事务正确完成。

---

#### LRS.FUNC.APB_CDC_BRIDGE.02.003 下游完成捕获

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.02.003
category: FUNC
feature: downstream_regeneration
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 当 `m_psel && m_penable && m_pready` 时，下游 transaction 完成。
2. Read transaction 必须捕获 `m_prdata` 并返回 `s_prdata`。
3. 必须捕获 `m_pslverr` 并返回 `s_pslverr`。

##### 验证关注点

1. 读数据/错误状态保真返回上游。
2. 一个下游完成对应一个上游完成。

---

## 2. CDC 实现 / CDC Implementation

### 2.1 HANDSHAKE Profile

#### LRS.FUNC.APB_CDC_BRIDGE.03.001 握手式跨域

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.03.001
category: FUNC
feature: handshake_profile
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. HANDSHAKE 应作为 V1.0 默认推荐实现，用于 APB register access、low throughput、area-first、power-first。
2. 采用 bundled-data handshake：Request payload 打包后由单一 Req Toggle 经 `SYNC_STAGES >= 2` 级同步器跨域。
3. Response payload 由 Rsp Toggle 经同步器返回源域。
4. Request payload 在 destination acknowledgement 前不得变化；Response payload 在 source acknowledgement 前不得变化。
5. 典型结构为：Request Latch → Req Toggle → 2FF Sync → Detect → Execute APB → Response Latch → Rsp Toggle → 2FF Sync → Return PREADY/PRDATA/PSLVERR。

##### 验证关注点

1. 握手事务不丢失、不重复。
2. Payload 稳定（SVA）。
3. 快→慢/慢→快均正确。

---

#### LRS.FUNC.APB_CDC_BRIDGE.03.002 同步器级数

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.03.002
category: FUNC
feature: handshake_profile
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 跨域 handshake control 必须通过 `SYNC_STAGES >= 2` 级同步器。
2. 默认 `SYNC_STAGES = 2`；高可靠场景可配置为 3。
3. 增加级数必须明确 MTBF ↑、Area ↑、Latency ↑。

##### 验证关注点

1. SYNC_STAGES=2/3 下握手正确。
2. 同步器级数与 RTL 一致。

---

### 2.2 ASYNC_FIFO Profile

#### LRS.FUNC.APB_CDC_BRIDGE.04.001 异步 FIFO 实现

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.04.001
category: FUNC
feature: async_fifo_profile
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. FIFO profile 用于需要更强 decoupling 的场景；推荐 `REQ_DEPTH = 1/2`、`RSP_DEPTH = 1/2`。
2. Request payload 打包为 `{PADDR, PWRITE, PWDATA, PSTRB, PPROT}` 进入 CDC FIFO。
3. Response payload 打包为 `{PRDATA, PSLVERR}`。
4. 即使 FIFO depth > 1，V1.0 默认不得改变上游 APB single-transfer completion 语义。

##### 验证关注点

1. FIFO 写入/读出正确。
2. depth=1/2 下无事务丢失/重复。
3. 无人工 outstanding（No Artificial Outstanding）。

---

#### LRS.FUNC.APB_CDC_BRIDGE.04.002 CDC 实现二选一隔离

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.04.002
category: FUNC
feature: cdc_impl_isolation
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. `CDC_IMPL` 参数必须是二选一：`HANDSHAKE` 或 `ASYNC_FIFO`，两种实现不得同时例化。
2. 两种实现对外暴露一致的 `req_channel`/`rsp_channel` 接口契约，源/目的 FSM 不感知底层实现。
3. 两种实现均保持单事务、bundled-data、`SYNC_STAGES` 语义，不得因实现选择改变 APB 协议行为。
4. 未选中的实现不得保留无意义数据通路（综合/面积证据）。

##### 验证关注点

1. `CDC_IMPL=HANDSHAKE` 时仅例化握手实现；`CDC_IMPL=ASYNC_FIFO` 时仅例化 FIFO 实现。
2. 两种实现下行为一致（等价验证）。
3. 未选实现被裁剪（综合证据）。

---

## 3. 时钟关系行为 / Clock Relationship Behavior

### 3.1 快→慢

#### LRS.FUNC.APB_CDC_BRIDGE.05.001 快慢上游等待

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.05.001
category: FUNC
feature: fast_to_slow
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 当 `s_pclk >> m_pclk` 时，上游必须保持 `s_pready = 0` 直到下游事务完成（合法 wait-state）。
2. Request 必须在 Source Domain 被锁存，避免长时间依赖上游保持组合数据。
3. fast→slow APB 场景默认优先 HANDSHAKE 实现。

##### 验证关注点

1. 上游长 ACCESS 等待。
2. 请求负载稳定性。

---

### 3.2 慢→快

#### LRS.FUNC.APB_CDC_BRIDGE.06.001 慢快低延迟

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.06.001
category: FUNC
feature: slow_to_fast
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 当 `s_pclk << m_pclk` 时，应优先减少 synchronizer chain latency、extra buffering、unnecessary FSM states。
2. 默认 `REQ_DEPTH = 1`、`RSP_DEPTH = 1` 即可。
3. 下游应快速完成 SETUP/ACCESS。

##### 验证关注点

1. 快速下游完成、响应 CDC 延迟。
2. 无重复下游事务。

---

### 3.3 同步异频（预留）

#### LRS.FUNC.APB_CDC_BRIDGE.07.001 同步异频资格

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.07.001
category: FUNC
feature: sync_ratio
priority: P1
verify_method: review
status: active
END_LRS_META -->

##### 需求描述

1. 只有 clocks related、frequency ratio fixed、phase relation timing-analyzable、constraints available 时才允许启用专用 synchronous implementation。
2. Bridge 不得根据参数中的 MHz 数值自动判断 clocks 是否同步（No Automatic Guess）。
3. 当 clock relation 无法证明时必须使用 ASYNC_SAFE implementation（Fallback）。
4. V1.0 默认安全模式为 `CDC_MODE = ASYNC_SAFE`。

##### 验证关注点

1. 配置审查确认默认 ASYNC_SAFE。
2. 无自动判断时钟关系逻辑。

---

## 4. 时钟暂停 / Clock Pause

### 4.1 目的时钟停止

#### LRS.FUNC.APB_CDC_BRIDGE.08.001 目的时钟暂停保持

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.08.001
category: FUNC
feature: clock_pause
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 若 `m_pclk` 暂停：当前 transaction 必须保持 pending、`s_pready` 保持 low、transaction 不得丢失。
2. 若 `s_pclk` 暂停：destination 可继续完成当前 APB transaction；response 必须保持至 source clock 恢复并安全接收。
3. Bridge 必须兼容 clock gating，被 gate 的域恢复 clock 后应继续完成 transaction。

##### 验证关注点

1. 源/目的时钟停止场景下无事务丢失。
2. 时钟恢复后事务继续完成。

---

## 5. 复位错误行为 / Reset Error Behavior

### 5.1 复位中止

#### LRS.FUNC.APB_CDC_BRIDGE.09.001 复位中止策略

<!-- LRS_META
id: LRS.FUNC.APB_CDC_BRIDGE.09.001
category: FUNC
feature: reset_behavior
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 若 upstream transaction 尚未完成而 downstream reset，V1.0 选择 `stall until recovery` / `reset-abort` 策略，不引入复杂 timeout/error reconstruction（PPA 优先）。
2. reset 后不得把 reset 前的 request/response toggle、payload、FIFO entry 识别为新事务。
3. 目标避免要求固定 reset 顺序。

##### 验证关注点

1. reset during request CDC / APB ACCESS / response CDC。
2. reset 后无 stale transfer 被当作新事务。

---

*文档版本: v1.0*
*创建日期: 2026-09-07*
*创建者: IP Development Suite - 01-lrs-author*
