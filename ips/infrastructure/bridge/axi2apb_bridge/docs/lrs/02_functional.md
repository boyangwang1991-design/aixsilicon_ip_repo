# 功能需求 - AXI-to-APB Bridge (X2P)
# Functional Requirements - AXI-to-APB Bridge (X2P)

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 包含范围 / Scope

本文档包含以下需求类别：
- **FUNC**：功能需求（AW/W 关联、Burst 转换、Narrow/Width Conversion、Time-Out、仲裁、Outstanding、错误映射、Reset 等）

---

## 2. 功能需求 / Functional Requirements

### 2.1 AW/W 关联 / AW-W Association

#### LRS.FUNC.X2P.01.001 AW/W 独立握手

<!-- LRS_META
id: LRS.FUNC.X2P.01.001
category: FUNC
ip: X2P
feature: aw_w_association
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. AW 和 W Channel 应独立握手，支持 AW before W、W before AW、AW/W 同周期以及任意 AW-W 间隔。
2. X2P 应保存已接受但尚未与 AW 配对的 W data，以及已接受但尚未与 W 配对的 AW transaction。
3. 不得假设 AWVALID 和 WVALID 同周期出现。

##### 验证关注点

1. AW 提前、W 提前、同周期三种时序均正常。
2. 任意 AW-W 间隔不丢数据。

---

#### LRS.FUNC.X2P.01.002 AXI Write Ordering

<!-- LRS_META
id: LRS.FUNC.X2P.01.002
category: FUNC
ip: X2P
feature: aw_w_association
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 完整 AXI4 Profile 应按照 AXI Write Ordering Rule 正确关联 AW transaction 与 W data sequence。
2. 一个 AW Descriptor 对应 AWLEN+1 个 W Beats，W 数据顺序与 AW 顺序一致。

##### 验证关注点

1. 多笔 Write 交错时数据与地址正确配对。
2. WLAST 正确标记每笔 W 事务结束。

---

### 2.2 Burst 转换 / Burst Conversion

#### LRS.FUNC.X2P.02.001 INCR Burst

<!-- LRS_META
id: LRS.FUNC.X2P.02.001
category: FUNC
ip: X2P
feature: burst_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应完整支持 AXI INCR Burst，下一 AXI Beat 地址按 AXI 规范计算。
2. 地址计算必须考虑 AxSIZE、当前地址、数据总线宽度与 burst length。

##### 验证关注点

1. INCR 各 beats 地址递增正确。
2. 地址不跨越 4KB boundary。

---

#### LRS.FUNC.X2P.02.002 FIXED Burst

<!-- LRS_META
id: LRS.FUNC.X2P.02.002
category: FUNC
ip: X2P
feature: burst_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应完整支持 FIXED Burst，所有 AXI Beat 使用同一 AXI Transfer Address。
2. 每个 AXI Beat 应作为独立 transaction data 被转换。

##### 验证关注点

1. FIXED 各 beats 地址不变。
2. 每 beat 数据独立转换。

---

#### LRS.FUNC.X2P.02.003 WRAP Burst

<!-- LRS_META
id: LRS.FUNC.X2P.02.003
category: FUNC
ip: X2P
feature: burst_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应完整支持 WRAP Burst。
2. 应按照 AxLEN、AxSIZE、起始地址与 wrap boundary 正确计算 Wrap Address。
3. 当地址达到 Wrap Upper Boundary 后，下一 Beat 应回绕至 Wrap Lower Boundary。

##### 验证关注点

1. WRAP 地址回绕点正确。
2. WRAP 与 Width Conversion 同时存在时地址语义正确。

---

#### LRS.FUNC.X2P.02.004 Burst 4KB Boundary

<!-- LRS_META
id: LRS.FUNC.X2P.02.004
category: FUNC
ip: X2P
feature: burst_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应遵守 AXI Burst 不跨越 4KB Boundary 的要求。
2. 对于非法输入，不得产生超出合法 AXI Burst 地址范围的 APB transaction。

##### 验证关注点

1. 4KB 边界附近的 burst 地址正确。
2. 非法输入不产生越界 APB transaction。

---

### 2.3 Narrow Transfer / Width Conversion

#### LRS.FUNC.X2P.03.001 Narrow Transfer

<!-- LRS_META
id: LRS.FUNC.X2P.03.001
category: FUNC
ip: X2P
feature: narrow_width_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应支持 AXI Narrow Transfer（如 AXI_DATA_WIDTH=64、AxSIZE=2 表示传输 4 Bytes）。
2. 应基于 AxADDR、AxSIZE、WSTRB 计算有效 Byte Lane。

