# P2P 1×N Parameterized IP — Requirement Specification

> **Document ID**: `aixsilicon:ip:p2p_1n:req`
> **IP Name**: `p2p_1n`
> **IP Type**: `Parameterized IP`
> **Category**: `lightweight-interconnect`
> **Target Version**: `1.0.0`
> **Status**: `Draft / G0 Candidate`
> **Clocking Model**: Single Clock Domain
> **Primary Goal**: Low Latency / Low Area / High Frequency / Predictable PPA

---

# 1. Purpose

P2P 1×N 是一个单 Initiator、多 Target 的轻量级片上互联 IP。

其主要功能为：

* Address Decode；
* Request 1→N Routing；
* Response N→1 Mux；
* Target Select Tracking；
* Unmapped Address Error；
* Target Error Propagation；
* Request / Response Backpressure；
* 可配置 Pipeline；
* 面向不同规模的 PPA 优化。

P2P 1×N 不承担：

* 多 Initiator 仲裁；
* N×M Crossbar；
* CDC；
* AXI/APB 协议转换；
* Burst；
* QoS；
* Multiple Outstanding；
* Response Reordering。

---

# 2. Product Positioning

P2P 1×N 定位为：

> **Single-Initiator Multi-Target Lightweight Request/Response Router**

典型结构：

```text
                   Initiator
                       │
                       ▼
                +-------------+
                |   P2P 1×N   |
                +------+------+ 
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
       Target0      Target1      TargetN
```

典型应用：

* X2P 下游 local fabric；
* SRAM Controller 内部资源路由；
* Accelerator 内部寄存器 / SRAM / local engine 访问；
* Peripheral Cluster；
* P2P→APB Adapter 上游；
* SoC 子系统内轻量控制互联。

---

# 3. Design Principles

## P2P-REQ-001 Lightweight

P2P 必须保持轻量。

在 V1.0 中不得引入：

* arbitration；
* transaction ID；
* reorder buffer；
* multi-outstanding tracker；
* CDC logic；
* complex protocol state。

---

## P2P-REQ-002 Parameterized RTL

P2P 必须采用 Parameterized RTL 实现。

核心配置至少包括：

```text
NUM_TARGETS
ADDR_WIDTH
DATA_WIDTH
USER_WIDTH
REQ_PIPELINE
RSP_PIPELINE
```

参数变化不得要求修改 RTL source。

---

## P2P-REQ-003 Single Initiator

必须且仅支持一个 Initiator。

---

## P2P-REQ-004 Multiple Targets

必须支持：

```text
NUM_TARGETS >= 1
```

V1.0 推荐重点验证：

```text
1 / 2 / 4 / 8 / 16 / 32
```

---

## P2P-REQ-005 Single Clock Domain

Initiator、P2P 和所有 Target 必须处于同一 clock domain。

V1.0 不支持 CDC。

---

# 4. Transaction Model

P2P 采用 Request / Response 模型：

```text
Initiator
   │ Request
   ▼
Target
   │ Response
   ▼
Initiator
```

V1.0 采用：

> **Single Outstanding Transaction**

任一时刻最多允许一个尚未完成的事务。

---

# 5. Request Interface

Request Channel 至少包含：

```text
req_valid
req_ready
req_addr
req_write
req_wdata
req_wstrb
```

可选：

```text
req_user
```

---

## P2P-REQ-010 Request Handshake

事务接受条件：

```text
req_valid && req_ready
```

---

## P2P-REQ-011 Request Stability

当：

```text
req_valid = 1
req_ready = 0
```

时，Initiator 必须保持：

```text
req_addr
req_write
req_wdata
req_wstrb
req_user
```

稳定。

P2P 必须正确支持该行为。

---

## P2P-REQ-012 Address Width

支持参数：

```text
ADDR_WIDTH
```

推荐范围：

```text
8 ~ 64
```

---

## P2P-REQ-013 Data Width

支持参数：

```text
DATA_WIDTH
```

至少覆盖：

```text
8
16
32
64
128
256
512
```

并要求：

```text
DATA_WIDTH % 8 == 0
```

---

## P2P-REQ-014 Write Strobe

必须支持：

```text
WSTRB_WIDTH = DATA_WIDTH / 8
```

---

# 6. Response Interface

Response Channel 至少包含：

```text
rsp_valid
rsp_ready
rsp_rdata
rsp_error
```

可选：

```text
rsp_user
```

---

## P2P-REQ-020 Response Handshake

Response 完成条件：

```text
rsp_valid && rsp_ready
```

---

## P2P-REQ-021 Response Stability

当：

