# Changelog

All notable changes to the unified IP repository are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.2.0] - 2026-09-07

### Added

- **IP Master Catalog**：`registry.yaml` 升级为全量 IP 目录 SSOT，覆盖 plan.md 的
  P0/P1/P2/P3 规划 **369 条 IP**（含已交付 uart / 规划候选纳管 hac_aes、lowrisc_* 等）。
- 新增目录管理脚本 `scripts/`（对齐 cbb_repo 框架）：
  - [`scripts/build_ip_registry.py`](scripts/build_ip_registry.py)：registry.yaml 生成 / 校验 / 规范化；
  - [`scripts/update_registry_readme.py`](scripts/update_registry_readme.py)：将 registry 状态总览
    自动刷新到 README.md（marker 区块）；
  - [`scripts/ip_status.py`](scripts/ip_status.py)：按优先级/类型/领域/状态查询 IP 状态；
  - [`scripts/ip_lib.py`](scripts/ip_lib.py)：公共库（校验 / Markdown 表格）。
  - [`scripts/data/`](scripts/data/)：IP 清单数据（P0/P1/P2/P3 按领域分文件）。
- README.md 新增「IP 状态总览」自动生成区块与脚本使用说明。
- CI `validate-index` job 升级：`build_ip_registry.py --check` + `update_registry_readme.py --check`。

### Changed

- `registry.yaml` 条目格式升级：新增 `domain/subdomain/type/priority/status/maturity/interfaces`
  字段（原 `ips[].versions[]` 嵌套格式改为扁平 `ips[]` 单版本模型，简化维护）。
- `registry.yaml` 由手工维护改为脚本生成（`scripts/data/*.py` 为数据源）。
- **首个 infrastructure/bridge 工程包入库**：`ip_x2p`（AXI→APB 桥）迁移为
  [`ips/infrastructure/bridge/axi2apb_bridge`](ips/infrastructure/bridge/axi2apb_bridge/README.md:1)，
  类型由 `generator` 改为 `ip`，VLNV `aixsilicon:ip:axi2apb_bridge:1.0.0`，
  `status=implemented`（G0-G3 通过，G4 BUG-001 blocking）。
- **IP 开发位置约束（ADR-2026-09-07）**：`ip-development-suite` skill 更新——以后做 IP
  直接在本仓 `ips/<domain>/<subdomain>/<ip_name>/` 就地开展，不再创建独立 `ip_<name>/` 工作区。

### Removed

- 移除 registry 中 `unified_repo` 顶层字段（仓库地址在 `ipkg.yaml` / README 中维护）。

## [0.1.0] - 2026-08-11

### Added

- 初始化统一 IP 仓（monorepo）结构。
- 内嵌索引 `registry.yaml`（schema_version 2.0）。
- `ipkg.yaml` 配置（GitHub: boyangwang1991-design/aixsilicon_ip_repo，
  VLNV 命名空间：boyangwang1991-design:ip）。
- 统一仓 CI（扫描 `ips/` 全部 FuseSoC core 做 lint）。
- 仓库级文档 `docs/opentitan-ip-build-list.md`（OpenTitan IP 构建清单）。
