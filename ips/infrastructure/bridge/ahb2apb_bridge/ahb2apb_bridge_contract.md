# AIXSILICON X2P IP — Architecture Specification

> **Document ID**: `aixsilicon:ip:x2p:arch`
> **IP Name**: `x2p`
> **Version**: `1.0.0-g0`
> **Requirement Baseline**: `aixsilicon:ip:x2p:req@1.0.0-g0`
> **Status**: `G0 Draft`
> **Architecture**: 1 AXI Slave → 1 APB Master

---

# 1. Architecture Goals

X2P 架构必须同时满足：

* AXI4 / AXI4-Lite；
* APB3 / APB4；
* INCR / FIXED / WRAP；
* Narrow Transfer；
* Width Conversion；
* Outstanding；
* Request Buffer；
* configurable R/W arbitration；
* APB Timeout；
* pipeline；
* synchronous / asynchronous clock。

因此不能采用单一“大 FSM”直接连接 AXI 与 APB。

推荐架构采用：

> **Frontend → Transaction Layer → CDC Boundary → APB Backend → Response Layer**

---

# 2. Top-Level Architecture

```text
                       AXI CLOCK DOMAIN
+------------------------------------------------------------------+
|                                                                  |
|  AXI                                                             |
|   |                                                              |
|   v                                                              |
| +--------------------+                                           |
| | AXI Frontend       |                                           |
| |                    |                                           |
| | AW Capture         |                                           |
| | W Capture          |                                           |
| | AR Capture         |                                           |
| | AXI Protocol State |                                           |
| +---------+----------+                                           |
|           |                                                      |
|           v                                                      |
| +--------------------+                                           |
| | Request Buffers    |                                           |
| |                    |                                           |
| | Read Queue         |                                           |
| | Write Queue        |                                           |
| +---------+----------+                                           |
|           |                                                      |
|           v                                                      |
| +--------------------+                                           |
| | R/W Scheduler      |                                           |
| +---------+----------+                                           |
|           |                                                      |
|           v                                                      |
| +--------------------+                                           |
| | AXI Transfer Engine|                                           |
| |                    |                                           |
| | Burst Tracker      |                                           |
| | WRAP Addr Gen      |                                           |
| | Narrow Decode      |                                           |
| | Width Convert      |                                           |
| +---------+----------+                                           |
|           |                                                      |
+-----------|------------------------------------------------------+
            |
        Request Channel
            |
       +----v-----+
       | CDC Layer|       bypass in SYNC mode
       +----+-----+
            |
+-----------|------------------------------------------------------+
|           v                     APB CLOCK DOMAIN                  |
| +--------------------+                                           |
| | APB Request Buffer |                                           |
| +---------+----------+                                           |
|           |                                                      |
|           v                                                      |
| +--------------------+                                           |
| | APB Engine         |                                           |
| |                    |                                           |
| | SETUP              |                                           |
| | ACCESS             |                                           |
| | WAIT               |                                           |
| | TIMEOUT            |                                           |
| +---------+----------+                                           |
|           |                                                      |
|           v                                                      |
|          APB                                                     |
|                                                                  |
+------------------------------------------------------------------+

            ^
            |
      Response Channel
            |
       +----+-----+
       | CDC Layer|
       +----+-----+
            |
+-----------|------------------------------------------------------+
|           v                                                      |
| +--------------------+                                           |
| | Response Engine    |                                           |
| |                    |                                           |
| | Read Assemble      |                                           |
| | Error Aggregate    |                                           |
| | BID/RID Restore    |                                           |
| +---------+----------+                                           |
|           |                                                      |
|           v                                                      |
|          AXI                                                     |
+------------------------------------------------------------------+
```

---

# 3. Major Components

推荐 RTL 层级：

```text
x2p
│
├── x2p_axi_frontend
│   ├── x2p_aw_channel
│   ├── x2p_w_channel
│   ├── x2p_ar_channel
│   └── x2p_axi_rsp
│
├── x2p_req_mgr
│   ├── x2p_rd_queue
│   ├── x2p_wr_queue
│   └── x2p_aw_w_pair
│
├── x2p_scheduler
│
├── x2p_transfer_engine
│   ├── x2p_burst_engine
│   ├── x2p_wrap_addr_gen
│   ├── x2p_lane_engine
│   └── x2p_width_engine
│
├── x2p_cdc
│   ├── x2p_req_cdc
│   └── x2p_rsp_cdc
│
├── x2p_apb_engine
│   └── x2p_timeout_ctrl
│
├── x2p_rsp_mgr
│   ├── x2p_read_assembler
│   ├── x2p_write_rsp
│   └── x2p_error_aggregate
│
└── x2p_regslice
```

