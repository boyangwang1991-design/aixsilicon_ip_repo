# APB CDC Bridge — LLD 验证要点

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 验证要点

| 模块 | 验证要点 |
|------|----------|
| SOURCE | 捕获时机、单事务、wait-state、响应返回、复位 |
| DEST | SETUP/ACCESS 时序、wait-state 稳定、完成捕获、复位 |
| HS_CDC | 握手不丢/不重、payload 稳定、ack 返回 |
| FIFO_CDC | FIFO 读写、深度 1/2、灰度指针、单事务保持 |
| TOP | 参数校验、CDC_IMPL 隔离（仅例化所选实现） |

## 2. 隔离验证

- `CDC_IMPL=HANDSHAKE`：仅握手实现被例化，FIFO 无数据通路。
- `CDC_IMPL=ASYNC_FIFO`：仅 FIFO 实现被例化，握手无数据通路。
- 两种实现行为等价（读/写/错误/等待）。

## 3. 断言要点

- 一个上游 transfer → 至多一个下游 transfer。
- 一个下游 completion → 至多一个上游 completion。
- request/response payload CDC 期间稳定。
- 无 spurious PREADY / PSLVERR。

## 4. 时钟关系矩阵

1:1 async / 1:2 / 1:4 / 1:8 / 2:1 / 4:1 / 8:1 / near-frequency async / random irrational ratio。

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 05-lld-microdesign*
