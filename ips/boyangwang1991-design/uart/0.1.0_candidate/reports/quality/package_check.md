# FuseSoC 打包质量检查报告 - uart

| 项目 | 值 |
|---|---|
| IP | uart |
| core | fusesoc/rtl-team_ip_uart.core |
| FuseSoC 版本 | 2.4.6 |
| 状态 | PASS |

## 1. Core 结构

- ✅ 名称：`boyangwang1991-design:ip:uart:0.1.0`
- ✅ 提供 8 个 target：default（TL-UL）、apb（APB）、lint、elab、sim、smoke、synth、formal。
- ✅ 依赖统一仓公共库：`lowrisc:prim:all`、`lowrisc:ip:tlul`、`lowrisc:top:constants`（FuseSoC 解析通过）。

## 2. 双总线隔离（.core）

| Target | 顶层 | filesets | 说明 |
|---|---|---|---|
| default | uart | rtl_handwritten + common | TL-UL 从接口（原始核心） |
| apb | uart_apb_top | rtl_handwritten + rtl_apb_wrapper + rtl_generated + common | APB4 接入（经 apb2tlul，核心不变） |

- ✅ 两个 target 通过独立 toplevel 隔离，不会同时实例化冲突。

## 3. 文件存在性

- ✅ core 中引用的所有源文件均存在（rtl/uart*.sv、rtl/apb2tlul.sv、rtl/uart_apb_top.sv、rtl/generated/*.sv）。
- ✅ generated RTL 与 handwritten RTL 分组明确。

## 4. FuseSoC 解析验证

- ✅ `fusesoc core show boyangwang1991-design:ip:uart` 显示 8 个 target。
- ✅ `fusesoc core show lowrisc:prim:all` 显示公共库 default target。

## 5. 依赖版本

- 公共库版本 0.1.0（`ips/lowrisc/{prim,tlul,top}/0.1.0/`），由 FuseSoC 按 name 解析。
- ⚠️ reference/opentitan 原目录的 `.core` 因 waver 文件缺失被忽略（不影响本 IP，因统一仓公共库已独立）。

## Findings

| 编号 | 严重度 | 描述 | 状态 |
|---|---|---|---|
| PKG-FIND-001 | Info | 公共库 VLNV 沿用 lowrisc 命名空间，本 IP 用 boyangwang1991-design 命名空间 | Open |