不要求 RTL 必须严格拆成以上文件，但架构职责必须保持独立。

---

# 4. Internal Transaction Interface

AXI 与 APB 不直接交换协议级信号。

内部定义统一 Request：

```text
x2p_req {
    txn_id
    is_write

    addr

    burst_type
    burst_len
    burst_size

    beat_idx

    data
    strb

    prot

    first
    last
}
```

内部 APB request：

```text
x2p_apb_req {
    txn_id

    addr
    write

    wdata
    strb
    prot

    axi_beat_idx
    subbeat_idx

    axi_beat_last
    axi_txn_last
}
```

Response：

```text
x2p_rsp {
    txn_id

    axi_beat_idx

    rdata
    error

    beat_last
    txn_last
}
```

这些定义是内部概念接口，不要求暴露为 Top-Level Port。

---

# 5. AXI Frontend

AXI Frontend 负责：

* READY/VALID；
* AW capture；
* W capture；
* AR capture；
* B/R response handshake；
* AXI ID capture；
* basic protocol metadata extraction。

不负责：

* APB FSM；
* APB wait-state；
* width conversion；
* CDC。

---

# 6. AW/W Association

Write path：

```text
          AW
           |
           v
      AW Queue
           |
           +------+
                  |
                 Pair
                  |
           +------+
           |
      W Data Queue
           ^
           |
           W
```

AW/W association 必须支持：

```text
AW before W
W before AW
same-cycle
```

完整 AXI4 Burst 中：

一个 AW Descriptor 对应：

```text
AWLEN + 1
```

个 W Beats。

---

# 7. Request Queue Architecture

Read 和 Write 分别设置 Request Queue：

```text
AR
 |
 v
RD Queue ----+
             |
             v
          Scheduler
             ^
             |
WR Queue ----+
 ^
 |
AW/W
```

Depth：

```text
READ_REQUEST_DEPTH
WRITE_REQUEST_DEPTH
```

独立参数化。

---

# 8. Scheduler

Scheduler 负责：

```text
Read Queue
    |
    +--> arbitration --> Transfer Engine
    |
Write Queue
```

支持三种 Policy：

```text
ROUND_ROBIN
READ_PRIORITY
WRITE_PRIORITY
```

---

# 9. Arbitration Granularity

支持：

## TRANSACTION Mode

一个 AXI Burst 完成全部 APB transfer 后才切换 R/W。

```text
Read burst entire transaction
         ↓
Write burst entire transaction
```

优点：

* control simpler；
* metadata context simpler。

缺点：

* long burst 容易阻塞另一方向。

---

## BEAT Mode

每完成一个 AXI Beat，可重新仲裁：

```text
Read beat
Write beat
Read beat
Write beat
```

默认：

```text
ARB_GRANULARITY = BEAT
```

不能在一个 AXI Beat 的 APB Sub-Transfers 中间切走。

即：

```text
AXI64 -> APB32

APB subbeat0
APB subbeat1
```

两个 subbeat 必须作为 atomic APB scheduling unit。

---

# 10. Transfer Engine

Transfer Engine 是 X2P 核心。

负责把：

```text
AXI transaction semantics
```

转换为：

```text
APB transfer sequence
```

内部逻辑关系：

```text
AXI Transaction
       |
       v
Burst Engine
       |
       v
AXI Beat
       |
       v
Lane / Width Engine
       |
       v
APB Sub-Transfer(s)
```

---

# 11. Burst Engine

维护：

```text
burst_type
burst_len
burst_size
beat_index
current_addr
```

---

# 12. INCR Address

对于 INCR：

```text
beat_bytes = 1 << AxSIZE

next_addr =
    current_addr + beat_bytes
```

---

# 13. FIXED Address

对于 FIXED：

```text
next_addr =
    start_addr
```

---

# 14. WRAP Address Generator

计算：

```text
number_bytes = 1 << AxSIZE

burst_bytes =
    number_bytes * (AxLEN + 1)

wrap_base =
    floor(start_addr / burst_bytes)
    * burst_bytes

wrap_limit =
    wrap_base + burst_bytes
```

地址推进：

```text
next_addr = current_addr + number_bytes

if next_addr == wrap_limit:
    next_addr = wrap_base
```

WRAP Address Generator 只处理 AXI Beat Address。

Width conversion 不能改变 AXI WRAP Boundary 语义。

