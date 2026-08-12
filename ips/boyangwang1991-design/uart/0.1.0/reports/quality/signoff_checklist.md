# UART Signoff Checklist

> 验证收敛 signoff 清单。全部通过后完成验证 signoff。

## 架构检查

- [x] 目录结构符合 verification_template（env/tc/th/sim/tests）
- [x] driver 继承 uvm_driver、monitor 继承 uvm_monitor
- [x] agent/env/test 分层清晰
- [x] filelist 完整（check_uvm.f 覆盖全部源文件）
- [x] package 编译顺序正确（agent → env → tc）
- [x] sim/Makefile 支持 compile/run/regress

## Agent 检查

- [x] driver 只负责信号驱动（TL-UL/APB/UART）
- [x] monitor 被动采样并广播 analysis port
- [x] driver/sequencer connect_phase 连接
- [x] passive 模式不创建 driver/sequencer

## Env 检查

- [x] RM/checker/coverage 按 cfg 使能位创建
- [x] 所有 monitor ap 连接到 RM/checker/coverage
- [x] virtual sequencer 持有 3 个 agent sequencer 句柄
- [x] config_db 传递路径正确

## Test 检查

- [x] 7 个 testcase 继承 tc_base
- [x] raise/drop objection 正确配对
- [x] sequence 在正确 sequencer 上运行
- [x] 设置了合理超时（uvm_root）
- [x] 全部 testcase 加入 regression_list.yaml

## Checker 检查

- [x] expected（RM）和 actual（monitor）分离清晰
- [x] mismatch 日志包含事务详情
- [x] report/check phase 打印统计

## Coverage 检查

- [x] 6 个 covergroup 按 coverage_plan 实现（baud/frame/fifo/error/mode/reg_access）
- [x] 含 cross coverage 与边界 bin

## 门禁

- [x] G0-G5 全部 pass（见 gate_report.md）

## 结论

UART IP 验证环境已完成 smoke + 全量回归（7/7 testcase PASS），
G0-G5 质量门禁全部通过，满足 signoff 条件。
