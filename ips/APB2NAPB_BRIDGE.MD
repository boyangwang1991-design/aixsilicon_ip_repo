删除 INF-007 apb_interconnect
INF-005 apb_demux → 明确定义成 1 APB → N APB Router
直接归到 INF-005 apb_demux，没必要再新建一个 apb_1ton_bridge IP。

# APB 1-to-N Bridge — Requirement Specification

> **Document ID**: `aixsilicon:ip:apb-1ton-bridge:req`
> **IP Name**: `apb_1ton_bridge`
> **Category**: `bus / peripheral interconnect`
> **Protocol**: AMBA APB3 / APB4
> **Implementation Type**: Parameterized SystemVerilog IP
> **Target Version**: `1.0.0`
> **Status**: Draft

---

# 1. Purpose

`APB 1-to-N Bridge` 用于将一个上游 APB 访问端口按照地址空间路由至多个下游 APB Slave。

IP 根据上游 `PADDR` 完成地址译码，产生对应下游端口的 `PSEL`，并将被选中下游端口的 `PRDATA / PREADY / PSLVERR` 返回上游。

典型应用：

* SoC Peripheral Bus；
* X2P Bridge 后级 APB fanout；
* 多个低速 Peripheral 的 APB 地址空间组织；
* APB 子系统分层互联。

---

# 2. Scope

## 2.1 V1.0支持

V1.0支持：

* 1 个上游 APB Slave-facing interface；
* N 个下游 APB Master-facing interfaces；
* APB3；
* APB4；
* 可参数化下游端口数量；
* 可参数化地址宽度；
* 可参数化数据宽度；
* 每个下游端口独立地址区间；
* 地址译码；
* `PSEL` one-hot 生成；
* 请求信号 fanout；
* 返回信号 mux；
* Decode Miss 错误响应；
* APB wait-state；
* PSLVERR 透传；
* 可选地址 offset/remap；
* 可选 transaction timeout；
* 可选 response register；
* 配置合法性检查脚本。

---

## 2.2 V1.0不支持

以下功能不属于本 IP：

* Multiple upstream masters；
* Arbitration；
* Outstanding transaction；
* Transaction reordering；
* AXI/APB protocol conversion；
* Clock Domain Crossing；
* Async APB；
* QoS；
* Security / MPU / Firewall；
* Dynamic address remapping；
* Runtime programmable address map。

跨时钟访问应通过独立 `APB CDC Bridge` 完成。

---

# 3. Architecture Overview

推荐架构：

```text
                         PADDR
                           │
                           ▼
                    +-------------+
                    | Address     |
                    | Decoder     |
                    +-------------+
                           │
                       select[N]
                           │
             ┌─────────────┴─────────────┐
             │                           │
             ▼                           ▼
      +---------------+           +---------------+
      | Request       |           | Response      |
      | Fanout        |           | MUX           |
      +---------------+           +---------------+
             │                           ▲
     N × APB Request              N × APB Response
             │                           │
             ▼                           │
      +------+------+-------+------------+
      │      │      │       │
     M0     M1     M2      M[N-1]
```

主要逻辑由以下模块构成：

1. Address Decoder
2. PSEL Generator
3. Request Fanout
4. Response MUX
5. Decode Error Handler
6. Optional Timeout Logic
7. Optional Response Register

---

# 4. Interface Definition

## 4.1 Upstream Interface

IP 对上游表现为 APB Slave。

基本信号：

```text
PCLK
PRESETn

PADDR
PSEL
PENABLE
PWRITE
PWDATA

PRDATA
PREADY
PSLVERR
```

APB4额外支持：

```text
PSTRB
PPROT
```

---

## 4.2 Downstream Interfaces

IP 对每个下游端口表现为 APB Master。

每个端口提供：

```text
M_PADDR[i]
M_PSEL[i]
M_PENABLE[i]
M_PWRITE[i]
M_PWDATA[i]

M_PRDATA[i]
M_PREADY[i]
M_PSLVERR[i]
```

APB4：

```text
M_PSTRB[i]
M_PPROT[i]
```

其中：

```text
i = 0 ... NUM_SLAVES-1
```

---

# 5. Parameter Requirements

至少支持以下参数。

```systemverilog
parameter int NUM_SLAVES = 4;
parameter int ADDR_WIDTH = 32;
parameter int DATA_WIDTH = 32;
```

地址配置：

