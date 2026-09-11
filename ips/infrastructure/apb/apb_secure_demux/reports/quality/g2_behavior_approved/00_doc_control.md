# 微架构文档控制

<!-- LLD_DOC_META
schema_version: '2.0'
ip_name: apb_secure_demux
delivery_model: parameterized
hld_baseline: ASD-HLD-1.0.0-USER-APPROVED
document_version: 1.0.0
status: draft
END_LLD_DOC_META -->

本轮输入是已获用户批准的 G1，审批原文与哈希记录见 ../reviews/g1_approval.md。本文细化实现行为，未将未来技术冻结写成既成事实。结构定义由后续 SystemRDL 持有；本目录不维护 offset/bit 表。

LLD 作者变更、真实冻结、机器检查独立记录。型号、地址、管理主体与启动策略继续以集成配置为输入。验证夹具不成为产品默认。
