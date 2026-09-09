# APB CDC Bridge — HLD 内部接口分解

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 内部接口

### 1.1 Request 通道

#### HLD.IF.INT.APB_CDC_BRIDGE.REQ_CH Request 跨域通道

<!-- HLD_INT_IF_META
id: HLD.IF.INT.APB_CDC_BRIDGE.REQ_CH
name: req_channel
type: bundled-data handshake
source_module: HLD.MOD.L1.APB_CDC_BRIDGE.SOURCE
target_module: HLD.MOD.L1.APB_CDC_BRIDGE.DEST
description: 源域到目的域的 Request payload + toggle 握手通道
signals:
  - name: req_payload
    width: "PACKED_BUNDLE"
    direction: from_source
    clock_domain: SRC_CLK
  - name: req_toggle
    width: 1
    direction: from_source
    clock_domain: SRC_CLK
  - name: req_ack_toggle
    width: 1
    direction: to_source
    clock_domain: DST_CLK
timing:
  protocol: handshake
  ack: toggle-echo
req_ref:
  - LRS.FUNC.APB_CDC_BRIDGE.03.001
END_HLD_INT_IF_META -->

##### 需求描述

1. 源域发起 `req_toggle`，payload 保持稳定，等待目的域 `req_ack_toggle` 同步回源。

---

### 1.2 Response 通道

#### HLD.IF.INT.APB_CDC_BRIDGE.RSP_CH Response 跨域通道

<!-- HLD_INT_IF_META
id: HLD.IF.INT.APB_CDC_BRIDGE.RSP_CH
name: rsp_channel
type: bundled-data handshake
source_module: HLD.MOD.L1.APB_CDC_BRIDGE.DEST
target_module: HLD.MOD.L1.APB_CDC_BRIDGE.SOURCE
description: 目的域到源域的 Response payload + toggle 握手通道
signals:
  - name: rsp_payload
    width: "PACKED_BUNDLE"
    direction: from_source
    clock_domain: DST_CLK
  - name: rsp_toggle
    width: 1
    direction: from_source
    clock_domain: DST_CLK
  - name: rsp_ack_toggle
    width: 1
    direction: to_source
    clock_domain: SRC_CLK
timing:
  protocol: handshake
  ack: toggle-echo
req_ref:
  - LRS.FUNC.APB_CDC_BRIDGE.03.001
END_HLD_INT_IF_META -->

##### 需求描述

1. 目的域发起 `rsp_toggle`，payload 保持稳定，等待源域 `rsp_ack_toggle` 同步回目的。

---

## 2. 内部接口信号汇总

| 信号 | 位宽 | 方向 | 域 |
|------|------|------|-----|
| req_payload | `{PADDR,PWRITE,PWDATA,PSTRB,PPROT}` | SOURCE→DEST | 源域锁存/目的域读 |
| req_toggle | 1 | SOURCE→DEST | 源域驱动 |
| req_ack_toggle | 1 | DEST→SOURCE | 目的域驱动 |
| rsp_payload | `{PRDATA,PSLVERR}` | DEST→SOURCE | 目的域锁存/源域读 |
| rsp_toggle | 1 | DEST→SOURCE | 目的域驱动 |
| rsp_ack_toggle | 1 | SOURCE→DEST | 源域驱动 |

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 03-hld-architect*