```text
rsp_valid = 1
rsp_ready = 0
```

时：

```text
rsp_rdata
rsp_error
rsp_user
```

必须保持稳定。

---

# 7. Address Map

每个 Target 应配置：

```text
BASE
SIZE
```

推荐参数化形式支持 per-target array。

---

## P2P-REQ-030 Address Region

每个 Target 必须具有独立 address region。

---

## P2P-REQ-031 Power-of-Two Size

V1.0 要求：

```text
SIZE = 2^N
```

---

## P2P-REQ-032 Alignment

要求：

```text
BASE % SIZE == 0
```

---

## P2P-REQ-033 No Overlap

不同 Target 的 address region 不得 overlap。

应通过：

* elaboration-time assertion；
* static check；
* simulation assertion；

至少一种方式检测非法配置。

---

## P2P-REQ-034 Address Range

所有 region 必须位于：

```text
0 ~ 2^ADDR_WIDTH - 1
```

范围内。

---

# 8. Address Decode

## P2P-REQ-040 Unique Decode

任意合法地址最多只能命中一个 Target。

逻辑语义：

```text
$onehot0(target_hit)
```

---

## P2P-REQ-041 Decode Miss

若地址未命中任何 Target：

```text
decode_miss = 1
```

---

## P2P-REQ-042 No Request on Miss

发生 decode miss 时：

```text
target_req_valid[*] = 0
```

---

## P2P-REQ-043 Decode Optimization

对于 power-of-two、aligned region，RTL 应优先采用可被综合工具高效优化的地址比较形式。

不得强制采用：

```text
addr >= base && addr <= end
```

作为唯一实现形式。

推荐等价实现：

```text
(addr & mask) == base
```

或有效高位比较。

---

## P2P-REQ-044 Compare-Bit Reduction

地址译码不得无条件比较全部 ADDR_WIDTH。

应尽量只比较区分 Target 所需的有效地址位。

---

# 9. Request Routing

## P2P-REQ-050 One-Hot Routing

合法 request 只能送到一个 Target。

---

## P2P-REQ-051 Non-Selected Target

未选中 Target 必须满足：

```text
target_req_valid = 0
```

---

## P2P-REQ-052 Payload

被选中 Target 必须收到完整 request payload。

---

## P2P-REQ-053 Request Ready

Initiator：

```text
req_ready
```

应由以下因素共同决定：

* 当前是否允许接受新事务；
* Selected Target ready；
* Request pipeline 可用状态。

---

# 10. Response Routing

## P2P-REQ-060 Target Tracking

Request 被接受时，P2P 必须保存：

```text
active_target
```

或采用功能等价机制。

---

## P2P-REQ-061 Response Selection

Initiator response 只能来自 active target。

---

## P2P-REQ-062 Non-Active Response

非 active Target 的 response 不得被返回 Initiator。

---

## P2P-REQ-063 Response Ready

只有 active Target 的：

```text
target_rsp_ready
```

允许响应 Initiator 的：

```text
rsp_ready
```

非 active Target 不得收到伪 ready handshake。

---

# 11. Outstanding Control

## P2P-REQ-070 Single Outstanding

V1.0 固定：

```text
MAX_OUTSTANDING = 1
```

---

## P2P-REQ-071 Busy

Request handshake 后进入：

```text
BUSY
```

状态。

---

## P2P-REQ-072 New Request

在当前 Response 完成前，不接受下一事务。

---

## P2P-REQ-073 Completion

当：

```text
rsp_valid && rsp_ready
```

完成后返回：

```text
IDLE
```

---

# 12. Error Handling

## P2P-REQ-080 Unmapped Error

Decode miss 必须由 P2P 内部生成 error response。

---

## P2P-REQ-081 No Hang

Unmapped access 不得：

* hang；
* silently drop；
* route to arbitrary Target。

---

## P2P-REQ-082 Target Error

Target 返回的：

```text
rsp_error
```

必须透明传播到 Initiator。

---

# 13. Backpressure

## P2P-REQ-090 Target Backpressure

Selected Target 可通过：

```text
target_req_ready = 0
```

阻塞 request。

---

## P2P-REQ-091 Initiator Backpressure

Initiator 可通过：

```text
rsp_ready = 0
```

阻塞 response。

---

## P2P-REQ-092 Stability Under Stall

发生 stall 时必须保证：

* Request 不丢失；
* Response 不丢失；
* Payload 稳定；
* active_target 稳定；
* Transaction 不重复。

---

# 14. Pipeline

Pipeline 是 P2P PPA 调优的核心参数之一。

---

## P2P-REQ-100 Zero Pipeline

必须支持：

