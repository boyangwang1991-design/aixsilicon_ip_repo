# UART Smoke Summary

> 快速冒烟测试结果：验证环境可编译、elaborate 并运行全部 testcase。

<!-- REPORT_META
schema_version: "1.0"
ip_name: uart
report_type: smoke
status: pass
eda_profile: commercial-systemverilog
END_REPORT_META -->

## 结果

| 测试 | 结果 | 说明 |
|------|------|------|
| tc_uart_smoke | PASS | 复位 + 寄存器访问 + TX/RX 系统回环 |
| tc_uart_tx_rx | PASS | 多字节收发（SLPBK 回环） |
| tc_uart_error | PASS | 错误中断注入/清除 |
| tc_uart_fifo | PASS | FIFO 状态/软复位 |
| tc_uart_csr | PASS | 寄存器读写/W1C |
| tc_uart_perf | PASS | NCO/波特率配置 |
| tc_uart_alert | PASS | ALERT_TEST 注入 |

全部 testcase：`UVM_ERROR : 0`，`UVM_FATAL : 0`。

## 环境

- 仿真器：VCS（`-ntb_opts uvm-1.2`）
- RTL：OpenTitan UART 原版 + apb2tlul + uart_apb_top
- 完整回归日志：`reports/quality/run_*.log`
