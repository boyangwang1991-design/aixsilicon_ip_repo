# APB Demux — HLD 分解建议

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. LLD 分解建议

根据 LRS 与 HLD 架构，LLD 阶段建议保持与 HLD 一致的模块边界，但主实现可
保持**单模块参数化 RTL**（`apb_demux_top.sv`），内部按逻辑块组织，不强制
拆分为独立 RTL 文件（LRS CONS 02.001 要求保持简单）。

| HLD 模块 | LLD 建议 | 说明 |
|----------|----------|------|
| `apb_demux_top` | `rtl/apb_demux_top.sv` | 参数化顶层，含全部逻辑块 |
| `apb_demux_decode` | 顶层内部 always_comb 块 | 地址译码 + PSEL + decode_miss |
| `apb_demux_route` | 顶层内部组合逻辑 | fanout + mux + 透传 |
| `apb_demux_err` | 顶层内部逻辑 + 可选时序块 | decode error / timeout / response register |

## 2. 面向 RTL 的输出约束

- 无 `regs/*.rdl`（`register_model=none`）；
- 无 `rtl/generated/` CSR；
- 单时钟域、无 CDC；
- 所有参数在顶层声明，配置校验由 Python 脚本完成。

## 3. 面向验证方案的输出

- 验证特性：地址译码正确性、PSEL onehot、wait-state、PSLVERR 透传、
  Decode Miss、remap、timeout、response register、APB3/APB4、参数组合；
- 断言：`$onehot0(M_PSEL)`、wait-state 稳定、decode 正确性、decode miss 响应；
- 覆盖点：地址边界、命中/未命中、wait-state 周期数、PSLVERR、超时、remap 开关。

---

*文档版本: v1.0*
*创建日期: 2026-09-09*
*创建者: IP Development Suite - 03-hld-architect*
