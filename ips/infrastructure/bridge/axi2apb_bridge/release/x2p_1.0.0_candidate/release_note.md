# X2P Release Note (Candidate)

> 版本: 1.0.0-candidate · 日期: 2026-09-03
> **状态: CANDIDATE（非正式发布）** — G4 未通过（BUG-001 open）

## 内容

- AXI4/AXI4-Lite → APB3/APB4 桥 RTL（9 文件）+ FuseSoC core。
- 需求/架构/微架构/验证方案/追踪矩阵全套文档。
- UVM 验证环境（可编译，smoke 写路径通过）。

## 门禁状态

| Gate | 状态 |
|---|---|
| G0-G3 | PASS |
| G4 | FAIL（读路径 BUG-001） |
| G5 | NOT PASS |

## 已知问题

- **BUG-001**：AXI 读请求 RVALID 永不建立（R 超时）。写路径已验证通过。
  修复前不得用于正式集成。

## 使用

```bash
fusesoc library add x2p_local <path>
fusesoc run --target=lint aixsilicon:ip:x2p:1.0.0