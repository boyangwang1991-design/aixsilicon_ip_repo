# APB Demux — 功能安全需求（SAFE）

> 本文档是 LRS 文档的一部分，请参阅 [主索引文件](index.md)。

---

## 1. 功能安全需求 / Functional Safety Requirements

**N/A - 本 IP 无 ISO 26262 功能安全目标。**

APB Demux 为地址路由互联 IP，不承担安全相关功能，不包含 ECC/Parity、错误注入、
安全机制或 FMEDA 关联。若 SoC 级要求对 APB 访问路径进行安全监控，应通过独立的
APB Timeout Monitor / Error Slave 在系统级实现，不在本 IP 内实现。

---
