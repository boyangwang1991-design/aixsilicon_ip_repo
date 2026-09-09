# APB Demux — 低功耗需求（LP）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 低功耗需求 / Low Power Requirements

**N/A - 本 IP 为轻量级 APB 互联逻辑，无专用低功耗需求。**

APB Demux 为纯组合逻辑（地址译码 + 请求 fanout + 响应 mux）加少量可选时序
逻辑（timeout counter、response register），不包含独立电源域、无时钟门控接口、
无唤醒通道、无 Retention 需求。功耗主要由动态翻转决定，属于综合/PPA 优化范畴，
不作为独立低功耗功能需求。

---
