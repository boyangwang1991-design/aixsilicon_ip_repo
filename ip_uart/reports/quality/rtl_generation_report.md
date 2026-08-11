# RTL 生成报告 - uart

| 项目 | 值 |
|---|---|
| IP | uart |
| 状态 | PASS（candidate） |
| 日期 | 2026-08-11 |

## 1. RTL 文件清单

| 文件 | 说明 | 来源 |
|---|---|---|
| rtl/uart.sv | UART 顶层（TL-UL） | OpenTitan 原版（未改动） |
| rtl/uart_core.sv | 核心逻辑 | OpenTitan 原版（未改动） |
| rtl/uart_rx.sv | 接收模块 | OpenTitan 原版（未改动） |
| rtl/uart_tx.sv | 发送模块 | OpenTitan 原版（未改动） |
| rtl/uart_reg_top.sv | 寄存器堆 | OpenTitan 原版（未改动） |
| rtl/uart_reg_pkg.sv | 寄存器包 | OpenTitan 原版（未改动） |
| rtl/apb2tlul.sv | APB→TL-UL 桥（新增） | 自研，参考 vyges/tlul-apb-adapter FSM |
| rtl/uart_apb_top.sv | APB 顶层封装（新增） | 自研 |
| rtl/generated/uart_csr_pkg.sv / uart_csr.sv | PeakRDL CSR（APB-flat） | 生成 |
| rtl/filelist.f / filelist_libs.f | 编译文件列表 | 生成 |

## 2. 核心代码完整性验证

- ✅ 核心 6 个文件与 `reference/opentitan/hw/ip/uart/rtl/` 哈希一致（md5 校验通过）。
- ✅ 未修改任何核心 RTL；APB 接入仅通过新增 wrapper 实现。

## 3. 公共库策略

- 按用户要求，prim/tlul/top 公共库统一复制到统一仓 `ips/lowrisc/{prim,tlul,top}/0.1.0/`，通过 FuseSoC `.core`（`lowrisc:prim:all` / `lowrisc:ip:tlul` / `lowrisc:top:constants`）depend 引用。
- `ip_uart/rtl/filelist_libs.f` 为 UART 依赖闭包（9 包 + 63 模块），供 VCS 独立编译。

## 4. 编译验证（VCS W-2024.09）

- ✅ vlogan 编译全部文件通过（无 error）。
- ✅ Elaboration `uart`（TL-UL 顶层）通过 → `simv_uart`。
- ✅ Elaboration `uart_apb_top`（APB 顶层）通过 → `simv_uart_apb`。

## 5. 说明

- RTL 为 candidate；`09-rtl-check` 将运行 SpyGlass lint 与 VCS elaboration 复验。
- 公共库 `.core` 引用路径为统一仓绝对结构，FuseSoC 消费者 add 统一仓即可解析依赖。

## Findings

| 编号 | 严重度 | 描述 | 状态 |
|---|---|---|---|
| RTL-FIND-001 | Info | vyges/tlul-apb-adapter 为 TL-UL→APB 方向；本 IP 需要 APB→TL-UL，故参考其 FSM 结构自研 apb2tlul | Open |
