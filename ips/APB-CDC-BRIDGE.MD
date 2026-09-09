# APB CDC Bridge — Requirement Specification

> **Document ID**: `aixsilicon:ip:apb_cdc_bridge:req`
> **IP Name**: `apb_cdc_bridge`
> **IP Type**: `Parameterized IP`
> **Category**: `amba / cdc / bridge`
> **Protocol**: AMBA APB3 / APB4
> **Target Version**: `1.0.0`
> **Status**: `Draft / G0 Candidate`
> **Topology**: 1 APB Upstream Port × 1 APB Downstream Port
> **Clocking Model**: Dual Clock Domain
> **Primary Goal**: CDC Correctness / Low Area / Low Power / Predictable Latency / PPA Configurability

---

# 1. Purpose

APB CDC Bridge 用于连接位于不同 Clock Domain 的 APB Initiator 与 APB Target，在保持 APB 协议语义的前提下完成安全的跨时钟域访问。

典型结构：

```text
APB Clock Domain A                 APB Clock Domain B

APB Initiator
     │
     ▼
+------------------+
|  APB CDC Bridge  |
+------------------+
     │
     ▼
 APB Target
```

本 IP 主要解决：

* APB Request 跨时钟域；
* APB Response 跨时钟域；
* PREADY / PRDATA / PSLVERR 语义保持；
* 快时钟 → 慢时钟；
* 慢时钟 → 快时钟；
* 完全异步时钟；
* 同频异相；
* 同源同步异频；
* Clock Pause / Clock Gating；
* 独立 Reset；
* CDC 与 PPA 的平衡。

---

# 2. Product Positioning

APB CDC Bridge 定位为：

> **Single-Transaction APB Protocol-Preserving Clock-Domain-Crossing Bridge**

其职责为：

```text
APB protocol capture
+
CDC transport
+
APB transaction regeneration
+
response return
```

不负责：

* APB 1×N address decode；
* 多 APB Initiator 仲裁；
* AXI/APB protocol conversion；
* APB width conversion；
* APB timeout；
* firewall；
* register remap；
* multiple outstanding；
* burst transaction。

---

# 3. Design Principles

## APBCDC-REQ-001 Protocol Correctness First

Bridge 必须在所有支持的 Clock Relationship 下保持 APB 协议正确性。

不得出现：

* transaction loss；
* duplicate transaction；
* partial transfer；
* wrong PRDATA；
* wrong PSLVERR；
* spurious PREADY；
* metastability propagation；
* transaction replay。

---

## APBCDC-REQ-002 Minimal Protocol State

APB 本身为单事务、非流水协议。

V1.0 应利用这一特性优先采用低复杂度 CDC 架构，不应无条件引入深 Async FIFO。

---

## APBCDC-REQ-003 Parameterized RTL

必须支持参数化：

```text
ADDR_WIDTH
DATA_WIDTH
USER_WIDTH           // 若支持 APB5 扩展可预留
CDC_IMPL
SYNC_STAGES
REQ_DEPTH
RSP_DEPTH
RESET_MODE
```

V1.0 核心支持 APB3/APB4。

---

# 4. APB Interfaces

上游 APB 接口：

```text
s_pclk
s_presetn

s_psel
s_penable
s_paddr
s_pwrite
s_pwdata
s_pstrb
s_pprot

s_prdata
s_pready
s_pslverr
```

下游 APB 接口：

```text
m_pclk
m_presetn

m_psel
m_penable
m_paddr
m_pwrite
m_pwdata
m_pstrb
m_pprot

m_prdata
m_pready
m_pslverr
```

APB3 profile 可裁剪：

```text
PSTRB
PPROT
```

相关逻辑。

---

# 5. Supported Clock Relationships

## APBCDC-REQ-010 Fully Asynchronous

必须支持：

```text
s_pclk
m_pclk
```

无固定频率和相位关系。

包括：

* 任意非整数频率比；
* phase continuously drifting；
* frequency close but asynchronous。

---

## APBCDC-REQ-011 Fast-to-Slow

必须支持：

```text
s_pclk > m_pclk
```

例如：

```text
800 MHz → 100 MHz
400 MHz → 50 MHz
200 MHz → 25 MHz
```