```text
REQ_PIPELINE = 0
RSP_PIPELINE = 0
```

低延迟模式。

---

## P2P-REQ-101 Request Pipeline

必须支持：

```text
REQ_PIPELINE = 0 / 1
```

V1.0 至少支持 0 和 1。

---

## P2P-REQ-102 Response Pipeline

必须支持：

```text
RSP_PIPELINE = 0 / 1
```

---

## P2P-REQ-103 Elastic Pipeline

所有 pipeline 必须正确支持 valid/ready backpressure。

不得使用仅延迟 data 而不处理 ready/valid 的普通寄存器。

---

## P2P-REQ-104 Pipeline Bypass

当 pipeline depth = 0 时，对应寄存器和控制逻辑必须被完全裁剪。

---

# 15. Latency Requirements

## P2P-REQ-110 Zero-Added-Cycle Goal

对于：

```text
REQ_PIPELINE = 0
RSP_PIPELINE = 0
```

P2P 不应强制增加固定 cycle latency。

---

## P2P-REQ-111 Request Path

低延迟模式下允许：

```text
addr decode
→ target request
```

同周期完成。

---

## P2P-REQ-112 Response Path

低延迟模式下允许：

```text
target response
→ initiator response
```

同周期完成。

---

## P2P-REQ-113 Predictable Pipeline Latency

启用 pipeline 后，每级增加的 latency 必须可预测并在 User Guide 中说明。

---

# 16. PPA Requirements

PPA 是 P2P V1.0 的核心设计目标。

必须同时关注：

```text
Latency
Timing
Area
Power
```

---

# 17. PPA Scaling

## P2P-REQ-120 Target Count Scaling

面积应随：

```text
NUM_TARGETS
```

近似线性增长。

不得因为参数化实现引入明显高于必要复杂度的结构增长。

---

## P2P-REQ-121 Data Width Scaling

Response data mux 面积通常随：

```text
NUM_TARGETS × DATA_WIDTH
```

增长。

RTL 应采用结构清晰、易于综合工具优化的 mux 表达方式。

---

## P2P-REQ-122 Register Scaling

关闭 pipeline 时不得保留与 Target 数量成比例的不必要寄存器。

---

# 18. Critical Path Management

P2P 至少应关注以下关键路径：

```text
P1: req_addr → address decode → target_req_valid

P2: target_req_ready → req_ready

P3: target_rsp_rdata → response mux → rsp_rdata

P4: rsp_ready → target_rsp_ready
```

其中 P1 和 P3 为重点优化对象。

---

# 19. Address Decode PPA

## P2P-REQ-130 Decode Sharing

对于多个具有公共高位的 region，应允许综合工具共享公共比较逻辑。

RTL 编码不得阻碍这种优化。

---

## P2P-REQ-131 Decode Fanout

`req_addr` 的大 fanout 应纳入 timing 评估。

对于较多 Target，应允许：

* synthesis replication；
* decode factoring；
* optional request pipeline。

---

## P2P-REQ-132 One-Hot Select

推荐内部使用：

```text
target_sel_onehot
```

或等价形式进行 request routing。

是否同时保留 encoded target index，由微架构决定。

---

# 20. Response Mux PPA

## P2P-REQ-140 Response Data Mux

Response data path 不得通过低效的软件式动态结构实现。

必须生成可被综合工具识别为标准 mux 的 RTL。

---

## P2P-REQ-141 Mux Depth

对于较大 NUM_TARGETS，设计应避免不必要的串行 priority-mux chain。

---

## P2P-REQ-142 Balanced Mux

推荐 RTL 结构允许综合工具构建：

```text
balanced mux tree
```

而不是固定：

```text
if / else if / else if / ...
```

造成深 priority chain。

---

# 21. Ready Path PPA

## P2P-REQ-150 Request Ready

不得无必要形成：

```text
Target ready
→ deep decode
→ complex control
→ Initiator ready
```

的超长组合路径。

---

## P2P-REQ-151 Response Ready

Response ready routing 应尽量保持：

```text
rsp_ready
→ active target
```

简单。

---

## P2P-REQ-152 No Combinational Loop

Request / Response ready-valid 组合不得形成 combinational loop。

---

# 22. Pipeline PPA Modes

建议定义三个推荐 profile。

### LOW_LATENCY

```text
REQ_PIPELINE = 0
RSP_PIPELINE = 0
```

目标：

* 最低 latency；
* 最少 register；
* 接受较长组合路径。

### BALANCED

```text
REQ_PIPELINE = 1
RSP_PIPELINE = 0
```

或项目推荐配置。

目标：

