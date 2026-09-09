# APB CDC Bridge — HLD 外部接口

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 外部接口

### 1.1 上游 APB Slave 接口

#### HLD.IF.EXT.APB_CDC_BRIDGE.S_APB 上游 APB 从接口

<!-- HLD_IF_META
id: HLD.IF.EXT.APB_CDC_BRIDGE.S_APB
name: s_apb
type: APB
direction: slave
description: 上游 APB3/APB4 Slave 接口（源时钟域）
ports:
  - name: s_pclk
    direction: input
    width: 1
    clock_domain: SRC_CLK
  - name: s_presetn
    direction: input
    width: 1
    clock_domain: SRC_RST
  - name: s_psel
    direction: input
    width: 1
    clock_domain: SRC_CLK
  - name: s_penable
    direction: input
    width: 1
    clock_domain: SRC_CLK
  - name: s_paddr
    direction: input
    width: "ADDR_WIDTH"
    clock_domain: SRC_CLK
  - name: s_pwrite
    direction: input
    width: 1
    clock_domain: SRC_CLK
  - name: s_pwdata
    direction: input
    width: "DATA_WIDTH"
    clock_domain: SRC_CLK
  - name: s_pstrb
    direction: input
    width: "DATA_WIDTH/8"
    clock_domain: SRC_CLK
  - name: s_pprot
    direction: input
    width: 3
    clock_domain: SRC_CLK
  - name: s_prdata
    direction: output
    width: "DATA_WIDTH"
    clock_domain: SRC_CLK
  - name: s_pready
    direction: output
    width: 1
    clock_domain: SRC_CLK
  - name: s_pslverr
    direction: output
    width: 1
    clock_domain: SRC_CLK
timing:
  protocol: APB3/APB4
  transfer: single
req_ref:
  - LRS.INTF.APB_CDC_BRIDGE.01.001
  - LRS.INTF.APB_CDC_BRIDGE.01.002
END_HLD_IF_META -->

##### 需求描述

1. 上游 APB Slave 接口，支持 APB3/APB4（PSTRB/PPROT 可选）。
2. 单 PSEL，位宽由参数决定。

---

### 1.2 下游 APB Master 接口

#### HLD.IF.EXT.APB_CDC_BRIDGE.M_APB 下游 APB 主接口

<!-- HLD_IF_META
id: HLD.IF.EXT.APB_CDC_BRIDGE.M_APB
name: m_apb
type: APB
direction: master
description: 下游 APB3/APB4 Master 接口（目的时钟域）
ports:
  - name: m_pclk
    direction: input
    width: 1
    clock_domain: DST_CLK
  - name: m_presetn
    direction: input
    width: 1
    clock_domain: DST_RST
  - name: m_psel
    direction: output
    width: 1
    clock_domain: DST_CLK
  - name: m_penable
    direction: output
    width: 1
    clock_domain: DST_CLK
  - name: m_paddr
    direction: output
    width: "ADDR_WIDTH"
    clock_domain: DST_CLK
  - name: m_pwrite
    direction: output
    width: 1
    clock_domain: DST_CLK
  - name: m_pwdata
    direction: output
    width: "DATA_WIDTH"
    clock_domain: DST_CLK
  - name: m_pstrb
    direction: output
    width: "DATA_WIDTH/8"
    clock_domain: DST_CLK
  - name: m_pprot
    direction: output
    width: 3
    clock_domain: DST_CLK
  - name: m_prdata
    direction: input
    width: "DATA_WIDTH"
    clock_domain: DST_CLK
  - name: m_pready
    direction: input
    width: 1
    clock_domain: DST_CLK
  - name: m_pslverr
    direction: input
    width: 1
    clock_domain: DST_CLK
timing:
  protocol: APB3/APB4
  transfer: single
req_ref:
  - LRS.INTF.APB_CDC_BRIDGE.02.001
  - LRS.INTF.APB_CDC_BRIDGE.02.002
END_HLD_IF_META -->

##### 需求描述

1. 下游 APB Master 接口，重新生成合法 APB 事务。
2. IDLE 时输出稳定。

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 03-hld-architect*
