# APB CDC Bridge — HLD 可测性/可观测

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 可观测性

- 上游/下游 APB 接口信号天然可观测（协议 monitor）。
- 内部 req/rsp toggle 可用于事务级观测。
- 提供 SVA 断言（位于 `verification/`）：
  - one upstream transfer → at most one downstream transfer
  - one downstream completion → at most one upstream completion
  - request/response payload stable during CDC
  - no spurious PREADY / PSLVERR
  - no downstream APB protocol violation
  - no transaction while destination reset

## 2. 可测性

- 无内部 RAM/FIFO 深度依赖；FIFO 实现可选（深度 1/2）便于覆盖。
- 时钟暂停/恢复场景可测（时钟门控兼容）。

## 3. Scan 兼容

- 采用标准时序逻辑（`always_ff`），天然兼容 Scan insertion。

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 03-hld-architect*