---

## APBCDC-REQ-012 Slow-to-Fast

必须支持：

```text
s_pclk < m_pclk
```

例如：

```text
50 MHz → 200 MHz
100 MHz → 800 MHz
```

---

## APBCDC-REQ-013 Same Frequency Different Phase

必须支持同频但无严格 phase guarantee 的场景。

若 phase relationship 未通过 STA/clock definition 保证，应按 asynchronous-safe 模式处理。

---

## APBCDC-REQ-014 Synchronous Different Frequency

允许支持：

```text
CDC_MODE = SYNC_RATIO
```

用于同源、固定整数频率关系的场景。

但 V1.0 默认安全模式应仍为：

```text
CDC_MODE = ASYNC_SAFE
```

---

# 6. APB Transaction Semantics

## APBCDC-REQ-020 Upstream Capture

Bridge 仅在合法 APB transfer 下接受事务：

```text
s_psel = 1
s_penable = 1
```

并根据内部状态决定：

```text
s_pready
```

---

## APBCDC-REQ-021 Single Transaction

V1.0 任一时刻最多允许一个跨 Bridge 的 APB transaction active。

---

## APBCDC-REQ-022 Upstream Completion

只有在以下两类情况下才允许：

```text
s_pready = 1
```

1. 下游 APB transaction 已完成；
2. Bridge 本地已经确定错误且无需访问下游。

不得在下游尚未完成时提前返回成功。

---

# 7. Request Capture

## APBCDC-REQ-030 Request Bundle

上游事务应锁存以下 payload：

```text
PADDR
PWRITE
PWDATA
PSTRB
PPROT
```

仅对当前 profile 有效字段进行存储。

---

## APBCDC-REQ-031 Stable Payload

跨域期间 Request payload 必须保持稳定，直至下游安全捕获。

禁止将 multi-bit bus 每 bit 独立双触发器同步。

---

# 8. Downstream APB Regeneration

Bridge 必须在 m_pclk 域重新生成合法 APB transaction。

典型状态：

```text
IDLE
  ↓
SETUP
  ↓
ACCESS
  ↓
COMPLETE
```

---

## APBCDC-REQ-040 SETUP Phase

下游必须先产生：

```text
m_psel = 1
m_penable = 0
```

---

## APBCDC-REQ-041 ACCESS Phase

下一 m_pclk 周期进入：

```text
m_psel = 1
m_penable = 1
```

并保持直到：

```text
m_pready = 1
```

---

## APBCDC-REQ-042 Wait State

当：

```text
m_pready = 0
```

时必须保持：

```text
m_psel
m_penable
m_paddr
m_pwrite
m_pwdata
m_pstrb
m_pprot
```

稳定。

---

# 9. Response Capture

## APBCDC-REQ-050 Downstream Completion

当：

```text
m_psel &&
m_penable &&
m_pready
```

时，下游 transaction 完成。

---

## APBCDC-REQ-051 Read Data

Read transaction 必须捕获：

```text
m_prdata
```

并返回：

```text
s_prdata
```

---

## APBCDC-REQ-052 Error

必须捕获：

```text
m_pslverr
```

并返回：

```text
s_pslverr
```

---

# 10. CDC Implementation Profiles

V1.0 推荐支持两种实现：

```text
HANDSHAKE
ASYNC_FIFO
```

并可预留：

```text
SYNC_BRIDGE
```

未来优化。

---

# 11. HANDSHAKE Profile

HANDSHAKE 应作为 V1.0 默认推荐实现。

适用于：

* APB register access；
* low throughput；
* area-first；
* power-first；
* single outstanding。

典型结构：

```text
Source Domain

APB Request
    ↓
Request Latch
    ↓
Req Toggle
    ↓
2FF Sync
    ↓

Destination Domain

Detect Request
    ↓
Execute APB
    ↓
Response Latch
    ↓
Rsp Toggle
    ↓
2FF Sync
    ↓

Source Domain

Return PREADY / PRDATA / PSLVERR
```

---

## APBCDC-REQ-060 Bundle-Data CDC

Request / Response payload 应使用 bundled-data handshake 或等价安全方法。

---

## APBCDC-REQ-061 Control Synchronization

跨域 handshake control 必须通过：

