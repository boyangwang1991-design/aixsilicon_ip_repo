# LLD 质量检查报告 — apb_cdc_bridge

> **IP**: `apb_cdc_bridge` | **日期**: 2026-09-07 | **Gate**: G2

## 1. 抽取结果

| 指标 | 值 |
|------|-----|
| LLD 模块 | 6（TOP/SOURCE/DEST/SYNC/HS_CDC/FIFO_CDC） |
| FSM | 4（source_capture / dest_generate / hs_req / fifo_push） |
| CDC 路径 | 18 |
| Reset 信号 | 10 |
| 中断 | 0（N/A） |

## 2. Extractor 校验

```text
✓ No duplicate module IDs
✓ All modules have hld_ref
✓ All FSMs have complete definition
INFO: TOP 无 CDC 定义（TOP 无跨域信号，可接受）
✓ All modules have reset definition
✓ Validation PASSED
```

## 3. CDC 实现隔离

- `CDC_IMPL=HANDSHAKE` → 仅例化 `handshake_cdc`；`CDC_IMPL=ASYNC_FIFO` → 仅例化 `fifo_cdc`。
- 两种实现对外暴露一致 `req_channel`/`rsp_channel` 契约，源/目的 FSM 不感知实现。
- 两种实现均保持单事务、bundled-data、SYNC_STAGES 语义。
- 对应 LRS 需求 `LRS.FUNC.APB_CDC_BRIDGE.04.002`（二选一隔离）。

## 4. PPA 微架构预算

| 指标 | HANDSHAKE | ASYNC_FIFO |
|------|-----------|------------|
| 同步器数 | 2（req/rsp toggle） | 4（灰度指针） |
| 存储 | 1 req + 1 rsp reg | FIFO 存储（depth*width） |
| 动态功耗 | 最低 | 略高 |
| 延迟 | ~2*SYNC_STAGES+2 | 相近 |

## 5. 结论

**G2: PASS** — LLD 微架构文档齐全，canonical micro_design 模型生成且校验通过，双实现隔离明确。