```systemverilog
parameter logic [ADDR_WIDTH-1:0]
    BASE_ADDR [NUM_SLAVES];

parameter logic [ADDR_WIDTH-1:0]
    ADDR_MASK [NUM_SLAVES];
```

也允许实现采用：

```text
BASE_ADDR + ADDR_SIZE
```

形式，但内部推荐转换为：

```text
BASE_ADDR + ADDR_MASK
```

进行地址译码。

---

## 5.1 Optional Parameters

建议支持：

```text
ADDR_REMAP_ENABLE
TIMEOUT_ENABLE
TIMEOUT_CYCLES
OUTPUT_REGISTER
```

默认：

```text
ADDR_REMAP_ENABLE = 0
TIMEOUT_ENABLE    = 0
OUTPUT_REGISTER   = 0
```

默认配置应优先实现：

> 最小面积 + 最低 transaction latency。

---

# 6. Address Decode Requirements

## REQ-ADDR-001

每个下游 APB port 必须具有独立的地址映射区域。

---

## REQ-ADDR-002

地址译码必须基于当前 APB transaction 的 `PADDR`。

推荐实现：

```systemverilog
hit[i] =
    (PADDR & ADDR_MASK[i]) ==
    (BASE_ADDR[i] & ADDR_MASK[i]);
```

---

## REQ-ADDR-003

任意合法地址最多只能命中一个 downstream port。

即：

```text
$onehot0(hit)
```

必须成立。

地址 overlap 应优先通过静态配置检查发现。

---

## REQ-ADDR-004

地址区域推荐满足：

```text
size = power-of-two
base aligned to size
```

以简化 decoder 逻辑。

---

## REQ-ADDR-005

对于合法配置，Generator/配置脚本应尽可能减少无意义地址位比较。

例如：

```text
BASE = 0x4000_0000
SIZE = 0x1000
```

理论上仅需比较：

```text
PADDR[31:12]
```

RTL实现不强制使用特定优化方式，但综合结果不应人为引入完整地址加减比较路径。

---

# 7. Request Routing Requirements

## REQ-ROUTE-001

以下请求信号允许广播至所有 downstream ports：

```text
PADDR
PENABLE
PWRITE
PWDATA
PSTRB
PPROT
```

---

## REQ-ROUTE-002

只有地址命中的 downstream port 可以接收到有效 `PSEL`。

```text
M_PSEL[i] = upstream_PSEL & hit[i]
```

---

## REQ-ROUTE-003

未选中 downstream port：

```text
M_PSEL = 0
```

---

## REQ-ROUTE-004

`M_PENABLE` 必须符合 APB protocol timing。

不得产生：

```text
PENABLE = 1
PSEL    = 0
```

所代表的非法 downstream APB transaction。

实现可以通过：

```text
M_PENABLE[i] = upstream_PENABLE
```

配合 `M_PSEL[i]` 使用。

---

# 8. APB Transaction Behavior

APB transaction 包含：

```text
SETUP PHASE
PSEL    = 1
PENABLE = 0
```

随后：

```text
ACCESS PHASE
PSEL    = 1
PENABLE = 1
```

IP 不得改变标准 APB transaction semantics。

---

## REQ-TRANS-001

当 downstream `PREADY=0` 时，IP 必须保持 transaction 处于 ACCESS phase。

---

## REQ-TRANS-002

在 wait-state 期间：

* downstream selection 不得改变；
* 返回 response source 不得改变。

由于 APB protocol 要求 `PADDR` 在 transaction 期间保持稳定，因此默认架构允许：

> 使用组合地址译码，不额外 latch slave selection。

若实现内部选择寄存器，也不得改变协议可见行为。

---

# 9. Response Routing

## REQ-RESP-001

被选中 downstream port 的：

```text
PRDATA
PREADY
PSLVERR
```

必须返回至 upstream。

---

## REQ-RESP-002

未选中 downstream port 的 response 不得影响 upstream response。

---

## REQ-RESP-003

Response MUX 可以采用：

```text
one-hot mux
```

或等效综合友好结构。

---

## REQ-RESP-004

当 downstream 返回：

```text
PSLVERR = 1
```

IP 必须向 upstream 透传 error response。

不得屏蔽 downstream APB error。

---

# 10. Decode Miss

## REQ-ERR-001

若：

```text
PSEL = 1
```

但当前 `PADDR` 未匹配任何 downstream port，则必须产生 Decode Error。

