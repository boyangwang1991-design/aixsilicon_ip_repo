# 测试矩阵 - UART 验证方案

> 本文档是 [verification_plan.md](verification_plan.md) 第 11 章的详细展开（测试矩阵）。

## 测试策略摘要

- **测试组划分**：sanity（1）、basic（2）、scenario（1）、corner（2）、random（1），总计 7 个（简单 IP 上限 7）。
- **优先级**：smoke 1 个（tc_uart_smoke），regression 4 个，extended 2 个。
- **参数化合并**：收发/回环/噪声滤波合并、FIFO 水位、错误事件、寄存器访问按参数合并。

## 测试矩阵

| 测试ID | 功能 | 测试名称 | 类型 | 优先级 | tier | 描述 | 通过标准 |
|--------|------|----------|------|--------|------|------|----------|
| TC.INTF.UART.01.001.SMOKE | FL.INTF.UART.01 | tc_uart_smoke | directed | must | smoke | 复位 + 寄存器读写 + TX/RX 系统回环一字节 + 基本中断 | RM/CSR 比对通过 |
| TC.FUNC.UART.01.002.TXRX | FL.FUNC.UART.01 | tc_uart_tx_rx | directed | must | regression | 参数化：波特率集合 + 奇偶开关 + 帧格式（8 位 LSB）+ SLPBK/LLPBK/NF 回环模式，多字节收发 | RM 收发比对一致、回环/滤波正确 |
| TC.FUNC.UART.01.003.ERR | FL.FUNC.UART.01 | tc_uart_error | error_injection | must | regression | 参数化：frame/parity/break/overflow/timeout 错误注入与中断 | 各错误中断正确置位，数据丢弃 |
| TC.FUNC.UART.01.004.FIFO | FL.FUNC.UART.01 | tc_uart_fifo | boundary | must | regression | 参数化：RXILVL/TXILVL 各档水位、FIFO 满/空/复位、rx_watermark/tx_watermark | 水位中断与 FIFO_STATUS 一致 |
| TC.REG.UART.01.005.CSR | FL.REG.UART.01 | tc_uart_csr | register | must | regression | 参数化：各寄存器读写/W1C/复位值 + 非法地址错误响应 | CSR 检查 + RAL 比对通过 |
| TC.PERF.UART.01.006.PERF | FL.PERF.UART.01 | tc_uart_perf | performance | must | extended | 参数化：波特率误差 ±2.5% 容限、FIFO 深度、单字节延迟 | 容限内正确通信、延迟符合 |
| TC.SAFE.UART.01.007.ALERT | FL.SAFE.UART.01 | tc_uart_alert | directed | must | extended | ALERT_TEST 注入 + 总线完整性 fatal_fault alert | alert_tx_o 正确触发 |

<!-- TESTCASE_META
id: TC.INTF.UART.01.001.SMOKE
name: tc_uart_smoke
type: directed
coverage_type: functional
description: 复位后寄存器默认值、基本寄存器读写、TX/RX 系统回环一字节、基本中断
preconditions: 复位完成，CTRL 配置（NCO/TX/RX/SLPBK）
stimulus: 写 CTRL 使能，写 WDATA 一字节，等待 RX 收到，读 RDATA
expected_result: 读回 RDATA 与发送数据一致，相关中断/状态正确
priority: must
tier: smoke
feature_ref: FL.INTF.UART.01
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.UART.01.002.TXRX
name: tc_uart_tx_rx
type: directed
coverage_type: functional
description: 参数化波特率/奇偶/帧格式/回环模式的端到端收发
preconditions: 配置 NCO（多种波特率）、PARITY_EN/ODD、SLPBK/LLPBK/NF
stimulus: 生成多字节数据帧（含奇偶），经回环/线路回环/外部收发，注入单周期毛刺验证滤波
expected_result: RM 收发比对一致，帧格式（START+8 data+[parity]+STOP）正确，回环一致、NF 滤除毛刺
priority: must
tier: regression
feature_ref: FL.FUNC.UART.01
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.UART.01.003.ERR
name: tc_uart_error
type: error_injection
coverage_type: functional
description: 参数化错误注入：frame/parity/break/overflow/timeout 及其中断
preconditions: 使能对应错误检测与中断
stimulus: 注入错误帧/奇偶错/break/溢出/超时场景
expected_result: 各错误中断正确置位、数据按设计丢弃/标记
priority: must
tier: regression
feature_ref: FL.FUNC.UART.01
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.FUNC.UART.01.004.FIFO
name: tc_uart_fifo
type: boundary
coverage_type: functional
description: 参数化 FIFO 水位（RXILVL/TXILVL 各档）、满/空/软复位、watermark 中断
preconditions: 配置 FIFO_CTRL 水位与中断
stimulus: 填充/读取 FIFO 至各水位边界，触发软复位
expected_result: 水位中断与 FIFO_STATUS 一致，软复位清空 FIFO
priority: must
tier: regression
feature_ref: FL.FUNC.UART.01
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.REG.UART.01.005.CSR
name: tc_uart_csr
type: register
coverage_type: functional
description: 参数化寄存器读写、W1C、复位值、非法地址错误响应
preconditions: 复位
stimulus: RAL 遍历各寄存器读写，非法地址访问
expected_result: 读写一致、W1C 正确、复位值正确、非法地址返回错误
priority: must
tier: regression
feature_ref: FL.REG.UART.01
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.PERF.UART.01.006.PERF
name: tc_uart_perf
type: performance
coverage_type: functional
description: 参数化波特率误差容限、FIFO 深度、单字节延迟
preconditions: 配置不同 NCO/波特率
stimulus: 收发侧引入 ±2.5% 波特率偏差，测量 bit-time 与延迟
expected_result: 容限内正确通信、单字节 10/11 bit-time、FIFO 深度 32/64
priority: must
tier: extended
feature_ref: FL.PERF.UART.01
END_TESTCASE_META -->

<!-- TESTCASE_META
id: TC.SAFE.UART.01.007.ALERT
name: tc_uart_alert
type: directed
coverage_type: functional
description: ALERT_TEST 注入与总线完整性 fatal_fault alert
preconditions: 复位，连接 alert 接收
stimulus: 写 ALERT_TEST 触发 alert；注入总线完整性错误
expected_result: alert_tx_o 正确触发、复位后已知状态
priority: must
tier: extended
feature_ref: FL.SAFE.UART.01
END_TESTCASE_META -->

---

*文档版本: v1.0*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 06-verification-plan*
