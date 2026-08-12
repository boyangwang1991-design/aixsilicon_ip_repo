# LLD 验证与交付 - UART

## 6. 验证要点

| 模块 | 验证要点 |
|---|---|
| uart_top | 复位、中断/alert 输出已知、cio_tx_en 恒 1、总线完整性 alert |
| uart_reg_top | 寄存器读写、W1C、非法地址错误响应、INTR_STATUS=state&enable |
| uart_core | FIFO 水位/满/空/溢出、波特率、事件产生、break/超时/噪声滤波/回环 |
| uart_tx | 帧格式、奇偶、tx_done |
| uart_rx | 16x 采样、中点采样、帧/奇偶错误、毛刺忽略 |
| apb2tlul | APB 两相握手、地址映射、pslverr、与 TL-UL 功能等价 |

## 7. RTL TODO 列表

| 优先级 | RTL 文件 | 模块/实例 | 设计点 | 内容 | 关联需求/HLD ID |
|---|---|---|---|---|---|
| P0 | rtl/apb2tlul.sv | apb2tlul | APB→TL-UL 转换 FSM | 实现 IDLE/SETUP/ACCESS/WAIT_TL/RESP 状态机，APB 事务转 TL-UL Get/PutFullData | LRS.INTF.UART.01.003 / HLD.MOD.L1.UART.APB2TLUL |
| P0 | rtl/apb2tlul.sv | apb2tlul | pslverr 生成 | 非法地址（>0x34 或 4 字节对齐外）返回 pslverr=1 | LRS.REG.UART.01.001 |
| P1 | rtl/uart_apb_top.sv | uart_apb_top | APB 顶层封装 | 实例化 apb2tlul + uart，暴露 APB 接口与串行/中断/alert | LRS.CONS.UART.01.002 |
| P1 | rtl/include/uart_apb_defs.svh | - | 地址宏 | 定义 APB 地址映射宏（可选） | LRS.REG.UART.01.001 |

> 核心模块（uart/uart_core/uart_rx/uart_tx/uart_reg_top/uart_reg_pkg）为 OpenTitan 原版，**不做 RTL 改动**，无 TODO。

## 8. 交付映射

| HLD 模块 | LLD 模块 | RTL 文件 | 状态 |
|---|---|---|---|
| HLD.MOD.L1.UART.TOP | LLD.MOD.UART.TOP | rtl/uart.sv（原版） | 保留 |
| HLD.MOD.L1.UART.REG_TOP | LLD.MOD.UART.REG_TOP | rtl/uart_reg_top.sv + uart_reg_pkg.sv（原版） | 保留 |
| HLD.MOD.L1.UART.CORE | LLD.MOD.UART.CORE | rtl/uart_core.sv（原版） | 保留 |
| HLD.MOD.L1.UART.TX | LLD.MOD.UART.TX | rtl/uart_tx.sv（原版） | 保留 |
| HLD.MOD.L1.UART.RX | LLD.MOD.UART.RX | rtl/uart_rx.sv（原版） | 保留 |
| HLD.MOD.L1.UART.APB2TLUL | LLD.MOD.UART.APB2TLUL | rtl/apb2tlul.sv（新增） | 实现 |

## 附录

- WaveDrom 时序图：APB 两相握手、UART 帧时序（参考 OpenTitan theory_of_operation），如需可后续补充。
- NA：本设计无跨时钟域路径（单时钟域），无 CDC 详细设计。

---

*文档版本: v0.1*
*创建日期: 2026-08-11*
*创建者: IP Development Suite - 05-lld-microdesign*
