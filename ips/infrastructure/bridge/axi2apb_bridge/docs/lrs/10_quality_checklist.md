# LRS 质量检查清单 - AXI-to-APB Bridge (X2P)

> 本文档是 LRS 文档检查清单，不含需求条目。

---

## 1. 需求完整性

| 检查项 | 状态 | 说明 |
|---|---|---|
| INTF 需求存在 | ✅ | 01_interface.md（6 条） |
| FUNC 需求存在 | ✅ | 02_functional.md（26 条） |
| REG 需求 | N/A | 纯桥无寄存器 |
| PERF 需求存在 | ✅ | 04_performance.md（4 条） |
| LP 需求 | N/A | 参数裁剪实现 |
| SAFE 需求 | N/A | 无功能安全需求 |
| SEC 需求 | N/A | 无安全资产 |
| CONS 需求存在 | ✅ | 08_constraint.md（3 条） |
| DFX 需求 | N/A | 无 DFT 需求 |

## 2. 可验证性检查

| 检查项 | 状态 |
|---|---|
| 每条 must 需求有 verify_method | ✅ |
| 需求可仿真/评审验证 | ✅ |
| 数值/范围明确 | ✅（宽度/depth/timeout 等均明确） |

## 3. 编号一致性

| 检查项 | 状态 |
|---|---|
| 需求 ID 唯一 | ✅ |
| IP 段 = X2P | ✅（LRS.INTF.X2P.* / LRS.FUNC.X2P.* / LRS.PERF.X2P.* / LRS.CONS.X2P.*） |
| 编号格式 LRS.<CAT>.<IP>.<GROUP>.<INDEX> | ✅ |

## 4. 需求统计核对

实际统计见 index.md 第 3 节（抽取后由脚本填充 TBD 为实际值）。

## 5. 发现项

- 无阻塞性发现项。
- VC Formal 缺失，formal 验证标记为探索性。