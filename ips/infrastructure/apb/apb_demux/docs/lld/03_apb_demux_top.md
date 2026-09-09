# APB Demux — LLD 顶层模块微架构

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 模块定义

#### LLD.MOD.APB_DEMUX.TOP 顶层参数化模块

<!-- LLD_MODULE_META
id: LLD.MOD.APB_DEMUX.TOP
name: apb_demux_top
hld_ref:
  - HLD.MOD.L1.APB_DEMUX.TOP
  - HLD.MOD.L1.APB_DEMUX.DECODE
  - HLD.MOD.L1.APB_DEMUX.ROUTE
  - HLD.MOD.L1.APB_DEMUX.ERR
req_ref:
  - LRS.FUNC.APB_DEMUX.01.002
  - LRS.FUNC.APB_DEMUX.01.003
  - LRS.FUNC.APB_DEMUX.02.002
  - LRS.FUNC.APB_DEMUX.02.003
  - LRS.FUNC.APB_DEMUX.03.001
  - LRS.FUNC.APB_DEMUX.03.002
  - LRS.FUNC.APB_DEMUX.04.001
  - LRS.FUNC.APB_DEMUX.04.002
  - LRS.FUNC.APB_DEMUX.05.001
  - LRS.FUNC.APB_DEMUX.05.002
  - LRS.FUNC.APB_DEMUX.05.003
  - LRS.FUNC.APB_DEMUX.06.001
  - LRS.FUNC.APB_DEMUX.06.002
  - LRS.FUNC.APB_DEMUX.07.001
  - LRS.FUNC.APB_DEMUX.07.002
  - LRS.FUNC.APB_DEMUX.08.001
  - LRS.FUNC.APB_DEMUX.08.002
  - LRS.RESET.APB_DEMUX.02.002
  - LRS.RESET.APB_DEMUX.02.003
description: 单模块参数化 RTL，集成地址译码、PSEL 生成、请求路由、响应 mux、Decode Miss、可选 timeout/response register
rtl_intent:
  suggested_name: rtl/apb_demux_top.sv
applicability:
  expr: "true"
END_LLD_MODULE_META -->

##### 需求描述

1. 单一 `apb_demux_top.sv` 承载全部逻辑，参数化交付。

---

## 2. 数据通路

### 2.1 地址译码数据通路

#### LLD.DATAPATH.APB_DEMUX.DECODE 地址译码通路

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.APB_DEMUX.DECODE
module_ref: LLD.MOD.APB_DEMUX.TOP
hld_ref:
  - HLD.MOD.L1.APB_DEMUX.DECODE
width: ADDR_WIDTH
direction: combinational
latency: 0
description: |
  hit[i] = (PADDR & ADDR_MASK[i]) == (BASE_ADDR[i] & ADDR_MASK[i])；
  decode_miss = ~|hit；
  M_PSEL[i] = upstream_PSEL & hit[i]。
req_ref:
  - LRS.FUNC.APB_DEMUX.01.002
  - LRS.FUNC.APB_DEMUX.01.003
  - LRS.FUNC.APB_DEMUX.02.002
  - LRS.FUNC.APB_DEMUX.05.001
applicability:
  expr: "true"
END_LLD_DATAPATH_META -->

##### 需求描述

1. 组合译码，无寄存器，wait-state 期间 selection 自然稳定。

---

### 2.2 响应 mux 数据通路

#### LLD.DATAPATH.APB_DEMUX.RESP 响应 mux 通路

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.APB_DEMUX.RESP
module_ref: LLD.MOD.APB_DEMUX.TOP
hld_ref:
  - HLD.MOD.L1.APB_DEMUX.ROUTE
width: DATA_WIDTH
direction: combinational
latency: 0
description: |
  按 hit/N 端口 one-hot mux PRDATA/PREADY/PSLVERR；
  未选中端口响应被屏蔽；
  decode_miss 时返回 PREADY=1, PSLVERR=1, PRDATA=0。