* 打断 address decode / request path；
* 保持 response 低延迟。

### HIGH_FREQUENCY

```text
REQ_PIPELINE = 1
RSP_PIPELINE = 1
```

目标：

* 优先 timing closure；
* 接受增加 latency / FF area。

---

# 23. Power Optimization

## P2P-REQ-160 Non-Selected Target Activity

未选中的 Target 不得产生无必要 request-valid toggle。

---

## P2P-REQ-161 Payload Toggle

对于未选中的 Target，是否复制：

```text
addr/data/write/wstrb
```

到所有 Target 端口，必须考虑动态功耗。

优先推荐：

> 非选中 Target 尽量减少无意义 payload switching。

但不得以明显恶化 timing 为代价。

---

## P2P-REQ-162 Idle Power

P2P 在无事务时：

* control state 应保持稳定；
* pipeline valid 应保持稳定；
* 不应存在无意义 toggle。

---

# 24. Structural Optimization

## P2P-REQ-170 NUM_TARGETS = 1

对于：

```text
NUM_TARGETS = 1
```

应尽量退化为：

```text
direct connection
+
optional pipeline
+
minimal error logic
```

不得保留 N-way routing 结构。

---

## P2P-REQ-171 USER_WIDTH = 0

必须完全删除：

```text
req_user
rsp_user
```

相关内部逻辑。

---

## P2P-REQ-172 Pipeline Disabled

Pipeline 关闭后，相应 storage/control 应完全裁剪。

---

# 25. Flat Architecture

V1.0 默认采用：

> **Flat 1×N Architecture**

基本结构：

```text
                      Initiator
                          │
                          ▼
                 Optional Req Pipe
                          │
                          ▼
                 Address Decoder
                          │
                    target_select
                          │
                          ▼
                  Request Demux
               ┌─────┬─────┬─────┐
               ▼     ▼     ▼     ▼
              T0    T1    ...   TN
               │     │            │
               └─────┴─────┬──────┘
                           ▼
                    Response Mux
                           │
                           ▼
                 Optional Rsp Pipe
                           │
                           ▼
                       Initiator
```

---

# 26. Hierarchical Implementation

V1.0 不要求实现内部 hierarchical multi-stage routing。

当：

```text
NUM_TARGETS
```

过大导致 timing 不满足时，优先通过：

* pipeline；
* synthesis optimization；
* upper-level hierarchy；

解决。

未来版本可增加 hierarchical P2P。

这样可以避免 V1.0 Parameterized IP 过度复杂。

---

# 27. Parameter Set

建议最小参数集合：

```systemverilog
parameter int NUM_TARGETS
parameter int ADDR_WIDTH
parameter int DATA_WIDTH
parameter int USER_WIDTH
parameter bit REQ_PIPELINE
parameter bit RSP_PIPELINE
parameter logic [ADDR_WIDTH-1:0] TARGET_BASE [NUM_TARGETS]
parameter logic [ADDR_WIDTH-1:0] TARGET_MASK [NUM_TARGETS]
```

具体 parameter 语法由 Architecture Specification 确定。

---

# 28. Configuration Validation

必须检查：

* NUM_TARGETS >= 1；
* ADDR_WIDTH 合法；
* DATA_WIDTH % 8 == 0；
* USER_WIDTH >= 0；
* Target range 对齐；
* Target range 不 overlap；
* Target range 不超出 ADDR_WIDTH；
* pipeline 参数合法。

---

# 29. Reset

## P2P-REQ-180 Reset

P2P 使用单一 reset：

```text
rst_n
```

---

## P2P-REQ-181 Reset State

Reset 后必须：

```text
busy = 0
```

并清除：

* active target；
* pipeline valid；
* pending response。

---

## P2P-REQ-182 No Spurious Transfer

Reset 期间及退出 reset 后不得产生伪 request / response。

---

# 30. Debuggability

RTL 必须具有清晰的内部信号命名。

推荐：

```text
target_hit
target_sel
decode_miss
active_target
busy
```

---

# 31. Assertions

建议提供至少以下 assertion：

```text
target_hit is onehot0
no request while busy
no multi-target valid
payload stable under stall
response comes from active target
no response without outstanding request
no transfer during reset
```

---

# 32. Verification Requirements

至少覆盖：

### Target Count

```text
1×1
1×2
1×4
1×8
1×16
1×32
```

### Data Width

```text
32
64
128
256
```

### Pipeline

```text
REQ=0 RSP=0
REQ=1 RSP=0
REQ=0 RSP=1
REQ=1 RSP=1
```

### Address

* base；
* end；
* middle；
* gap；
* unmapped；
* overlap rejection。