---

# 15. Width Engine

Width Engine 输入：

```text
AXI Beat Address
AxSIZE
AXI DATA
WSTRB
```

输出：

```text
1...N APB Sub-Transfers
```

---

# 16. Same Width

例如：

```text
AXI32 -> APB32
```

正常 full-width transfer：

```text
1 AXI Beat
    ↓
1 APB Transfer
```

---

# 17. Wide-to-Narrow

例如：

```text
AXI128 -> APB32
```

最大：

```text
1 AXI Beat
    ↓
4 APB Sub-Transfers
```

内部：

```text
subbeat_idx = 0..N-1
```

其中：

```text
N =
AXI_TRANSFER_BYTES / APB_DATA_BYTES
```

但实际产生的 APB transfer 数必须结合：

```text
AxSIZE
address offset
WSTRB
```

决定。

不能无条件按物理 AXI DATA WIDTH 拆满 N 个。

---

# 18. APB Sub-Address

Wide-to-Narrow 情况下：

```text
apb_addr =
axi_beat_addr + subbeat_offset
```

地址必须按照有效 Byte Region 计算，而非简单依赖物理 AXI bus lane 编号。

---

# 19. Write Data Selection

概念上：

```text
PWDATA =
select_bytes(
    AXI_WDATA,
    address,
    subbeat_idx
)
```

PSTRB 同理产生。

---

# 20. Narrow-to-Wide

例如：

```text
AXI32 -> APB64
```

Write：

* WDATA 放置到目标 Byte Lane；
* PSTRB 标识有效 bytes。

Read：

* 从对应 PRDATA Byte Lane 提取 AXI RDATA。

原则上不需要为了单次 Narrow AXI transfer 访问无关 APB bytes。

---

# 21. APB3 Handling

APB3 无 PSTRB。

如果 Width/Narrow 转换产生 partial APB write：

```text
partial_write = 1
```

则：

```text
do not issue APB write
return SLVERR
```

不执行自动 RMW。

---

# 22. CDC Placement

CDC 位于：

```text
Transfer Engine
       |
       v
   CDC Boundary
       |
       v
   APB Engine
```

而不是放在 AXI READY/VALID 信号或 APB FSM signal 之间。

---

# 23. SYNC Mode

SYNC：

```text
Transfer Engine
       |
       +----------------------+
                              |
                         APB Engine
```

CDC Layer 被 bypass / generate-out。

---

# 24. ASYNC Mode

ASYNC：

```text
AXI Domain
   |
Request Channel
   |
+-------------+
| Req CDC     |
+-------------+
   |
================ Clock Boundary
   |
+-------------+
| APB Req Buf |
+-------------+
   |
APB Engine
   |
+-------------+
| Rsp CDC     |
+-------------+
   |
================ Clock Boundary
   |
AXI Response Engine
```

---

# 25. CDC Request Payload

跨域发送完整 APB request：

```text
addr
write
wdata
strb
prot

txn_id
axi_beat_idx
subbeat_idx

beat_last
txn_last
```

因此 APB Domain 不需要了解 AXI Burst 规则。

这是架构上的关键边界。

---

# 26. CDC Response Payload

APB Domain 返回：

```text
txn_id

axi_beat_idx
subbeat_idx

rdata
error

beat_last
txn_last
```

AXI Domain 负责最终：

* read assembly；
* BID/RID；
* BRESP/RRESP。

---

# 27. CDC Ordering

Req CDC 必须保持 request FIFO order。

Rsp CDC 必须保持 APB completion order。

由于 APB Backend 串行执行：

```text
APB response reorder = NOT REQUIRED
```

---

# 28. CDC Reset Architecture

建议：

```text
aresetn
presetn
```

分别属于 AXI / APB domain。

CDC channel 必须保证：

* pointer reset safe；
* reset release 不产生 false valid；
* domain 单独复位后 stale request 不会被重新消费。

---

# 29. APB Engine

APB Engine 输入的已经是单个完整 APB Transfer Descriptor。

因此其 FSM 可以非常纯净：

```text
IDLE
  |
  v
SETUP
  |
  v
ACCESS
  | \
  |  \ timeout
  |   \
PREADY  TIMEOUT
  |
  v
COMPLETE
```

---

# 30. APB FSM

## IDLE

等待 request。

## SETUP

输出：

```text
PSEL    = 1
PENABLE = 0
```

## ACCESS

输出：

```text
PSEL    = 1
PENABLE = 1
```

等待：

```text
PREADY
```

