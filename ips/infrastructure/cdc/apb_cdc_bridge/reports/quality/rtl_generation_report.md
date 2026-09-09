# RTL 生成报告 — apb_cdc_bridge

> **IP**: `apb_cdc_bridge` | **日期**: 2026-09-07 | **Gate**: G3 输入（RTL candidate）

## 1. RTL 文件

| 文件 | 模块 | 说明 |
|------|------|------|
| `rtl/apb_cdc_bridge_pkg.sv` | package | 参数/常量包 |
| `rtl/apb_cdc_sync_chain.sv` | apb_cdc_sync_chain | 可配置级数 2FF 同步器 |
| `rtl/apb_cdc_handshake.sv` | apb_cdc_handshake | HANDSHAKE CDC 实现 |
| `rtl/apb_cdc_async_fifo.sv` | apb_cdc_async_fifo + _ram | ASYNC_FIFO CDC 实现 |
| `rtl/apb_cdc_source.sv` | apb_cdc_source | 源域 APB 捕获 |
| `rtl/apb_cdc_dest.sv` | apb_cdc_dest | 目的域 APB 生成 |
| `rtl/apb_cdc_bridge_top.sv` | apb_cdc_bridge_top | 顶层（参数化 + 隔离例化） |
| `rtl/include/apb_cdc_bridge_defs.svh` | — | 定义头 |

## 2. 编译验证（VCS elab）

| 配置 | 结果 |
|------|------|
| HANDSHAKE（CDC_IMPL=0, SYNC_STAGES=2） | ✔ simv 生成 |
| ASYNC_FIFO depth=2（CDC_IMPL=1, REQ/RSP_DEPTH=2） | ✔ simv 生成 |
| ASYNC_FIFO depth=1（CDC_IMPL=1, REQ/RSP_DEPTH=1） | ✔ simv 生成 |

## 3. 设计要点

- **CDC_IMPL 二选一隔离**：`generate` 分支按 `CDC_IMPL` 例化 HANDSHAKE 或 FIFO，未选中实现不例化（满足 LRS.FUNC.04.002）。
- **Bundled-data**：payload 打包 + 单 toggle 握手，禁止逐 bit 同步。
- **非法配置断言**：`generate` + `$error` 实现编译期校验（满足 LRS.CONS.01.001）。
- **单事务**：源/目的 FSM 保证任一时刻一个跨桥事务。

## 4. 状态

RTL 为 **candidate**；待 09-rtl-check（lint/elab）与综合确认后才可声明 G3 pass。