##### 验证关注点

1. Narrow write 仅访问有效字节。
2. Narrow read 仅返回有效字节。

---

#### LRS.FUNC.X2P.03.002 Wide-to-Narrow Conversion

<!-- LRS_META
id: LRS.FUNC.X2P.03.002
category: FUNC
ip: X2P
feature: narrow_width_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. AXI_DATA_WIDTH > APB_DATA_WIDTH 时，一个 AXI Beat 应拆解为多个 APB Sub-Transfers（如 AXI64→APB32 拆为两个）。
2. 每个 Sub-Transfer 应正确生成 PADDR、PWDATA、PSTRB。
3. 无需访问的 Byte Lane 不得产生无意义的 APB Write。

##### 验证关注点

1. Wide-to-Narrow 拆解数量正确（结合 AxSIZE/地址偏移/WSTRB）。
2. 未访问字节不产生 APB 访问。

---

#### LRS.FUNC.X2P.03.003 Narrow-to-Wide Conversion

<!-- LRS_META
id: LRS.FUNC.X2P.03.003
category: FUNC
ip: X2P
feature: narrow_width_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. AXI_DATA_WIDTH < APB_DATA_WIDTH 时，应把 AXI transaction 映射到正确的 APB Byte Lane。
2. APB4 Write 应通过 PSTRB 标识有效 Byte Lane。

##### 验证关注点

1. Narrow-to-Wide 写映射到正确 lane，PSTRB 正确。
2. Read 从对应 lane 提取数据。

---

#### LRS.FUNC.X2P.03.004 Read Data Assembly

<!-- LRS_META
id: LRS.FUNC.X2P.03.004
category: FUNC
ip: X2P
feature: narrow_width_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Wide AXI Read 被拆分多个 APB transfer 时，应收集所有必要 PRDATA。
2. 只有形成完整 AXI Read Beat 后才能 RVALID=1。
3. 任一 APB Sub-Transfer 出错时，该 AXI Beat 的 RRESP 应反映错误。

##### 验证关注点

1. Read 数据拼接正确。
2. RVALID 仅在完整 Beat 后拉高。
3. 子传输错误映射到 RRESP。

---

#### LRS.FUNC.X2P.03.005 Write Strobe 转换

<!-- LRS_META
id: LRS.FUNC.X2P.03.005
category: FUNC
ip: X2P
feature: narrow_width_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. APB4 Profile 应支持 WSTRB→PSTRB 语义转换。
2. PSTRB 应准确反映当前 APB Sub-Transfer 的有效 Byte Lane。

##### 验证关注点

1. WSTRB 到 PSTRB 的映射正确。

---

#### LRS.FUNC.X2P.03.006 APB3 Partial Write

<!-- LRS_META
id: LRS.FUNC.X2P.03.006
category: FUNC
ip: X2P
feature: narrow_width_conversion
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 由于 APB3 不提供 PSTRB，不能表示为完整 APB Word Write 的 APB3 Write 应返回 AXI SLVERR。
2. V1.0 不得通过自动 Read-Modify-Write 修改 APB3 Write 语义。

##### 验证关注点

1. APB3 partial write 返回 SLVERR。
2. 无自动 RMW。

---

### 2.4 Request Buffering / Outstanding

#### LRS.FUNC.X2P.04.001 可配置 Request Buffer

<!-- LRS_META
id: LRS.FUNC.X2P.04.001
category: FUNC
ip: X2P
feature: request_buffering
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应具有可配置 Request Buffer，分别提供 READ_REQUEST_DEPTH / WRITE_REQUEST_DEPTH。
2. Depth 应至少支持 1/2/4/8。
3. Buffer Full 时应通过 AXI READY 合法产生 Backpressure。
4. 禁止 Request Overflow / Underflow。

##### 验证关注点

1. 队列深度 1/2/4/8 均正确。
2. Buffer Full 时 READY 下降，无溢出/下溢。

---

#### LRS.FUNC.X2P.04.002 Outstanding

<!-- LRS_META
id: LRS.FUNC.X2P.04.002
category: FUNC
ip: X2P
feature: request_buffering
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 完整 AXI4 Profile 应支持多个 Pending Read/Write Transactions。
2. 最大支持数量通过参数配置。
3. 每笔 Pending Transaction 应保存完成 response 所需 metadata（ID、address、burst 信息、transfer size、response state）。