```text
SYNC_STAGES >= 2
```

级 synchronizer。

默认：

```text
SYNC_STAGES = 2
```

---

## APBCDC-REQ-062 Payload Hold

Request payload 在 destination acknowledgement 前不得变化。

Response payload 在 source acknowledgement 前不得变化。

---

# 12. ASYNC FIFO Profile

FIFO profile 用于需要更强 decoupling 的场景。

由于 APB 本身 single outstanding，V1.0 不要求深 FIFO。

推荐：

```text
REQ_DEPTH = 1 / 2
RSP_DEPTH = 1 / 2
```

---

## APBCDC-REQ-070 Request FIFO

可将 Request payload 打包为：

```text
{PADDR, PWRITE, PWDATA, PSTRB, PPROT}
```

进入 CDC FIFO。

---

## APBCDC-REQ-071 Response FIFO

Response payload打包为：

```text
{PRDATA, PSLVERR}
```

---

## APBCDC-REQ-072 No Artificial Outstanding

即使 FIFO depth > 1，V1.0 默认不得改变上游 APB single-transfer completion 语义。

除非未来定义 pipelined APB front-end extension。

---

# 13. Fast-to-Slow Behavior

对于：

```text
s_pclk >> m_pclk
```

最主要问题是下游 APB access 时间变长。

---

## APBCDC-REQ-080 Upstream Wait

上游必须保持：

```text
s_pready = 0
```

直到下游事务完成。

这是 APB 合法 wait-state 行为。

---

## APBCDC-REQ-081 Request Storage

Request 必须在 Source Domain 被锁存，避免长时间依赖上游保持组合数据。

---

## APBCDC-REQ-082 PPA Preference

fast→slow APB 场景默认仍优先：

```text
HANDSHAKE
```

因为 APB 本身不能通过增加 FIFO depth 显著提高上游事务吞吐。

只有在特殊架构中才推荐 FIFO。

---

# 14. Slow-to-Fast Behavior

对于：

```text
s_pclk << m_pclk
```

Destination 通常可以很快完成 SETUP/ACCESS。

---

## APBCDC-REQ-090 Low-Latency Preference

慢→快模式应优先减少：

* synchronizer chain latency；
* extra buffering；
* unnecessary FSM states。

---

## APBCDC-REQ-091 Minimum Buffer

默认：

```text
REQ_DEPTH = 1
RSP_DEPTH = 1
```

即可。

---

# 15. Synchronous Different Frequency

若 clocks 同源且关系由 STA 明确保证，可提供优化模式。

---

## APBCDC-REQ-100 Sync-Ratio Eligibility

只有满足：

* clocks related；
* frequency ratio fixed；
* phase relation timing-analyzable；
* constraints available；

时才允许启用专用 synchronous implementation。

---

## APBCDC-REQ-101 No Automatic Guess

Bridge 不得根据 parameter 中的 MHz 数值自动判断 clocks 是否同步。

---

## APBCDC-REQ-102 Fallback

当 clock relation 无法证明时必须使用 ASYNC_SAFE implementation。

---

# 16. Clock Pause

## APBCDC-REQ-110 Destination Clock Stop

若 m_pclk 暂停：

* 当前 transaction 必须保持 pending；
* s_pready 保持 low；
* transaction 不得丢失。

---

## APBCDC-REQ-111 Source Clock Stop

若 s_pclk 暂停：

* destination 可继续完成当前 APB transaction；
* response 必须保持至 source clock 恢复并安全接收。

---

# 17. Reset Architecture

Bridge 必须支持独立：

```text
s_presetn
m_presetn
```

---

## APBCDC-REQ-120 Reset Style

推荐每个 domain：

```text
async assert
sync deassert
```

---

## APBCDC-REQ-121 Independent Reset

Source / Destination reset 可独立 assert。

---

## APBCDC-REQ-122 Transaction Abort

V1.0 建议明确：

> 任一侧 reset 发生时，正在进行中的跨域 transaction 可被 abort。

系统不得假设 reset 跨越 transaction 后事务仍然有效。

---

## APBCDC-REQ-123 No Stale Transfer

Reset 后不得将 reset 前的：

* request toggle；
* response toggle；
* payload；
* FIFO entry；

