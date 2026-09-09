# APB CDC Bridge — HLD 风险清单

> 本文档是 HLD 文档的一部分，请参阅 [主索引文件](index.md)。

---

| ID | 风险 | 影响 | 缓解 |
|----|------|------|------|
| HLD-R1 | 亚稳态传播 | 数据损坏 | 仅同步单 bit toggle + bundled-data 保护 |
| HLD-R2 | 握手死锁（时钟暂停） | 事务挂起 | 状态保持、时钟恢复后继续；reset-abort 兜底 |
| HLD-R3 | 复位 stale transfer | 伪事务 | 每域独立复位，toggle 复位到已知态 |
| HLD-R4 | reconvergence | CDC 违例 | 单控制事件单路径同步，payload 不逐 bit 同步 |
| HLD-R5 | 快→慢长等待 | 上游阻塞 | wait-state 合法、request 锁存 |
| HLD-R6 | FIFO 深度误解 | 面积浪费 | HANDSHAKE 默认，FIFO 仅按需 |
| HLD-R7 | 同频异相误判同步 | CDC 失败 | 默认 ASYNC_SAFE，不自动判断同步 |

---

*文档版本: v1.0* | *创建日期: 2026-09-07* | *创建者: IP Development Suite - 03-hld-architect*