req_ref:
  - LRS.FUNC.APB_DEMUX.04.001
  - LRS.FUNC.APB_DEMUX.04.002
  - LRS.FUNC.APB_DEMUX.05.002
applicability:
  expr: "true"
END_LLD_DATAPATH_META -->

##### 需求描述

1. one-hot mux 或等效综合友好结构；
2. PSLVERR 透传不屏蔽。

---

### 2.3 地址重映射数据通路

#### LLD.DATAPATH.APB_DEMUX.REMAP 地址重映射通路

<!-- LLD_DATAPATH_META
id: LLD.DATAPATH.APB_DEMUX.REMAP
module_ref: LLD.MOD.APB_DEMUX.TOP
hld_ref:
  - HLD.MOD.L1.APB_DEMUX.TOP
width: ADDR_WIDTH
direction: combinational
latency: 0
description: |
  ADDR_REMAP_ENABLE=0: M_PADDR[i] = PADDR；
  ADDR_REMAP_ENABLE=1: M_PADDR[i] = PADDR - BASE_ADDR[i]（仅被选中端口有效）
req_ref:
  - LRS.FUNC.APB_DEMUX.06.001
  - LRS.FUNC.APB_DEMUX.06.002
applicability:
  expr: "true"
END_LLD_DATAPATH_META -->

##### 需求描述

1. 静态 remap，不影响未选中端口。

---

## 3. 时序逻辑

### 3.1 Transaction Timeout 计数

#### LLD.FSM.APB_DEMUX.TIMEOUT Timeout 计数状态

<!-- LLD_FSM_META
id: LLD.FSM.APB_DEMUX.TIMEOUT
module_ref: LLD.MOD.APB_DEMUX.TOP
hld_ref:
  - HLD.MOD.L1.APB_DEMUX.ERR
states:
  - IDLE
  - WAIT_RESP
transitions:
  - from: IDLE
    to: WAIT_RESP
    condition: upstream_PSEL && upstream_PENABLE && ~decode_miss
  - from: WAIT_RESP
    to: IDLE
    condition: selected_PREADY || timeout_expired
reset_state: IDLE
encoding: binary
illegal_state_handling: 非法状态不可达（counter 受限）；复位返回 IDLE
description: |
  TIMEOUT_ENABLE=1 时，WAIT_RESP 中且 PREADY=0 时 counter 递增；
  达到 TIMEOUT_CYCLES 触发 timeout_expired。
req_ref:
  - LRS.FUNC.APB_DEMUX.07.001
  - LRS.FUNC.APB_DEMUX.07.002
applicability:
  expr: "TIMEOUT_ENABLE == 1"
END_LLD_FSM_META -->

##### 需求描述

1. Timeout counter 仅 ACCESS phase 且 `PREADY=0` 时计数；
2. 超时后返回 `PREADY=1, PSLVERR=1`。

---

### 3.2 Response Register

#### LLD.PIPELINE.APB_DEMUX.RESP_REG Response Register 流水级

<!-- LLD_PIPELINE_META
id: LLD.PIPELINE.APB_DEMUX.RESP_REG
module_ref: LLD.MOD.APB_DEMUX.TOP
stages: 1
description: |
  OUTPUT_REGISTER=1 时在响应路径插入 1 级寄存器；
  通过插入 wait-state（上游 PREADY 延迟一拍）保证协议合规。
req_ref:
  - LRS.FUNC.APB_DEMUX.08.002
applicability:
  expr: "OUTPUT_REGISTER == 1"
END_LLD_PIPELINE_META -->

##### 需求描述

1. 响应寄存器插入不违反 APB 协议。

---

## 4. 复位

#### LLD.RESET.APB_DEMUX.RST_N 复位行为

