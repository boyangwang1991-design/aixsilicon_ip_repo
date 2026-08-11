# 覆盖率评审报告 - UART

<!-- REPORT_META
schema_version: "1.0"
ip_name: uart
report_type: coverage_review
status: pass
eda_profile: commercial-systemverilog
END_REPORT_META -->

## 覆盖率实现

`verification/env/uart_fcov.sv` 实现 coverage_plan.md 定义的 6 个 covergroup：

| 覆盖点 | Covergroup | 描述 | 状态 |
|--------|-----------|------|------|
| COV.FUNC.UART.01.BAUD | baud_rate_cg | NCO 分频/常用波特率 | ✅ |
| COV.FUNC.UART.02.FRAME | frame_cg | 帧格式（奇偶/数据位）+ cross | ✅ |
| COV.FUNC.UART.03.FIFO | fifo_cg | FIFO 寄存器/操作 cross | ✅ |
| COV.FUNC.UART.04.ERR | error_cg | 错误事件 | ✅ |
| COV.INTF.UART.01.MODE | mode_cg | 回环模式 | ✅ |
| COV.REG.UART.01.ACC | reg_access_cg | 寄存器访问类型 | ✅ |

## 评审结论

- ✅ 覆盖 coverage_plan 全部 6 个覆盖点
- ✅ 含 cross coverage（frame、fifo、reg_access）
- ✅ bin 覆盖边界值（0/max/常用波特率）
- ✅ covergroup 在 transaction 中按 feature_list 功能点设计

## 说明

当前环境以寄存器/TL-UL 访问路径验证为主；UART 串行回环数据检测在无外部
UART 驱动时不完全闭合（见 review_findings.yaml FINDING-002，Note 级）。
覆盖率数据可通过 `make run COV=1` 收集后由 `make coverage` 生成报告。