### Stall

* request stall；
* response stall；
* long stall；
* random stall。

---

# 33. PPA Regression Requirements

P2P 必须建立固定 PPA regression matrix。

至少包含：

| Case | Targets | Data Width | Req Pipe | Rsp Pipe |
| ---- | ------: | ---------: | -------: | -------: |
| P0   |       1 |         32 |        0 |        0 |
| P1   |       4 |         32 |        0 |        0 |
| P2   |       8 |         64 |        0 |        0 |
| P3   |      16 |         64 |        0 |        0 |
| P4   |      16 |        128 |        0 |        0 |
| P5   |      32 |         64 |        0 |        0 |
| P6   |      16 |         64 |        1 |        0 |
| P7   |      32 |        128 |        1 |        1 |

---

# 34. PPA Metrics

每个 regression case 至少记录：

```text
Total Area
Combinational Area
Sequential Area
Register Count
Critical Path Delay
Maximum Frequency
Dynamic Power
Leakage Power
Request Latency
Response Latency
```

如无真实工艺功耗数据，可至少保留：

```text
toggle-based relative power proxy
```

或 synthesis cell statistics。

---

# 35. PPA Trend Requirements

重点不是规定某个绝对面积，而是要求：

> 参数变化后的 PPA 趋势必须合理且可解释。

至少关注：

```text
NUM_TARGETS ↑
→ decode/mux area approximately ↑

DATA_WIDTH ↑
→ response mux area approximately ↑

PIPELINE ↑
→ register area ↑
→ timing improves
→ latency ↑
```

若趋势异常，应进入 PPA review。

---

# 36. PPA Review Threshold

当参数扩大后出现以下现象之一，应进行架构评审：

* critical path 明显呈非预期恶化；
* area 增长明显高于理论规模增长；
* ready path 成为主 critical path；
* response mux 成为不可收敛瓶颈；
* pipeline 后频率改善不明显；
* dynamic power 随 NUM_TARGETS 异常增长。

---

# 37. FuseSoC Integration

P2P 应提供标准 FuseSoC Core。

推荐：

```text
aixsilicon:ip:p2p_1n:1.0.0
```

FuseSoC 负责：

* source files；
* parameters；
* simulation target；
* lint target；
* synthesis target；
* dependency management。

P2P 本身不依赖额外 Generator Runtime。

---

# 38. Deliverables

V1.0 至少包含：

```text
rtl/
docs/
verification/
fusesoc/
scripts/
```

文档至少包括：

```text
requirement.md
architecture.md
validation_plan.md
user_guide.md
ppa_report.md
```

---

# 39. Out of Scope

V1.0 明确不支持：

```text
Multi-Initiator
N×1
N×M
Arbitration
CDC
Asynchronous Clock
Burst
Multiple Outstanding
Transaction ID
Response Reordering
QoS
Protocol Conversion
AXI
APB
Timeout
Retry
ECC
Parity
Firewall
Coherency
```

---

# 40. Acceptance Criteria

V1.0 Release 至少满足：

### Functional

* Address decode PASS；
* Request routing PASS；
* Response routing PASS；
* Backpressure PASS；
* Decode miss PASS；
* Target error PASS；
* Reset PASS；
* Pipeline PASS。

### Parameterization

代表配置：

```text
1 / 2 / 4 / 8 / 16 / 32 Targets
32 / 64 / 128 / 256 bit
```

能够正确 elaboration、simulation、synthesis。

### Quality

完成：

```text
Compile PASS
Lint PASS
Simulation PASS
Synthesis PASS
Assertions PASS
```

### PPA

完成代表 configuration 的 PPA regression，并证明：

* 参数扩展趋势合理；
* zero-pipeline 模式具备最低 latency；
* pipeline 模式能够改善 timing；
* NUM_TARGETS=1 可以有效裁剪；
* USER_WIDTH=0 可以有效裁剪。

---

# 41. Final Definition

P2P 1×N V1.0 定义为：

> **单时钟域、单 Initiator、单 Outstanding、可参数化的轻量级 Request/Response Router，通过地址译码、1→N Request Routing、N→1 Response Mux 和可选 Elastic Pipeline，实现低面积、低延迟且可调频率的内部互联。**

其优化原则为：

```text
Small N
→ Low Latency First

Large N
→ Timing-Aware

Pipeline Disabled
→ Minimum Area / Latency

Pipeline Enabled
→ Frequency First

Unused Feature
→ Fully Pruned
```

P2P 的核心不是提供复杂协议能力，而是：

> **在最小协议复杂度下，把 1×N 地址路由做到尽可能好的 PPA。**
