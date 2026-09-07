# 验证方案质量检查报告 - X2P

## 基本信息
- IP: x2p
- 校验日期: 2026-09-03
- 方法学: UVM 1.2

## 抽取结果

| 项 | 数量 |
|---|---|
| Feature | 15 |
| Testcase（去重） | 16 |
| Assertion | 13 |
| Coverage | 9 |

## 每个 feature 验证对象分布（全部 ≥1）

| Feature | tc | as | cov |
|---|---|---|---|
| FL.INTF.X2P.01 | 1 | 1 | 0 |
| FL.INTF.X2P.02 | 1 | 1 | 1 |
| FL.INTF.X2P.03 | 1 | 1 | 0 |
| FL.FUNC.X2P.01 | 1 | 1 | 0 |
| FL.FUNC.X2P.02 | 3 | 1 | 1 |
| FL.FUNC.X2P.03 | 2 | 1 | 1 |
| FL.FUNC.X2P.04 | 1 | 1 | 1 |
| FL.FUNC.X2P.05 | 1 | 1 | 1 |
| FL.FUNC.X2P.06 | 1 | 1 | 1 |
| FL.FUNC.X2P.07 | 1 | 1 | 1 |
| FL.FUNC.X2P.08 | 1 | 1 | 1 |
| FL.FUNC.X2P.09 | 1 | 1 | 0 |
| FL.FUNC.X2P.10 | 1 | 1 | 1 |
| FL.PERF.X2P.01 | 1 | 0 | 0 |
| FL.CONS.X2P.01 | 1 | 0 | 0 |

## 校验结果

| 检查项 | 结果 |
|---|---|
| VPLAN 唯一 | ✅ |
| must 需求都有 feature | ✅（42 全映射） |
| must 需求所在 feature 都有 tc/as | ✅ |
| Testcase ID 全局唯一 | ✅ |
| Assertion 全局唯一 | ✅ |
| Coverage 全局唯一 | ✅ |
| 每条 must 需求有 testcase 或 assertion | ✅ |

## 结论

**验证方案通过**：15 features / 16 tc / 13 as / 9 cov，全部 must 需求可验证。
进入 RTL 与 UVM 实现阶段。