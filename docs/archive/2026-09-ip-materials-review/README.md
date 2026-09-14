# IP 材料清理归档（2026-09-13）

本目录保存历史原文，不作为当前研发指令或验证基线。

- cleanup-2026-09.md、cleanup-validation.md、stale-materials-audit.md：旧清单数量、阶段测试和跨仓整理报告。
- ipkg.yaml：旧统一建仓/发布配置；当前仓内脚本、IP Skill 与工具代码未检出读取者，原自动推送配置不构成现行授权。
- retired-assets.full.yaml：精简前完整退出记录；按 records[].original.name 查找旧规划。现行恢复约束和 archive_path 保留在 governance 中。
- changes.json：原路径、新路径和归档 SHA-256；删除项仅零字节 ucli.key。

扫描仓根及 ips 下 3095 个非构建文件，排除 .git、build、缓存及已有 archive。保留 293 条现行规划、需求合同、RTL、发布资料和工程证据；未登记但有实质材料的 apb_secure_demux 仍按退出记录保留。保留证据索引引用的零字节工具日志、Watchdog 完整流程计划和其他未确认过时的工程材料，不按日期或空文件一概删除。

本轮移除历史材料的当前入口，修正 AXI 单通道归属表和脚本旧 plan.md 注释。原工程文件除处置清单中的空日志外按清理前哈希复核。

## 验证

归档 SHA-256 核对通过；96 条退役记录保留的身份、处置、迁移、archive_path 与恢复字段一致；除 5 个空 ucli.key 外，3070 个工程文件与清理前哈希一致。registry 和 README 派生视图检查通过，管理交接回归 18 passed。

现有 PER-009 watchdog 版本与 SEC-015 memory_protection_controller 名称/版本不一致警告仍保留；不能通过删除元数据掩盖，需后续设计身份对齐。本轮未修改 RTL、工程证据或发布状态，未提交推送。
