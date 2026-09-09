# LRS 质量检查报告 — apb_cdc_bridge

> **IP**: `apb_cdc_bridge` | **日期**: 2026-09-07 | **Gate**: G0

## 1. 抽取结果

| 指标 | 值 |
|------|-----|
| LRS 需求总数 | 29 |
| INTF | 6 |
| FUNC | 14 |
| PERF | 3 |
| LP | 2 |
| CONS | 3 |
| DFX | 1 |
| REG/SAFE/SEC | 0（N/A 声明，见 index.md） |
| must（P0） | 20 |
| should（P1） | 9 |

## 2. Extractor 校验

```text
✓ Requirement count matches between LRS and YAML (29 = 29)
✓ No duplicate requirement IDs
✓ All must requirements have verify_method
✓ Validation PASSED
```

## 3. 需求可验证性

- 每条需求均有唯一 ID、title、category、feature、priority、description、verify_method、status。
- 需求追踪链 `TC → FL → LRS` 将在 06/16 阶段闭环。

## 4. 发现项

| ID | 严重度 | 描述 | 状态 |
|----|--------|------|------|
| LRS-F1 | Info | `vc_formal` 缺失，formal 验证方法需在可用工具环境补充 | 记录 |
| LRS-F2 | Info | SYNC_BRIDGE 为 V1.0 预留，不在验收范围 | 记录 |

## 5. 结论

**G0: PASS** — LRS 文档齐全，canonical 需求模型生成且校验通过。