---

# 31. Back-to-Back APB

如果存在下一 request，APB Engine 应尽可能实现合法的 back-to-back transfer。

例如：

```text
SETUP0
ACCESS0
SETUP1
ACCESS1
SETUP2
ACCESS2
```

避免额外 IDLE bubble。

---

# 32. Timeout Controller

进入 ACCESS 后开始计数：

```text
timeout_count = 0
```

每个：

```text
PREADY == 0
```

周期递增。

达到：

```text
TIMEOUT_CYCLES
```

时：

```text
timeout = 1
```

输出 response：

```text
error = SLVERR
```

并结束本地 APB transaction。

---

# 33. Timeout Recovery

Timeout 之后：

```text
PSEL    -> 0
PENABLE -> 0
```

APB Engine 返回 IDLE/下一 SETUP。

注意：

X2P 无法保证已经失去响应的外部 APB Slave 自身内部状态。

因此 Timeout 的语义定义为：

> 防止 X2P/AXI System 被永久阻塞，而不是保证外设事务可回滚。

---

# 34. Response Engine

Response Engine 负责：

```text
APB response
   ↓
subbeat tracking
   ↓
AXI beat completion
   ↓
AXI transaction completion
```

---

# 35. Read Assembly

例如：

```text
AXI64 <- APB32
```

过程：

```text
APB read #0
      |
      +--> read buffer[31:0]

APB read #1
      |
      +--> read buffer[63:32]

      ↓
AXI RDATA
```

只有整个 AXI Beat 完成后产生 RVALID。

---

# 36. Error Aggregation

每个 AXI Beat 保存：

```text
beat_error
```

逻辑：

```text
beat_error =
OR(all APB sub-transfer errors)
```

Write Transaction 保存：

```text
write_txn_error
```

逻辑：

```text
write_txn_error =
OR(all AXI write beat errors)
```

最终：

```text
BRESP =
write_txn_error ? SLVERR : OKAY
```

---

# 37. Outstanding Tracking

每个 Pending Transaction 需要 descriptor。

Read Descriptor：

```text
RID
start_addr
LEN
SIZE
BURST

current_beat
error
```

Write Descriptor：

```text
BID
start_addr
LEN
SIZE
BURST

current_beat
error
```

---

# 38. APB Serialization

无论 AXI outstanding 数量多少：

```text
APB execution width = 1 transaction
```

APB Backend 永远串行。

Request buffering 用于：

* AXI decoupling；
* latency hiding；
* CDC；
* backpressure reduction。

它不会让单个 APB Master 并行执行多个 transfer。

---

# 39. Pipeline Architecture

支持三个 pipeline points：

```text
AXI input
    |
[AXI_INPUT_REG]
    |
AXI Frontend
    |
Transfer Engine
    |
CDC
    |
APB Engine
    |
[APB_OUTPUT_REG]
```

以及：

```text
Response Engine
    |
[AXI_OUTPUT_REG]
    |
AXI R/B
```

---

# 40. APB Output Register

必须特别注意：

PSEL/PENABLE pipeline 不得破坏 APB SETUP/ACCESS phase relationship。

因此 `APB_OUTPUT_REG` 不应简单作为任意 signal slice。

应属于 APB Engine 的 timing mode：

```text
unregistered output
registered output
```

由 FSM 本身控制正确周期关系。

---

# 41. Critical Timing Paths

主要潜在路径：

### AXI Input

```text
AWVALID/ARVALID
  →
queue full
  →
AWREADY/ARREADY
```

### Scheduler

```text
queue state
  →
arbiter
  →
request select
```

### Width Conversion

```text
address + size + subbeat
  →
lane mux
  →
PWDATA/PSTRB
```

### APB Return

```text
PRDATA/PREADY
  →
response
```

ASYNC 模式天然切断 AXI/APB combinational timing path。

---

# 42. PPA Strategy

## Minimal Configuration

Generate-out：

```text
AXI ID tracking
Burst logic
WRAP
width split
CDC
deep queue
timeout
pipeline
```

当对应 Profile 不需要时。

---

# 43. Full Configuration

主要面积贡献预计来自：

1. request buffers；
2. CDC buffers；
3. read assembly buffer；
4. outstanding metadata；
5. AXI data-width dependent mux；
6. WRAP/address arithmetic。

APB FSM 本身面积占比很小。

---

# 44. Recommended Datapath Principle

避免把：

```text
AXI_DATA_WIDTH
```

全部 metadata 都跨 CDC。