##### 验证关注点

1. 多 outstanding 读/写正确完成。
2. metadata 完整。

---

### 2.5 仲裁 / Arbitration

#### LRS.FUNC.X2P.05.001 仲裁策略

<!-- LRS_META
id: LRS.FUNC.X2P.05.001
category: FUNC
ip: X2P
feature: read_write_arbitration
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Read Request 和 Write Request 共享单一 APB Master，应进行仲裁。
2. 应支持 ROUND_ROBIN / READ_PRIORITY / WRITE_PRIORITY 三种策略，默认 ROUND_ROBIN。
3. ROUND_ROBIN 模式不得发生永久 Read 或 Write starvation。

##### 验证关注点

1. 三种策略均正确。
2. ROUND_ROBIN 下无永久饥饿。

---

#### LRS.FUNC.X2P.05.002 仲裁粒度

<!-- LRS_META
id: LRS.FUNC.X2P.05.002
category: FUNC
ip: X2P
feature: read_write_arbitration
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 仲裁粒度应至少支持 AXI_TRANSACTION / AXI_BEAT，默认 AXI_BEAT。
2. 实现 Beat-Level Arbitration 时不得破坏同一 AXI Transaction 的协议 ordering。
3. 一个 AXI Beat 的 APB Sub-Transfers 必须作为不可切分的原子调度单元。

##### 验证关注点

1. 两种粒度均正确。
2. Beat 内 sub-transfer 不被切分。

---

### 2.6 Response / Error

#### LRS.FUNC.X2P.06.001 错误映射

<!-- LRS_META
id: LRS.FUNC.X2P.06.001
category: FUNC
ip: X2P
feature: response_error
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 正常 APB Completion（PSLVERR=0）应转换为 AXI OKAY。
2. APB PSLVERR=1 应转换为 AXI SLVERR。

##### 验证关注点

1. OKAY/SLVERR 映射正确。

---

#### LRS.FUNC.X2P.06.002 输出响应 Backpressure

<!-- LRS_META
id: LRS.FUNC.X2P.06.002
category: FUNC
ip: X2P
feature: response_error
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. RVALID=1、RREADY=0 时，R channel outputs 必须稳定。
2. BVALID=1、BREADY=0 时，B channel outputs 必须稳定。

##### 验证关注点

1. R/B 通道背压时输出稳定。

---

#### LRS.FUNC.X2P.06.003 Write Error Aggregation

<!-- LRS_META
id: LRS.FUNC.X2P.06.003
category: FUNC
ip: X2P
feature: response_error
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 一个 AXI Write Transaction 被拆成多个 APB transfer 时，只要任一 APB transfer 出错，最终 BRESP != OKAY。
2. 已经完成的 APB Write 不执行 rollback。

##### 验证关注点

1. 任一子传输出错，BRESP=SLVERR。
2. 无 rollback。

---

#### LRS.FUNC.X2P.06.004 AXI ID 保真

<!-- LRS_META
id: LRS.FUNC.X2P.06.004
category: FUNC
ip: X2P
feature: response_error
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. AXI4 Profile 应正确保存 AWID/ARID，并正确产生 BID/RID。
2. 不得产生 ID mismatch。

##### 验证关注点

1. BID/RID 与原事务 ID 一致。

---

#### LRS.FUNC.X2P.06.005 Unsupported / Invalid Transaction

<!-- LRS_META
id: LRS.FUNC.X2P.06.005
category: FUNC
ip: X2P
feature: response_error
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 不能被当前 parameter configuration 正确执行的 AXI transaction 应返回明确错误。
2. 不得 silently truncate / realign / discard data / alter transaction semantics。

##### 验证关注点

1. 非法事务返回 SLVERR（或明确错误）。

---

### 2.7 APB Timeout / APB FSM

#### LRS.FUNC.X2P.07.001 APB Timeout

<!-- LRS_META
id: LRS.FUNC.X2P.07.001
category: FUNC
ip: X2P
feature: apb_timeout
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. V1.0 应支持 APB Timeout，通过 TIMEOUT_ENABLE 与 TIMEOUT_CYCLES 配置。
2. 当 PSEL=1、PENABLE=1、PREADY=0 持续达到 TIMEOUT_CYCLES 时产生 timeout。
3. Timeout 对应 AXI response 为 SLVERR。
4. Timeout 后应结束当前 APB Master transaction，恢复至可继续处理后续 request 的状态。
5. Timeout 状态不得导致 APB FSM 永久锁死。

