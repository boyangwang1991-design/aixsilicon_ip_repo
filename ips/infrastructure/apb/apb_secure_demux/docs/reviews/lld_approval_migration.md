# LLD 历史批准格式迁移核对

本记录于 2026-09-14T07:14:06.640530+00:00 核对旧批准与当前输入，不新增审批，不重新解释用户授权。

实际批准人为此前会话用户，原文及范围见 [g2_behavior_approval.md](g2_behavior_approval.md)。
批准记录 SHA-256：`29a222ee87a6f08623ea1a7c356158fb602d12fa5e0709217f2d994e11c123b1`。

旧清单 `g2_behavior_approved/current_g2_identity.json` 的 SHA-256：`b6bcd3521a7584e720dfc6b5b955af6bef423a9c0a5cf892896c37708c4510af`。
本阶段完整 Markdown 集合共 35 份；全部与既有批准后清单逐字节相同。

本次仅在 GATE_META 增加当前套件所需 approval 字段，上游同类格式迁移不改变设计语义。reviewed_at 记录此次迁移核对时间，原始用户批准时间没有完整时间戳，不以该值冒称新的人类批准。输入指纹绑定当前设计及上游批准块；原始哈希清单和差异留在本地 build/design/resume_20260914。

范围仅为既有设计/行为批准；CSR 当前生成证据、RTL/UT、UVM、形式、PPA 和系统集成签核分别重新核验，旧 PASS 不替代本次执行。

抽取时发现已退役的重复字段 illegal_state_policy: safe_state；删除该冗余字段，保留原有 illegal_state_handling: 隔离输出与状态修改，等待可信复位恢复。未改变状态处理行为；这是 extractor schema 兼容迁移。
