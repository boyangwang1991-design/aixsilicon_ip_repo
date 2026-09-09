# APB Demux — HLD 功能设计

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 数据流

### 1.1 请求数据流

#### HLD.FLOW.APB_DEMUX.REQ 请求路由数据流

<!-- HLD_FLOW_META
id: HLD.FLOW.APB_DEMUX.REQ
name: request_routing_flow
description: 上游 APB 请求 → 地址译码 → PSEL one-hot → 请求 fanout → 下游 APB
participants:
  - HLD.MOD.L1.APB_DEMUX.TOP
  - HLD.MOD.L1.APB_DEMUX.DECODE
  - HLD.MOD.L1.APB_DEMUX.ROUTE
req_ref:
  - LRS.FUNC.APB_DEMUX.01.002
  - LRS.FUNC.APB_DEMUX.02.001
  - LRS.FUNC.APB_DEMUX.02.002
applicability:
  expr: "true"
END_HLD_FLOW_META -->

##### 需求描述

1. 上游发起 APB transaction（SETUP → ACCESS）。
2. Decoder 根据 `PADDR` 计算 `hit[N]`。
3. PSEL 生成器产生 `M_PSEL[i] = upstream_PSEL & hit[i]`。
4. `PADDR`/`PENABLE`/`PWRITE`/`PWDATA`/`PSTRB`/`PPROT` 广播至所有下游。

---

### 1.2 响应数据流

#### HLD.FLOW.APB_DEMUX.RESP 响应返回数据流

<!-- HLD_FLOW_META
id: HLD.FLOW.APB_DEMUX.RESP
name: response_return_flow
description: 下游响应（PRDATA/PREADY/PSLVERR）→ one-hot mux → 上游响应；Decode Miss / Timeout 走错误路径
participants:
  - HLD.MOD.L1.APB_DEMUX.ROUTE
  - HLD.MOD.L1.APB_DEMUX.ERR
req_ref:
  - LRS.FUNC.APB_DEMUX.04.001
  - LRS.FUNC.APB_DEMUX.04.002
  - LRS.FUNC.APB_DEMUX.05.002
  - LRS.FUNC.APB_DEMUX.07.001
applicability:
  expr: "true"
END_HLD_FLOW_META -->

##### 需求描述

1. 选中端口 `PRDATA`/`PREADY`/`PSLVERR` 经 one-hot mux 返回上游。
2. Decode Miss 时返回 `PREADY=1, PSLVERR=1, PRDATA=0`。
3. Timeout 时返回 `PREADY=1, PSLVERR=1`。

---

## 2. 控制策略

### 2.1 Wait-state 保持策略

#### HLD.POL.APB_DEMUX.WAIT Wait-state 保持策略

<!-- HLD_POLICY_META
id: HLD.POL.APB_DEMUX.WAIT
type: wait_state_policy
policy: 下游 PREADY=0 时保持 ACCESS phase；selection 与 response source 不改变
req_ref:
  - LRS.FUNC.APB_DEMUX.03.002
applicability:
  expr: "true"
END_HLD_POLICY_META -->

##### 需求描述

1. 组合译码保证 wait-state 期间 selection 稳定；
2. 响应 mux 源不变。

---

### 2.2 Decode Miss 策略

#### HLD.POL.APB_DEMUX.DECODE_MISS Decode Miss 错误策略

<!-- HLD_POLICY_META
id: HLD.POL.APB_DEMUX.DECODE_MISS
type: decode_error_policy
policy: PSEL=1 且无命中端口时立即返回 PREADY=1, PSLVERR=1, PRDATA=0，禁止无限等待
req_ref:
  - LRS.FUNC.APB_DEMUX.05.001
  - LRS.FUNC.APB_DEMUX.05.002
  - LRS.FUNC.APB_DEMUX.05.003
applicability:
  expr: "true"
END_HLD_POLICY_META -->

##### 需求描述

1. Decode Miss 立即结束，避免 APB fabric hang。

---

### 2.3 Remap 策略

#### HLD.POL.APB_DEMUX.REMAP 地址重映射策略

<!-- HLD_POLICY_META
id: HLD.POL.APB_DEMUX.REMAP
type: remap_policy
policy: ADDR_REMAP_ENABLE=0 时 M_PADDR[i]=PADDR；=1 时 M_PADDR[i]=PADDR-BASE_ADDR[i]（静态）
req_ref:
  - LRS.FUNC.APB_DEMUX.06.001
  - LRS.FUNC.APB_DEMUX.06.002
applicability:
  expr: "true"
END_HLD_POLICY_META -->

##### 需求描述

1. Remap 为静态配置，仅影响被选中端口的下游地址。

---

### 2.4 Timeout 策略

#### HLD.POL.APB_DEMUX.TIMEOUT Transaction Timeout 策略

<!-- HLD_POLICY_META
id: HLD.POL.APB_DEMUX.TIMEOUT
type: timeout_policy
policy: TIMEOUT_ENABLE=1 时 ACCESS phase 且 PREADY=0 达 TIMEOUT_CYCLES 后终止并返回 error
req_ref:
  - LRS.FUNC.APB_DEMUX.07.001
  - LRS.FUNC.APB_DEMUX.07.002
applicability:
  expr: "TIMEOUT_ENABLE == 1"
END_HLD_POLICY_META -->

##### 需求描述

1. Timeout counter 仅 ACCESS phase 且 `PREADY=0` 时计数。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
