# HLD 质量检查报告 — apb_cdc_bridge

> **IP**: `apb_cdc_bridge` | **日期**: 2026-09-07 | **Gate**: G1

## 1. 抽取结果

| 指标 | 值 |
|------|-----|
| L1 模块 | 4（TOP / SOURCE / DEST / SYNC） |
| 外部接口 | 2（s_apb / m_apb） |
| 内部接口 | 2（req_channel / rsp_channel） |
| 时钟/复位域 | 4（SRC_CLK / DST_CLK / SRC_RST / DST_RST） |
| CDC 路径 | 2（req_toggle / rsp_toggle） |

## 2. Extractor 校验

```text
✓ No duplicate module IDs
✓ Module hierarchy integrity OK
✓ All modules have req_ref
✓ All modules have clock/reset/power domains
✓ All 29 LRS requirements are covered by modules
✓ Validation PASSED
```

## 3. 需求覆盖

- 29 条 LRS 需求全部被至少一个 HLD 模块引用。
- 模块 TOP 覆盖配置校验/集成约束/CDC_MODE 策略；SOURCE 覆盖捕获/返回；DEST 覆盖
  重新生成/响应；SYNC 覆盖同步器链。

## 4. 设计决策记录

| 决策 | 选择 |
|------|------|
| CDC 架构 | HANDSHAKE 默认 / ASYNC_FIFO 可选 |
| CDC_MODE | ASYNC_SAFE 默认；SYNC_RATIO 预留（V1.0 不实现） |
| 数据同步 | Bundled-data + 单 toggle 握手 |
| 复位 | reset-abort，独立复位，无顺序依赖 |
| 单事务 | 任一时刻一个跨桥事务 |

## 5. 结论

**G1: PASS** — HLD 架构文档齐全，canonical 架构/接口/时钟域/CDC 模型生成且校验通过。