识别为新事务。

---

## APBCDC-REQ-124 No Reset Order Dependency

目标应避免要求固定：

```text
source reset first
destination reset second
```

等严格顺序。

---

# 18. Error Behavior on Reset

如果 upstream transaction 尚未完成而 downstream reset：

V1.0 可选择：

```text
stall until recovery
```

或：

```text
abort and return error
```

具体策略必须在 Architecture Specification 中冻结。

PPA 优先建议：

> **stall / reset-abort，不引入复杂 timeout/error reconstruction。**

---

# 19. PPA Objectives

PPA 是本 IP 的一级设计目标。

重点指标：

```text
Area
FF Count
Synchronizer Count
Latency
Dynamic Power
Critical Path
Clock Tree Load
```

---

# 20. Preferred Architecture

对普通 APB CDC，默认优先级：

```text
HANDSHAKE
    ↓
small elastic/FIFO
    ↓
special synchronous bridge
```

而不是：

```text
always async FIFO
```

---

# 21. Handshake PPA Benefits

HANDSHAKE profile 应优先实现：

* 单 Request payload register；
* 单 Response payload register；
* 最少 toggle control；
* 最少 synchronizer；
* 最少 FIFO pointer logic。

典型 area 应显著低于 full async FIFO。

---

# 22. Synchronizer Count Optimization

## APBCDC-REQ-130 Control Only

只同步必要 control。

禁止：

```text
PADDR bit-by-bit 2FF
PWDATA bit-by-bit 2FF
PRDATA bit-by-bit 2FF
```

---

## APBCDC-REQ-131 Shared Handshake

尽量以一个 request control crossing 对整个 request bundle 进行保护，而不是每个字段建立独立 CDC handshake。

Response 同理。

---

# 23. Payload Register Power

Payload register 仅在接受新 transaction 时更新。

Idle 时不得无意义 toggle。

---

# 24. APB Signal Pruning

根据 protocol profile 自动裁剪：

### APB3

可不实现：

```text
PSTRB
PPROT
```

### APB4

支持：

```text
PSTRB
PPROT
```

未启用字段不得保留无意义 datapath。

---

# 25. DATA_WIDTH Scaling

支持：

```text
DATA_WIDTH = 8 / 16 / 32 / 64 / 128
```

推荐重点优化：

```text
32 bit
64 bit
```

APB 超宽数据通路不作为 V1.0 PPA 主要目标。

---

# 26. ADDR_WIDTH Scaling

推荐：

```text
ADDR_WIDTH = 16 ~ 64
```

CDC storage area 应与实际配置位宽线性增长。

---

# 27. Request Packing

内部 request payload 推荐打包，避免多个独立 registers/FIFOs：

```text
REQ_PAYLOAD = {
    PADDR,
    PWRITE,
    PWDATA,
    PSTRB,
    PPROT
}
```

---

# 28. Response Packing

内部 response payload：

```text
RSP_PAYLOAD = {
    PRDATA,
    PSLVERR
}
```

---

# 29. Critical Paths

Source Domain：

```text
s_psel/s_penable
→ request capture
→ s_pready generation
```

Destination Domain：

```text
request detection
→ APB FSM
→ m_psel/m_penable
```

Response：

```text
m_pready/m_prdata
→ response capture
```

Source return：

```text
response detect
→ s_pready/s_prdata
```

---

# 30. No Cross-Domain Combinational Path

严格禁止：

```text
m_pready
combinational
→
s_pready
```

或类似跨时钟域组合路径。

---

# 31. Latency Model

总 APB transaction latency大致由：

```text
source capture
+
request CDC
+
destination SETUP
+
destination ACCESS/wait
+
response CDC
+
source completion
```

组成。

---

# 32. Latency Optimization

V1.0 应避免：

* unnecessary intermediate FIFO；
* duplicate payload register stages；
* redundant synchronizer levels；
* extra destination FSM state。

---

# 33. SYNC_STAGES

支持：

```text
SYNC_STAGES >= 2
```

推荐：

```text
2
```

高可靠场景可配置：

```text
3
```

增加级数必须明确：

```text
MTBF ↑
Area ↑
Latency ↑
```

---

# 34. Dynamic Power Optimization

