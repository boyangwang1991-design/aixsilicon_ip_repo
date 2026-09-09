# APB Demux — HLD 时钟/复位/性能

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 时钟域

#### HLD.DOM.APB_DEMUX.CLK_APB APB 时钟域

<!-- HLD_DOMAIN_META
id: HLD.DOM.APB_DEMUX.CLK_APB
type: clk
name: CLK_APB
source: PCLK
modules:
  - HLD.MOD.L1.APB_DEMUX.TOP
req_ref:
  - LRS.INTF.APB_DEMUX.03.001
  - LRS.RESET.APB_DEMUX.01.001
applicability:
  expr: "true"
END_HLD_DOMAIN_META -->

##### 需求描述

1. 单一 `PCLK` 时钟域，所有逻辑（译码/路由/响应）同域。

---

## 2. 复位域

#### HLD.DOM.APB_DEMUX.RST_APB_N APB 复位域

<!-- HLD_DOMAIN_META
id: HLD.DOM.APB_DEMUX.RST_APB_N
type: rst
name: RST_APB_N
source: PRESETn
modules:
  - HLD.MOD.L1.APB_DEMUX.TOP
req_ref:
  - LRS.INTF.APB_DEMUX.03.002
  - LRS.RESET.APB_DEMUX.02.001
  - LRS.RESET.APB_DEMUX.02.002
  - LRS.RESET.APB_DEMUX.02.003
applicability:
  expr: "true"
END_HLD_DOMAIN_META -->

##### 需求描述

1. `PRESETn` 低有效复位；复位期间无有效下游事务。

---

## 3. CDC/RDC

**N/A - 本 IP 为单时钟域、单复位域设计，无 CDC/RDC 路径。**

APB Demux 所有逻辑共享 `PCLK` 与 `PRESETn`，不存在跨时钟/跨复位域路径。

---

## 4. 性能预算

#### HLD.PERF.APB_DEMUX.LATENCY 低延迟预算

<!-- HLD_PERF_META
id: HLD.PERF.APB_DEMUX.LATENCY
metric: transaction_latency
target: 0 额外周期（组合响应路径）
allocated_to: HLD.MOD.L1.APB_DEMUX.ROUTE
req_ref:
  - LRS.PERF.APB_DEMUX.01.001
applicability:
  expr: "OUTPUT_REGISTER == 0"
END_HLD_PERF_META -->

##### 需求描述

1. 默认配置下 IP 自身延迟为 0 个额外时钟周期。

---

#### HLD.PERF.APB_DEMUX.PPA PPA 预算

<!-- HLD_PERF_META
id: HLD.PERF.APB_DEMUX.PPA
metric: ppa
target: 轻量级互联（decoder 有效位比较、平衡 mux、fanout 可控）
allocated_to: HLD.MOD.L1.APB_DEMUX.DECODE
req_ref:
  - LRS.PERF.APB_DEMUX.02.001
  - LRS.PERF.APB_DEMUX.03.001
applicability:
  expr: "true"
END_HLD_PERF_META -->

##### 需求描述

1. decoder 尽量减少 comparator 位宽与逻辑深度；
2. 大 `NUM_SLAVES` 时避免不平衡 mux tree；
3. 请求信号 fanout 交由综合/实现工具优化。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
