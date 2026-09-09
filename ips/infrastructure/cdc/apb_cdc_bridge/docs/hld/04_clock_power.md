# APB CDC Bridge — HLD 时钟/复位/电源域与 CDC 路径

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 时钟域

### 1.1 源时钟域

#### HLD.DOM.APB_CDC_BRIDGE.SRC_CLK 源时钟域

<!-- HLD_CLK_META
id: HLD.DOM.APB_CDC_BRIDGE.SRC_CLK
name: SRC_CLK
type: clock
description: 上游 APB 时钟域（s_pclk）
frequency: "外部提供（无固定频率）"
source: external
affected_modules:
  - HLD.MOD.L1.APB_CDC_BRIDGE.SOURCE
req_ref:
  - LRS.INTF.APB_CDC_BRIDGE.03.001
END_HLD_CLK_META -->

##### 需求描述

1. `s_pclk` 驱动源域捕获逻辑，频率/相位对外部无假设。

---

### 1.2 目的时钟域

#### HLD.DOM.APB_CDC_BRIDGE.DST_CLK 目的时钟域

<!-- HLD_CLK_META
id: HLD.DOM.APB_CDC_BRIDGE.DST_CLK
name: DST_CLK
type: clock
description: 下游 APB 时钟域（m_pclk）
frequency: "外部提供（无固定频率）"
source: external
affected_modules:
  - HLD.MOD.L1.APB_CDC_BRIDGE.DEST
  - HLD.MOD.L1.APB_CDC_BRIDGE.SYNC
req_ref:
  - LRS.INTF.APB_CDC_BRIDGE.03.001
END_HLD_CLK_META -->

##### 需求描述

1. `m_pclk` 驱动目的域重新生成逻辑，可暂停/gating。

---

### 1.3 源复位域

#### HLD.DOM.APB_CDC_BRIDGE.SRC_RST 源复位域

<!-- HLD_CLK_META
id: HLD.DOM.APB_CDC_BRIDGE.SRC_RST
name: SRC_RST
type: reset
description: 上游异步复位（s_presetn，active low，async assert / sync deassert）
active_level: active_low
source: external
affected_modules:
  - HLD.MOD.L1.APB_CDC_BRIDGE.SOURCE
req_ref:
  - LRS.INTF.APB_CDC_BRIDGE.03.002
END_HLD_CLK_META -->

##### 需求描述

1. `s_presetn` 独立复位源域。

---

### 1.4 目的复位域

#### HLD.DOM.APB_CDC_BRIDGE.DST_RST 目的复位域

<!-- HLD_CLK_META
id: HLD.DOM.APB_CDC_BRIDGE.DST_RST
name: DST_RST
type: reset
description: 下游异步复位（m_presetn，active low，async assert / sync deassert）
active_level: active_low
source: external
affected_modules:
  - HLD.MOD.L1.APB_CDC_BRIDGE.DEST
  - HLD.MOD.L1.APB_CDC_BRIDGE.SYNC
req_ref:
  - LRS.INTF.APB_CDC_BRIDGE.03.002
END_HLD_CLK_META -->

##### 需求描述

1. `m_presetn` 独立复位目的域。

---

## 2. CDC 路径

### 2.1 Request 控制跨域

#### HLD.CDC.APB_CDC_BRIDGE.REQ_TOGGLE Request Toggle 跨域

<!-- HLD_CDC_META
id: HLD.CDC.APB_CDC_BRIDGE.REQ_TOGGLE
name: req_toggle_cdc
source_clock: SRC_CLK
target_clock: DST_CLK
signal_type: single-bit control
sync_method: toggle + 2FF synchronizer
req_ref:
  - LRS.FUNC.APB_CDC_BRIDGE.03.001
  - LRS.CONS.APB_CDC_BRIDGE.02.001
END_HLD_CDC_META -->

##### 需求描述

1. Req Toggle 单 bit 控制经 SYNC_STAGES 级 2FF 同步到目的域。
2. Request payload 由 bundled-data 保护，不得逐 bit 同步。

---

### 2.2 Response 控制跨域

#### HLD.CDC.APB_CDC_BRIDGE.RSP_TOGGLE Response Toggle 跨域

<!-- HLD_CDC_META
id: HLD.CDC.APB_CDC_BRIDGE.RSP_TOGGLE
name: rsp_toggle_cdc
source_clock: DST_CLK
target_clock: SRC_CLK
signal_type: single-bit control
sync_method: toggle + 2FF synchronizer
req_ref:
  - LRS.FUNC.APB_CDC_BRIDGE.03.001
  - LRS.CONS.APB_CDC_BRIDGE.02.001
END_HLD_CDC_META -->

##### 需求描述

1. Rsp Toggle 单 bit 控制经 SYNC_STAGES 级 2FF 同步回源域。
2. Response payload 由 bundled-data 保护。

---

## 3. 时钟关系矩阵

| 关系 | 支持 | 说明 |
|------|------|------|
| 完全异步 | ✔ | 无频率/相位假设 |
| 快→慢（8:1, 4:1, 2:1） | ✔ | 上游 wait-state |
| 慢→快（1:2, 1:4, 1:8） | ✔ | 低延迟完成 |
| 同频异相 | ✔ | 按异步安全处理 |
| 同源同步异频 | ✔（预留优化） | SYNC_RATIO 预留，默认 ASYNC_SAFE |

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 03-hld-architect*