Idle 时：

* handshake toggle 不变化；
* request/response payload register 不更新；
* downstream APB outputs 尽量保持稳定；
* optional FIFO pointer 不变化。

---

# 35. Clock Gating Compatibility

Bridge 必须兼容 clock gating。

如果某一域处于 gating：

* pending transaction 状态必须保持；
* 该域恢复 clock 后应继续完成 transaction。

系统需要保证必要时能唤醒相关 clock。

---

# 36. CDC Static Requirements

必须通过 CDC signoff。

至少检查：

```text
synchronizer
bundled data
control crossing
reset crossing
reconvergence
combinational CDC
multi-bit CDC
```

---

# 37. Reconvergence

禁止同一个控制事件经多个独立 synchronizer crossing 后在另一侧直接 reconverge。

---

# 38. Assertions

至少建议提供：

```text
one upstream transfer → at most one downstream transfer
one downstream completion → at most one upstream completion
request payload stable during CDC
response payload stable during CDC
no downstream APB protocol violation
no transaction while destination reset
no spurious PREADY
no spurious PSLVERR
```

---

# 39. UVM Verification

UVM 环境应具有独立：

```text
source APB agent
destination APB agent
source clock generator
destination clock generator
```

---

# 40. Clock Relation Coverage

必须覆盖：

```text
1:1 async phase
1:2
1:4
1:8
2:1
4:1
8:1
near-frequency async
random irrational-like ratio
```

---

# 41. Phase Coverage

必须随机化：

```text
initial phase offset
```

并覆盖 phase drift 场景。

---

# 42. APB Transaction Coverage

至少覆盖：

* read；
* write；
* back-to-back upstream APB transfers；
* downstream zero wait；
* downstream single wait；
* long wait；
* random wait；
* PSLVERR；
* reset during transfer。

---

# 43. Fast-to-Slow Verification

重点覆盖：

* upstream long ACCESS wait；
* destination clock pause；
* downstream many wait states；
* request payload stability。

---

# 44. Slow-to-Fast Verification

重点覆盖：

* fast downstream completion；
* response CDC latency；
* no duplicate downstream transaction。

---

# 45. Clock Stop Verification

至少覆盖：

```text
source clock stop before request
source clock stop during response
destination clock stop before request
destination clock stop during ACCESS
```

---

# 46. Reset Verification

至少覆盖：

```text
both reset
source-only reset
destination-only reset
reset during request CDC
reset during APB ACCESS
reset during response CDC
clock stopped during reset
```

---

# 47. PPA Profiles

建议提供：

### LOW_AREA

```text
CDC_IMPL = HANDSHAKE
SYNC_STAGES = 2
```

特点：

```text
minimum FF
minimum power
higher CDC latency
```

---

### BALANCED

```text
CDC_IMPL = HANDSHAKE
SYNC_STAGES = 2
optional source/destination skid register
```

---

### HIGH_RELIABILITY

```text
CDC_IMPL = HANDSHAKE
SYNC_STAGES = 3
```

---

### BUFFERED

```text
CDC_IMPL = FIFO
REQ_DEPTH = 2
RSP_DEPTH = 2
```

仅用于确有 decoupling 需求的场景。

---

# 48. PPA Regression Matrix

至少建立：

| Case | Relation      | DATA_WIDTH | Impl        | Sync Stages |
| ---- | ------------- | ---------: | ----------- | ----------: |
| P0   | Async         |         32 | Handshake   |           2 |
| P1   | Async         |         64 | Handshake   |           2 |
| P2   | Fast→Slow 8:1 |         32 | Handshake   |           2 |
| P3   | Slow→Fast 1:8 |         32 | Handshake   |           2 |
| P4   | Async         |         32 | Handshake   |           3 |
| P5   | Async         |         32 | FIFO-2      |           2 |
| P6   | Async         |         64 | FIFO-2      |           2 |
| P7   | Sync 4:1      |         32 | Sync Bridge |           - |

---

# 49. PPA Metrics

至少记录：

```text
Total Area
Sequential Area
Combinational Area
FF Count
Synchronizer FF Count
Storage Bits
Source Critical Path
Destination Critical Path
Source Fmax
Destination Fmax
Average Transfer Latency
Dynamic Power
Leakage Power
```