<!-- LLD_RESET_META
id: LLD.RESET.APB_DEMUX.RST_N
module_ref: LLD.MOD.APB_DEMUX.TOP
reset_domain: RST_APB_N
type: async_assert_sync_release
polarity: active_low
reset_value:
  M_PSEL: all 0
  timeout_counter: 0
  response_register: 0
description: |
  复位期间所有 M_PSEL[i]=0，无有效下游事务；
  timeout counter 与 response register 进入确定状态。
req_ref:
  - LRS.RESET.APB_DEMUX.02.001
  - LRS.RESET.APB_DEMUX.02.002
  - LRS.RESET.APB_DEMUX.02.003
applicability:
  expr: "true"
END_LLD_RESET_META -->

##### 需求描述

1. 复位期间所有 `M_PSEL[i]=0`；
2. 内部状态确定复位。

---

## 5. CDC/RDC

**NA - 单时钟域、单复位域，无 CDC/RDC 路径。**

## 6. 中断/异常

**NA - 本 IP 无中断输出。** 错误通过 `PSLVERR` 上报（协议级），无独立中断线。

#### LLD.ERROR.APB_DEMUX.DECODE_MISS Decode Miss 错误

<!-- LLD_ERROR_META
id: LLD.ERROR.APB_DEMUX.DECODE_MISS
detection: 组合检测 decode_miss = (PSEL==1) && (~|hit)
response: 返回 PREADY=1, PSLVERR=1, PRDATA=0，立即结束 transaction
req_ref:
  - LRS.FUNC.APB_DEMUX.05.002
  - LRS.FUNC.APB_DEMUX.05.003
applicability:
  expr: "true"
END_LLD_ERROR_META -->

##### 需求描述

1. Decode Miss 立即结束，禁止无限等待。

---

## 7. PPA 决策

#### LLD.PPA.APB_DEMUX.DECODER Decoder 面积优化

<!-- LLD_PPA_META
id: LLD.PPA.APB_DEMUX.DECODER
tradeoff: 地址译码面积 vs 组合延迟
decision: 有效位比较优化：ADDR_MASK 全 0 位不参与比较；power-of-two 窗口只需比较高位
cost: 面积小、延迟低；需配置校验保证对齐
req_ref:
  - LRS.PERF.APB_DEMUX.02.001
applicability:
  expr: "true"
END_LLD_PPA_META -->

##### 需求描述

1. decoder 采用 `PADDR[31:12]` 之类有效位比较（示例 BASE=0x4000_0000, SIZE=0x1000）。

---

#### LLD.PPA.APB_DEMUX.MUX Response Mux 平衡

<!-- LLD_PPA_META
id: LLD.PPA.APB_DEMUX.MUX
tradeoff: mux 树平衡 vs 逻辑深度
decision: one-hot mux 交给综合工具平衡；大 NUM_SLAVES 时可用 OUTPUT_REGISTER 切分时序
cost: 默认零延迟；大规模时插入寄存器优化 timing
req_ref:
  - LRS.PERF.APB_DEMUX.02.001
applicability:
  expr: "true"
END_LLD_PPA_META -->

##### 需求描述

1. 大 `NUM_SLAVES` 响应 mux timing 由 OUTPUT_REGISTER 缓解。

---

## 8. 架构决策

#### LLD.DECISION.APB_DEMUX.SINGLE_MODULE 单模块决策

<!-- LLD_DECISION_META
id: LLD.DECISION.APB_DEMUX.SINGLE_MODULE
decision: 保持单文件参数化 RTL，不拆分独立模块文件
options:
  - 单文件 apb_demux_top.sv
  - 多文件（decode/route/err 独立）
selected: 单文件
rationale: 逻辑简单、便于验证与参数化复用；LRS CONS 02.001 约束
hld_ref:
  - HLD.MOD.L1.APB_DEMUX.TOP
req_ref:
  - LRS.CONS.APB_DEMUX.02.001
applicability:
  expr: "true"
END_LLD_DECISION_META -->

##### 需求描述

1. 保持实现简单。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 05-lld-microdesign*