---

## REQ-ERR-002

Decode Miss 推荐响应：

```text
PREADY  = 1
PSLVERR = 1
PRDATA  = 0
```

即立即结束 transaction。

---

## REQ-ERR-003

Decode Miss 不允许无限等待。

禁止：

```text
PREADY = 0 forever
```

否则可能导致整个 APB fabric hang。

---

# 11. Address Remap

建议支持静态 address offset。

参数：

```text
ADDR_REMAP_ENABLE
```

---

## REQ-REMAP-001

关闭 remap 时：

```text
M_PADDR[i] = PADDR
```

---

## REQ-REMAP-002

开启 remap 时，可采用：

```text
M_PADDR[i] = PADDR - BASE_ADDR[i]
```

例如：

```text
Upstream:
0x4000_0120

Slave local:
0x0000_0120
```

---

## REQ-REMAP-003

Address remap 必须是静态配置。

V1.0不支持 runtime programmable remap。

---

# 12. Timeout

Timeout 为 optional feature。

参数：

```text
TIMEOUT_ENABLE
TIMEOUT_CYCLES
```

---

## REQ-TIMEOUT-001

当 timeout disabled 时，不应引入 timeout counter 相关有效逻辑。

---

## REQ-TIMEOUT-002

若 downstream 长时间保持：

```text
PREADY = 0
```

且持续达到：

```text
TIMEOUT_CYCLES
```

IP 可以终止 transaction 并向 upstream 返回：

```text
PREADY  = 1
PSLVERR = 1
```

---

## REQ-TIMEOUT-003

Timeout counter 仅在有效 ACCESS phase 且 `PREADY=0` 时计数。

---

# 13. Response Register

Response register 为 optional feature：

```text
OUTPUT_REGISTER
```

---

## REQ-PIPE-001

默认：

```text
OUTPUT_REGISTER = 0
```

应采用低延迟组合 response path。

---

## REQ-PIPE-002

开启 response register 后，可以通过插入 APB wait-state 增加一个或多个周期。

不得违反 APB protocol。

---

## REQ-PIPE-003

Response register 主要用于：

* 大 NUM_SLAVES；
* 高频设计；
* response mux timing optimization。

---

# 14. Reset Requirements

## REQ-RST-001

使用：

```text
PRESETn
```

作为 APB reset。

---

## REQ-RST-002

Reset 期间不得产生有效 downstream transaction。

所有：

```text
M_PSEL[i]
```

应保持无效。

---

## REQ-RST-003

若实现：

* timeout counter；
* response register；
* selection register；

均必须进入确定 reset state。

---

# 15. Configuration Validation

本 IP 主体为 Parameterized RTL，不要求使用 RTL Generator。

建议提供轻量 Python 配置检查脚本。

脚本至少检查：

## CFG-001

```text
NUM_SLAVES > 0
```

---

## CFG-002

所有地址必须在：

```text
ADDR_WIDTH
```

表示范围以内。

---

## CFG-003

检查地址区域 overlap。

任何两个 slave address windows 不允许重叠。

---

## CFG-004

若采用 power-of-two window：

```text
SIZE = 2^N
```

且：

```text
BASE_ADDR % SIZE == 0
```

---

## CFG-005

检查：

```text
BASE_ADDR
ADDR_MASK
NUM_SLAVES
```

配置数组长度一致。

---

## CFG-006

检查 `TIMEOUT_CYCLES` 合法。

例如：

```text
TIMEOUT_ENABLE = 1
```

时：

```text
TIMEOUT_CYCLES > 0
```

---

# 16. PPA Requirements

该 IP 应以轻量级 peripheral interconnect 为设计目标。

PPA重点包括：

### Address Decoder

尽量减少：

* comparator 位宽；
* decoder logic depth；
* redundant comparison。

### Response MUX

NUM_SLAVES 较大时，应避免产生明显不平衡 mux tree。

### Fanout

对于较大 NUM_SLAVES，应关注：

```text
PADDR
PWDATA
PENABLE
PWRITE
```

的 fanout。

RTL不应人为增加无必要 buffer/register。

物理 fanout 优化可交由 synthesis / implementation 工具完成。

---

# 17. Recommended Scale

V1.0至少验证：

```text
NUM_SLAVES = 1
NUM_SLAVES = 2
NUM_SLAVES = 4
NUM_SLAVES = 8
NUM_SLAVES = 16
```

