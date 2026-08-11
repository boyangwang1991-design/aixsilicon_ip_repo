# 寄存器模型质量检查报告 - uart

| 项目 | 值 |
|---|---|
| IP | uart |
| RDL 源 | `regs/uart.rdl` |
| 生成时间 | 2026-08-11 |
| PeakRDL 版本 | peakrdl 1.5.0 / regblock 1.3.1 |
| 状态 | PASS |

## 1. 一致性检查

- ✅ 14 个寄存器地址偏移与 OpenTitan `uart.hjson` 完全一致（0x00–0x34）。
- ✅ 字段位宽、访问类型、复位值与 uart.hjson / LRS 03_register.md 匹配。
- ✅ W1C（INTR_STATE）、W1S 测试（INTR_TEST）、WO（WDATA/RXRST/TXRST）等 side-effect 明确定义。
- ✅ 无字段重叠或间隙错误（reserved 由工具自动推断）。
- ✅ 枚举字段（RXBLVL/RXILVL/TXILVL）与 uart.hjson enum 一致。

## 2. 生成产物验证

| 产物 | 路径 | 验证 |
|---|---|---|
| SystemRDL 源 | `regs/uart.rdl` | peakrdl dump 通过 |
| CSR RTL (pkg) | `rtl/generated/uart_csr_pkg.sv` | vlogan 编译通过 |
| CSR RTL (module) | `rtl/generated/uart_csr.sv` | vlogan 编译通过 |
| CSR manifest | `rtl/generated/uart_csr.manifest.yaml` | publish_csr.py PASS |
| C header | `sw/include/uart_regs.h` | 生成成功 |
| HTML 文档 | `docs/generated/uart_regs.html/` | 生成成功 |
| IP-XACT/RAL | `verification/ral/uart.xml` | 生成成功 |

## 3. CPU 接口适配决策

- **决策**：`regblock` 采用 `apb4-flat` CPU 接口生成 `uart_csr`，用于 APB 接入路径与发布流程验证。
- **核心说明**：UART 核心 RTL 保持 OpenTitan 原版 `uart_reg_top.sv`（TL-UL 接口）与 `uart_reg_pkg.sv` 不变（用户要求不改核心代码）；RDL 作为文档/C header/HTML/IP-XACT 的权威源。APB 接入通过新增 `apb2tlul` wrapper（协议转换，不改核心）实现。
- HLD 生成后用 `model/external_interface.yaml` 复核（见 03-HLD）。

## 4. 生成规则

- 生成文件未手工修改；重新生成即由 PeakRDL 覆盖。
- manifest sha256 与当前 RDL 及生成文件一致。

## Findings

| 编号 | 严重度 | 描述 | 状态 |
|---|---|---|---|
| REG-FIND-001 | Info | 核心 CSR 使用 OpenTitan reggen 版本；PeakRDL CSR 为 APB-flat 备选/发布验证用，需在 HLD/RTL/验证中保持地址一致性 | Open |
