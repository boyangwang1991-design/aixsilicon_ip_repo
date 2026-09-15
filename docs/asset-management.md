# IP / CBB 资产管理

分类依据见 [分类原则](ip-cbb-classification.md)。CBB 为 IP 开发提供核心逻辑；IP 对 SoC/子系统承担独立集成功能。完整 AXI 切片、APB 桥及完整总线 CDC 属于 IP；通用 ready/valid 缓冲、局部同步及权限比较核属于 CBB；本项目的 axi_channel_register_slice 明确归 IP。无需为分类添加 CSR、中断或空 RTL 封装。

本仓主要由 `ip-development-suite` 管理：Skill 执行分类、登记、开发、状态和发布交接流程，repo 提供资产事实与确定性检查。先更新 canonical Skill 后物化运行。公开仓库校验仍可独立运行，不依赖私有 Skill。

两仓统一执行以下管理策略：

1. **事实源**：直接编辑仓库根 `registry.yaml`。README 为派生视图；规划状态、优先级与发布资格分开。旧 Python 清单、指导 YAML 均为归档快照，不能作为生成源。
2. **身份**：`id` 是稳定索引编号，VLNV 是构建身份，二者不可混用。`governance/reserved-ids.yaml` 保留历史编号，新登记时同步追加，迁移/退役后不复用。`MIG-*` 保留指导清单编号。
3. **状态**：`planned` 允许有设计、RTL 或开发目录；`implemented` 表示已有实现记录，并非正式发布；`released` 需版本冻结和发布证据；`deprecated` 保留兼容信息。成熟度与 Gate 必须有相应版本/配置/工具证据，目录校验不能授予验证资格。
4. **分类与实现分离**：仓库 library 决定 IP/CBB 分类。IP `type=generator/wrapper/subsystem` 是兼容保留的实现/封装标签；CBB `implementation` 表示实现变体。Generator 或 Wrapper 不是第三种资产责任类别。
5. **唯一实现**：IP 优先通过固定版本 FuseSoC Core 引用 CBB，禁止复制同一通用 RTL。完整协议、错误恢复与集成验证仍由 IP 承担。依赖需形成闭包，不使用未声明跨仓源码路径。
6. **收敛与恢复**：迁移/退出记入 `governance/retired-assets.yaml`，保存原身份、原因、文件处置及目标映射；完整旧规划在 historical_snapshot 指定的归档中，按 original.name 查找。退出主清单不删除现有源码。恢复需复核责任和需求，将记录标为 `restored`，恢复原 ID 后重新校验。
7. **依赖与示例**：混合上游库、测试库和常量包作为依赖管理；模板/参考组合/PPA 配方不计入正式硬件主清单。历史候选信息保存在退出记录，不代表依赖已下载或已锁定。
8. **交付与发布**：规格、RTL、验证、PPA、约束、版本及依赖随资产保存；通用研发方法由 Skill 管理。迁移后的历史 Gate 保留原始路径/hash，新身份正式发布前重新验证；各仓独立提交和审查，跨仓迁移联合验证后一起更新基线。

在 workflow 根统一使用现有 uv 环境；仓库可独立用 Python + PyYAML 执行以下仓内命令：

```bash
python3 scripts/build_ip_registry.py --check
python3 scripts/build_ip_registry.py --write    # 可选规范化，保留扩展字段
python3 scripts/update_registry_readme.py
python3 scripts/update_registry_readme.py --check
```

仓库 CI 提供同样的索引和 README 门禁，保持手动触发策略。领域仿真/综合/发布 Gate 独立执行。

## 执行证据仅本地

本仓提交源码、约束、复现脚本/配置、最终质量摘要与签核结论及必要的输入/证据哈希。
原始 evidence（含哈希对象和索引）、工具日志、覆盖率 HTML/数据库、编译产物、预检
和逐次运行输出仅本地保留，不提交 Git、不上传 GitHub 或 Release 附件。根 `.gitignore`
覆盖存量路径；新执行产物按 IP suite 写入 `build/`。提交前运行
`python3 scripts/check_evidence_hygiene.py`，它检查 Git 索引而非仅检查忽略规则。

新 clone 不包含原始证据。按各 IP 的脚本、FuseSoC target 和验证计划重跑 owning 阶段，
生成本次报告与哈希后再验收；已提交的 PASS 是历史摘要，不能代替本次本地证据校验。
详细流程与发布集合由 canonical `ip-development-suite` 的 gate-evidence-retention 约束。

2026-09 清理取消跟踪原始证据并保留本地文件；GPIO 旧 candidate 的 manifest、说明和
package report 同步取消跟踪，避免将包含原始证据的旧包继续作为当前交付。未改写历史
技术结论或 Git 历史；需要新发布时按更新后的套件重建。

历史清理记录见 [清理报告](archive/2026-09-ip-materials-review/cleanup-2026-09.md)；`docs/archive/2026-09-ip-cbb-cleanup/` 保存清理前清单及指导快照。

## 历史材料隔离

归档区仅用于审计或显式恢复，不作为开发套件默认上下文、生成源或发布输入。退出资产的纯空占位目录可按原路径归档，并更新 retired-assets.yaml 的 archive_path；有实现或证据的存量工程先保留，不能仅凭未入主清单推定过时。历史变更日志和 Gate 报告不用于覆盖当前状态。

旧 ipkg.yaml 已归档，不再作为发布策略输入。当前发布须执行开发套件的证据与交接检查，并遵循工作区发布策略；历史 auto_tag/auto_push 不能视为执行授权。