---

# 50. Expected PPA Trends

预期：

```text
DATA_WIDTH ↑
→ payload storage area ↑

ADDR_WIDTH ↑
→ request storage area ↑

SYNC_STAGES ↑
→ synchronizer FF ↑
→ latency ↑
→ MTBF ↑

Handshake
→ lowest area
→ lowest storage
→ limited throughput

FIFO
→ area ↑
→ buffering capability ↑
```

---

# 51. PPA Optimization Priority

对于普通 APB CDC，优化优先级建议：

```text
1. CDC correctness
2. Area
3. Dynamic power
4. Latency
5. Throughput
```

因为 APB 通常用于低带宽 peripheral/control path。

---

# 52. Invalid Configuration

至少检测：

```text
ADDR_WIDTH <= 0
DATA_WIDTH <= 0
DATA_WIDTH % 8 != 0
SYNC_STAGES < 2 in async mode
unsupported CDC_IMPL
illegal FIFO depth
unsupported APB profile
```

---

# 53. FuseSoC Integration

提供：

```text
aixsilicon:ip:apb_cdc_bridge:1.0.0
```

至少支持：

```text
simulation
lint
cdc
synthesis
formal
```

target。

---

# 54. Deliverables

```text
rtl/
verification/
cdc/
formal/
docs/
fusesoc/
scripts/
```

文档至少包括：

```text
requirement.md
architecture.md
validation_plan.md
cdc_signoff.md
ppa_report.md
user_guide.md
```

---

# 55. Explicitly Out of Scope

V1.0 不支持：

```text
APB 1×N
APB N×1
Arbitration
AXI conversion
AHB conversion
Data width conversion
Address remap
Multiple outstanding
Burst
Timeout
Retry
Firewall
ECC
Parity
Functional safety monitor
```

---

# 56. Acceptance Criteria

## Functional

必须通过：

* APB read；
* APB write；
* PREADY propagation；
* PRDATA propagation；
* PSLVERR propagation；
* arbitrary wait states；
* async clocks；
* fast→slow；
* slow→fast；
* same-frequency phase shift；
* clock pause；
* independent reset。

## CDC

必须完成：

```text
CDC Static Signoff PASS
```

且无：

* unsafe single-bit crossing；
* unsafe multi-bit crossing；
* combinational CDC；
* reconvergence violation；
* reset release violation。

## Verification

必须完成：

```text
UVM Regression PASS
Assertions PASS
Formal targeted properties PASS
```

## PPA

必须完成 Handshake 与 FIFO 代表配置对比，并确认默认 Handshake profile 具有合理的面积/功耗优势。

---

# 57. Recommended V1.0 Architecture

V1.0 默认推荐：

```text
                Source APB Domain
                       │
                 APB Capture FSM
                       │
                 Request Register
                       │
                 Request Toggle
                       │
                   2FF Sync
                       │
                       ▼
             Destination APB Domain
                       │
                APB Generate FSM
                       │
                  APB Target
                       │
              PRDATA / PSLVERR
                       │
                Response Register
                       │
                Response Toggle
                       │
                   2FF Sync
                       │
                       ▼
                Source APB Domain
                       │
             PREADY/PRDATA/PSLVERR
```

这应作为：

> **LOW_AREA / DEFAULT**

实现。

---

# 58. Final Definition

APB CDC Bridge V1.0 定义为：

> **一个双时钟域、单事务、协议保持型 APB CDC Bridge，通过安全的 Request/Response CDC handshake 将上游 APB transaction 重新生成到下游 APB domain，并将 PRDATA、PSLVERR 和 completion 状态安全返回上游。**

其设计原则为：

```text
APB low throughput
→ Handshake First

Fast → Slow
→ Wait-state + request holding

Slow → Fast
→ Minimize CDC latency

Unknown clock relationship
→ Async-safe

Known synchronous relation
→ Optional specialized optimization

No need for buffering
→ Never pay FIFO cost
```

最终目标是：

> **利用 APB 天然 single-transaction、low-bandwidth 的特点，以最少的 CDC 状态和存储获得可靠跨域，而不是简单用 Async FIFO 粗暴包裹整个 APB。**
