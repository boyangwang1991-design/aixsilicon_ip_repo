# 仓库管理元数据

- `reserved-ids.yaml`：保留名称与稳定 ID，防止改号和编号复用。
- `retired-assets.yaml`：退出/迁移条目的运行索引，保留原身份、处置、文件位置、恢复方法及迁移目标。校验器据此阻止误恢复。

完整旧规划已移至 [历史快照](../docs/archive/2026-09-ip-materials-review/retired-assets.full.yaml)，显式恢复时按 original.name 查找。恢复先复核需求与归属，再同步 registry 和处置状态；现行处置仍以本目录为准。

这两个 YAML 为有效管理输入，当前资产清单只有根 registry.yaml。scripts/data/ip_ids.json 为旧入口兼容映射，不能用作旧规划生成源。
