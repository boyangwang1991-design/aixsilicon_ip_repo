# APB CDC Bridge — LLD SYNC 模块微设计

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 模块定义

### 1.1 CDC 同步器链模块

#### LLD.MOD.APB_CDC_BRIDGE.SYNC CDC 同步器链模块

<!-- LLD_META
module_id: LLD.MOD.APB_CDC_BRIDGE.SYNC
hld_ref: HLD.MOD.L1.APB_CDC_BRIDGE.SYNC
cdc:
  - signal: req_toggle
    source_domain: SRC_CLK
    target_domain: DST_CLK
    strategy: two_flop
  - signal: rsp_toggle
    source_domain: DST_CLK
    target_domain: SRC_CLK
    strategy: two_flop
reset:
  - signal: m_presetn
    polarity: active_low
    reset_value: "0"
    reset_type: async
  - signal: s_presetn
    polarity: active_low
    reset_value: "0"
    reset_type: async
datapath:
  pipeline_stages:
    - stage: "1"
      name: sync
      operation: "SYNC_STAGES 级 2FF 同步 toggle"
  backpressure:
    type: none
    mechanism: ""
ppa:
  performance:
    target_frequency: ">=800MHz"
    throughput: "n/a"
    max_latency: "SYNC_STAGES 周期"
    critical_path: "toggle → 2FF chain"
  area:
    budget: "SYNC_STAGES 个 FF/链"
    optimization: "仅同步 control，不逐 bit 同步 payload"
  power:
    budget: "idle 无翻转"
    techniques: "toggle 不变化时 FF 无翻转"
  tradeoffs:
    - option: "SYNC_STAGES=2 vs 3"
      choice: "默认 2；高可靠 3"
      rationale: "满足 LRS.FUNC.03.002 MTBF/面积/延迟权衡"
END_LLD_META -->

##### 需求描述

1. 提供 `SYNC_STAGES >= 2` 级 2FF 同步器链，同步 req/rsp toggle 控制信号。
2. 仅同步 control；payload 通过 bundled-data 保护，不逐 bit 同步。

---

## 2. 同步器链结构

```text
din ──> FF1 ──> FF2 ──> ... ──> FF[N] ──> dout
         (SYNC_STAGES 级)
```

## 3. 信号定义

| 信号 | 方向 | 位宽 | 说明 |
|------|------|------|------|
| `din` | in | 1 | 异步 toggle 输入 |
| `clk` | in | 1 | 目标域时钟 |
| `rst_n` | in | 1 | 目标域复位 |
| `dout` | out | 1 | 同步后 toggle |

## 4. 关键行为

- 同步器 FF 在目标域复位下复位（reset crossing 安全）。
- 不引入 combinational 跨域路径。

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 05-lld-microdesign*
