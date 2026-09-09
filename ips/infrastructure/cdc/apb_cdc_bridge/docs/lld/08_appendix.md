# APB CDC Bridge — LLD 附录

> 本文档是 LLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 参考协议

- AMBA 3 APB Protocol Specification（IHI 0024）
- AMBA 4 APB Protocol Specification（IHI 0034）

## 2. CDC 参考

- Cliff Cummings, "Clock Domain Crossing (CDC) Design & Verification Techniques Using SystemVerilog"
- Bundled-data handshake / 2FF synchronizer / gray-code pointer FIFO

## 3. 术语

| 术语 | 说明 |
|------|------|
| CDC | Clock Domain Crossing |
| 2FF | 双触发器同步器 |
| Bundled-data | 数据与使能控制一起跨域 |
| Toggle | 电平翻转握手 |
| Gray pointer | 灰度编码指针（FIFO） |

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 05-lld-microdesign*