建议支持：

```text
NUM_SLAVES <= 32
```

RTL本身不强制设定绝对最大值。

若出现：

```text
32+
64+
128+
```

大量 peripherals，应考虑升级为：

> Hierarchical APB Interconnect

而不是继续无限扩大单级 fanout。

---

# 18. Protocol Assertions

至少建议检查：

### One-hot Select

```systemverilog
$onehot0(M_PSEL)
```

---

### Stable During Wait

ACCESS phase 且：

```text
PREADY = 0
```

期间：

```text
PADDR
PWRITE
PWDATA
PSTRB
PPROT
selected slave
```

必须稳定。

---

### Decode Correctness

命中一个地址区域时，只能选择对应 downstream port。

---

### Decode Miss

未命中地址时：

```text
no downstream PSEL
```

且必须产生合法 error response。

---

# 19. Verification Requirements

至少覆盖以下场景：

1. 每个 downstream slave 的读访问；
2. 每个 downstream slave 的写访问；
3. 地址边界访问；
4. address decode miss；
5. downstream PSLVERR；
6. PREADY immediate；
7. PREADY wait-state；
8. back-to-back transaction；
9. read/write alternating；
10. reset during idle；
11. reset during transaction；
12. address remap enable/disable；
13. timeout enable/disable；
14. output register enable/disable；
15. NUM_SLAVES 不同参数组合；
16. APB3 profile；
17. APB4 PSTRB；
18. APB4 PPROT。

---

# 20. Recommended RTL Structure

推荐保持实现简单：

```text
rtl/
├── apb_1ton_bridge.sv
└── apb_1ton_pkg.sv       # optional
```

主模块内部：

```text
Address Decode
      │
      ├── hit[N]
      │
      ▼
PSEL Generator
      │
      ▼
Request Fanout
      │
      ▼
N APB Ports
      │
      ▼
Response MUX
      │
      ├── Decode Error
      ├── Timeout
      │
      ▼
Upstream Response
```

不建议为了该 IP 进一步拆分大量小型 RTL module。

---

# 21. Implementation Guidance

本 IP 推荐采用：

> **Parameterized SystemVerilog + Configuration Checker + FuseSoC**

而不是完整 RTL Generator。

推荐职责划分：

```text
SystemVerilog
├── Protocol behavior
├── Address decode
├── PSEL generation
├── Request routing
├── Response mux
├── Timeout
└── Pipeline

Python
├── Parameter validation
├── Address overlap check
├── Alignment check
└── Optional mask calculation

FuseSoC
├── RTL source management
├── Dependency management
├── Parameters
├── Simulation target
└── Synthesis target
```

核心原则：

> 参数变化不应重新生成一份新的 APB Bridge RTL。

所有合法参数组合均应复用同一套经过验证的 SystemVerilog 实现。

---

# 22. V1.0 Feature Baseline

| Feature                     | Priority      |
| --------------------------- | ------------- |
| APB3                        | P0            |
| APB4                        | P0            |
| 1 upstream → N downstream   | P0            |
| NUM_SLAVES parameter        | P0            |
| ADDR_WIDTH parameter        | P0            |
| DATA_WIDTH parameter        | P0            |
| Address map parameter       | P0            |
| Address decode              | P0            |
| PSEL one-hot generation     | P0            |
| Request fanout              | P0            |
| Response mux                | P0            |
| Wait-state support          | P0            |
| PSLVERR pass-through        | P0            |
| Decode Error                | P0            |
| Address overlap checker     | P0            |
| Address remap               | P1            |
| Timeout                     | P1            |
| Response register           | P1            |
| CDC                         | Not Supported |
| Arbitration                 | Not Supported |
| Runtime address programming | Not Supported |

---

# 23. Architecture Principle

V1.0应坚持：

```text
Simple
Deterministic
Parameterized
Low Latency
Low Area
Easy to Verify
```

该 IP 本质上应保持为：

```text
Address Decoder
+
PSEL Generator
+
Response MUX
```

而不是演进成复杂 APB Interconnect。

当未来需求出现：

* multiple upstream ports；
* hierarchical topology；
* automatic tree construction；
* pipeline placement；
* 大规模 peripheral topology optimization；

应建立独立：

```text
APB Interconnect Generator
```

而不是继续增加 `APB 1-to-N Bridge` 的复杂度。