##### 验证关注点

1. Timeout 使能/关闭行为。
2. Timeout 计数正确，返回 SLVERR。
3. Timeout 后 FSM 恢复，无死锁。

---

### 2.8 APB Transaction / Wait-State

#### LRS.FUNC.X2P.08.001 APB Transfer 流程

<!-- LRS_META
id: LRS.FUNC.X2P.08.001
category: FUNC
ip: X2P
feature: apb_transaction
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 每次 APB access 应按照 SETUP → ACCESS 执行。
2. SETUP phase：PSEL=1、PENABLE=0。
3. ACCESS phase：PSEL=1、PENABLE=1。
4. 只有当 PREADY=1 时 APB Transfer 才能结束。

##### 验证关注点

1. SETUP/ACCESS 相位正确。
2. PREADY=0 时保持 ACCESS。

---

#### LRS.FUNC.X2P.08.002 Wait-State

<!-- LRS_META
id: LRS.FUNC.X2P.08.002
category: FUNC
ip: X2P
feature: apb_transaction
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. PREADY=0 时 X2P 应保持当前 APB ACCESS phase。
2. Wait-State 期间应保持 PADDR/PSEL/PENABLE/PWRITE/PWDATA/PSTRB/PPROT 稳定，直到 transfer completion 或 timeout。

##### 验证关注点

1. Wait-State 信号稳定。

---

### 2.9 Register Stage / Ordering

#### LRS.FUNC.X2P.09.001 Register Stage

<!-- LRS_META
id: LRS.FUNC.X2P.09.001
category: FUNC
ip: X2P
feature: regslice_ordering
priority: P1
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. 应支持可配置 Register Stage，至少独立配置 AXI_INPUT_REG / AXI_OUTPUT_REG / APB_OUTPUT_REG。
2. Register Stage 启用与否不得改变 transaction 功能语义。

##### 验证关注点

1. 各 regslice 开关功能正确。

---

#### LRS.FUNC.X2P.09.002 Ordering

<!-- LRS_META
id: LRS.FUNC.X2P.09.002
category: FUNC
ip: X2P
feature: regslice_ordering
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. X2P 应遵守 AXI Ordering Requirements。
2. 相同 AXI ID 的 transaction 应保持协议要求的 response ordering。
3. APB transaction 本身不得发生 out-of-order completion。

##### 验证关注点

1. 同 ID transaction 顺序正确。
2. APB 串行执行顺序正确。

---

### 2.10 CDC / Async

#### LRS.FUNC.X2P.10.001 CDC Transaction Semantics

<!-- LRS_META
id: LRS.FUNC.X2P.10.001
category: FUNC
ip: X2P
feature: cdc_async
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. CDC 应在 Transaction Level 完成，不得直接将 PSEL/PENABLE/PREADY 作为 AXI/APB 两域之间的 CDC handshake。
2. AXI Domain → APB Domain 应传递完整 request 信息（address、read/write、write data、write strobe、protection、transaction metadata）。
3. APB Domain → AXI Domain 应返回 read data、completion、error、transaction metadata。

##### 验证关注点

1. 跨域 request/response 完整。
2. 无协议级信号直连跨域。

---

#### LRS.FUNC.X2P.10.002 CDC Buffering

<!-- LRS_META
id: LRS.FUNC.X2P.10.002
category: FUNC
ip: X2P
feature: cdc_async
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. ASYNC Profile 应具备 request-side 与 response-side CDC buffering。
2. CDC buffer 深度应与 supported outstanding configuration 协同，不得产生 transaction loss。

##### 验证关注点

1. CDC FIFO 深度配置正确。
2. 无事务丢失。

---

#### LRS.FUNC.X2P.10.003 Reset 后无伪请求

<!-- LRS_META
id: LRS.FUNC.X2P.10.003
category: FUNC
ip: X2P
feature: cdc_async
priority: P0
verify_method: simulation
status: active
END_LRS_META -->

##### 需求描述

1. Reset release sequencing 不得产生伪 request 或伪 response。
2. 任一 domain reset 后，不得误执行 reset 前未确认完整跨域的 transaction。

##### 验证关注点

1. 任一域复位不产生伪请求/响应。

---

*文档版本: v1.0*
*创建日期: 2026-09-03*
*创建者: IP Development Suite - 01-lrs-author*