只跨 APB Backend 真正所需的当前 Sub-Transfer：

```text
PADDR-width addr
APB_DATA_WIDTH data
APB_DATA_WIDTH/8 strb
```

因此：

> Width Conversion 建议位于 CDC 之前的 AXI/Transaction Domain。

这可以显著降低 Async FIFO Width。

推荐：

```text
AXI
 |
Burst Engine
 |
Width Engine
 |
APB-sized transaction
 |
CDC
 |
APB Engine
```

而不是：

```text
AXI128 complete beat
 |
CDC 128-bit+
 |
Width Convert
 |
APB32
```

---

# 45. Why Width Conversion Before CDC

例如：

```text
AXI128
APB32
```

如果在 CDC 前拆分：

CDC payload data：

```text
32 bit
```

如果在 CDC 后拆分：

CDC payload data：

```text
128 bit
```

异步 FIFO storage、Gray pointer memory payload 和 crossing wiring 都明显增加。

因此 V1.0 推荐架构明确为：

> **AXI Burst/Width decomposition occurs before CDC.**

---

# 46. Transaction Atomicity Boundary

以下结构必须视为不可中断单元：

```text
one AXI Beat
   ↓
all APB Sub-Transfers
```

即一个 AXI Beat 因 Width Conversion 产生 2/4 个 APB Sub-Transfers 时：

Scheduler 不在这些 Sub-Transfer 中间切换另一 Read/Write AXI Beat。

这是为了简化：

* read assembly；
* error aggregation；
* lane state；
* CDC metadata；
* ordering。

---

# 47. Architecture Invariants

必须始终满足：

1. 一个 AXI request 不会丢失；
2. 一个 AXI request 不会执行两次；
3. 一个 APB response 对应唯一 request；
4. APB 同时最多一个 transfer；
5. Wait-State 中 APB control/data stable；
6. 同一个 AXI Beat 的 sub-transfers 连续完成；
7. Width conversion 不改变 AXI burst address semantics；
8. CDC 不改变 transaction order；
9. Timeout 不导致 FSM deadlock；
10. Reset 不产生 phantom transaction。

---

# 48. Recommended RTL Configuration

建议顶层参数：

```systemverilog
parameter int AXI_ADDR_WIDTH
parameter int AXI_DATA_WIDTH
parameter int AXI_ID_WIDTH

parameter int APB_ADDR_WIDTH
parameter int APB_DATA_WIDTH

parameter AXI_PROFILE
parameter APB_PROFILE

parameter int READ_REQUEST_DEPTH
parameter int WRITE_REQUEST_DEPTH

parameter ARB_POLICY
parameter ARB_GRANULARITY

parameter bit TIMEOUT_ENABLE
parameter int TIMEOUT_CYCLES

parameter CLOCK_MODE
parameter int CDC_REQ_DEPTH
parameter int CDC_RSP_DEPTH

parameter bit AXI_INPUT_REG
parameter bit AXI_OUTPUT_REG
parameter bit APB_OUTPUT_REG
```

---

# 49. Recommended Default Configuration

```text
AXI_PROFILE       = AXI4
APB_PROFILE       = APB4

AXI_ADDR_WIDTH    = 32
AXI_DATA_WIDTH    = 64
AXI_ID_WIDTH      = 4

APB_ADDR_WIDTH    = 32
APB_DATA_WIDTH    = 32

READ_REQUEST_DEPTH  = 4
WRITE_REQUEST_DEPTH = 4

ARB_POLICY         = ROUND_ROBIN
ARB_GRANULARITY    = BEAT

TIMEOUT_ENABLE     = 1
TIMEOUT_CYCLES     = 256

CLOCK_MODE         = SYNC

CDC_REQ_DEPTH      = 4
CDC_RSP_DEPTH      = 4

AXI_INPUT_REG      = 0
AXI_OUTPUT_REG     = 0
APB_OUTPUT_REG     = 1
```

---

# 50. Architecture Freeze Criteria

Architecture G1 Freeze 前必须完成：

* AXI AW/W association microarchitecture；
* Request Descriptor format；
* Read/Write Queue model；
* arbitration granularity；
* WRAP address algorithm；
* width-conversion lane rules；
* APB3 partial-write handling；
* CDC request/response payload；
* CDC reset strategy；
* APB timeout recovery；
* read data assembly；
* error aggregation；
* output-register behavior；
* outstanding metadata sizing；
* parameter legality matrix；
* critical timing path analysis。

冻结后：

```text
Status = G1 PASS / Architecture Freeze
```
