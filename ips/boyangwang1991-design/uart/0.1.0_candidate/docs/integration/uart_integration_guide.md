# UART 集成指南

> 面向 SoC 硬件集成工程师。本文档基于 HLD/LLD 与接口模型，描述 UART IP
> （OpenTitan 内核 + APB 接入）在 SoC 中的集成方法与连接规则。

<!-- REPORT_META
schema_version: "1.0"
ip_name: uart
report_type: integration_guide
status: pass
eda_profile: commercial-systemverilog
END_REPORT_META -->

## 1. 模块功能概述

UART IP 提供通用异步收发器功能，核心逻辑来自 OpenTitan（未修改），
并新增 `apb2tlul` 桥提供 APB 接入能力。支持：

- 8 位数据帧 + 可选奇偶校验 + 停止位
- 可配置波特率（NCO 分频）
- TX/RX FIFO（32 深度）
- 系统回环（SLPBK）、线路回环（LLPBK）、噪声滤波（NF）
- 9 类中断 + fatal_fault alert

## 2. 顶层与实例化

| 顶层 | 接入方式 | 说明 |
|------|----------|------|
| `uart` | TL-UL | OpenTitan 原版，寄存器经 TL-UL 访问 |
| `uart_apb_top` | APB4 | `apb2tlul` 桥 + `uart` 封装 |

### 2.1 TL-UL 实例化

```systemverilog
uart u_uart (
  .clk_i          (clk),
  .rst_ni         (rst_n),
  .tl_i           (tl_h2d),   // tlul_pkg::tl_h2d_t
  .tl_o           (tl_d2h),   // tlul_pkg::tl_d2h_t
  .alert_rx_i     (alert_rx), // prim_alert_pkg::alert_rx_t [NumAlerts-1:0]
  .alert_tx_o     (alert_tx), // prim_alert_pkg::alert_tx_t [NumAlerts-1:0]
  .racl_policies_i('0),
  .racl_error_o   (),
  .lsio_trigger_o (),
  .cio_rx_i       (uart_rx),
  .cio_tx_o       (uart_tx),
  .cio_tx_en_o    (uart_tx_en),
  .intr_*_o       (intr_*)
);
```

### 2.2 APB 实例化

```systemverilog
uart_apb_top u_uart_apb (
  .clk_i     (clk),
  .rst_ni    (rst_n),
  .psel_i    (psel),
  .penable_i (penable),
  .pwrite_i  (pwrite),
  .paddr_i   (paddr),      // 8-bit
  .pwdata_i  (pwdata),     // 32-bit
  .pstrb_i   (pstrb),      // 4-bit
  .prdata_o  (prdata),
  .pready_o  (pready),
  .pslverr_o (pslverr),
  .alert_rx_i(alert_rx[0:0]),
  .alert_tx_o(),
  .cio_rx_i  (uart_rx),
  .cio_tx_o  (uart_tx),
  .cio_tx_en_o(uart_tx_en),
  .intr_*_o  (intr_*)
);
```

## 3. 接口连接表

### 3.1 总线接口

| 信号 | 方向 | 说明 |
|------|------|------|
| `tl_i` / `tl_o` | in/out | TL-UL 请求/响应（`uart`） |
| `psel/penable/pwrite/paddr/pwdata/pstrb` | in | APB 控制/数据（`uart_apb_top`） |
| `prdata/pready/pslverr` | out | APB 读数据/就绪/错误 |

### 3.2 串行 IO

| 信号 | 方向 | 说明 |
|------|------|------|
| `cio_rx_i` | in | 串行接收输入 |
| `cio_tx_o` | out | 串行发送输出 |
| `cio_tx_en_o` | out | 发送使能（恒为 1） |

### 3.3 中断（9 个，均高电平有效）

tx_watermark、tx_empty、rx_watermark、tx_done、rx_overflow、
rx_frame_err、rx_break_err、rx_timeout、rx_parity_err

### 3.4 Alert

| 信号 | 说明 |
|------|------|
| `alert_rx_i[0]` | fatal_fault alert 接收（Integrity 违规触发） |
| `alert_tx_o[0]` | fatal_fault alert 发送 |

## 4. 时钟复位

| 信号 | 说明 |
|------|------|
| `clk_i` | 单时钟域（系统时钟） |
| `rst_ni` | 异步复位、同步释放，低有效 |

## 5. 未使用端口 tie-off

| 端口 | tie-off |
|------|---------|
| `racl_policies_i` | 当 `EnableRacl=0` 时接 `'0` |
| `alert_rx_i` | 未接时用 `prim_alert_pkg::ALERT_RX_DEFAULT` |
| `racl_error_o`/`lsio_trigger_o` | 不用时悬空 |

## 6. 编译与集成

- RTL filelist：`rtl/filelist.f`（含 `-f rtl/filelist_libs.f` 公共库依赖闭包）
- 公共库：统一在统一仓 `ips/lowrisc/{prim,tlul,top}`，经 FuseSoC `.core` 引用
- FuseSoC core：`fusesoc/rtl-team_ip_uart.core`（8 targets，含 apb）

## 7. 集成检查清单

详见 `uart_integration_checklist.md`（或 xlsx 版）。
