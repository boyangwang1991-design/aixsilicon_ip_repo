# UART 质量 Dashboard

## Gate 状态

| Gate | 状态 |
|------|------|
| G0 (LRS Ready) | ✅ pass |
| G1 (HLD Ready) | ✅ pass |
| G2 (LLD Ready) | ✅ pass |
| G3 (RTL Ready) | ✅ pass |
| G4 (Verification Ready) | ✅ pass |
| G5 (Release Ready) | ✅ pass |

## 验证概况

| 项目 | 数值 |
|------|------|
| 需求 | 42（must 全覆盖） |
| 模块 | 6 L1 |
| 寄存器 | 14 |
| 功能点 | 6 |
| Testcase | 7（全部 PASS） |
| Coverage covergroup | 6 |
| 追踪矩阵 | 4 trace，0 gap |
| Finding | 3（1 resolved + 2 Note） |

## 质量信号

- **回归**：7/7 testcase 通过（0 ERROR / 0 FATAL）
- **RTL 检查**：SpyGlass lint 0 fatal/0 error；VCS elab PASS；DC synth 0 error
- **CSR**：SystemRDL → PeakRDL 一致（manifest 校验通过）
- **追踪**：req_to_hld=45, hld_to_lld=6, lld_to_rtl=7, req_to_test=120

详见 `gate_report.md`、`smoke_summary.md`、`trace_matrix.md`。
