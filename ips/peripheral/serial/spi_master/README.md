# SPI Master

已实现的 APB4 单时钟、队列式四线 SPI master，支持四种模式、1–32 位帧、两种位序、五类命令、片选保持、资源暂停、超时与安全中止。寄存器由 SystemRDL/PeakRDL 生成，TX/RX/CMD 队列实际复用 CBB sync_fifo。原始合同保持不变。

- [实施与验收结果](reports/acceptance.md)
- [SKILL 改进报告](reports/skill-improvement-report.md)
- [集成及软件指南](docs/integration.md)
- [LRS](docs/lrs/index.md)、[HLD](docs/hld/index.md)、[LLD](docs/lld/index.md)、[验证方案](docs/verification/index.md)
- [寄存器源](regs/spi_master.rdl)、[驱动 API](sw/include/spi_master.h)、[软件示例](sw/examples/transactions.c)

在 IP 目录执行 `make smoke`、`make regression`、`make unit`、`make params`、`make lint`、`make coverage`、`make driver`。定向执行如 `make sim CONFIG=max TEST=modes SEED=17`。`make registers models` 再生成衍生产物，不编辑 generated RTL 或 model YAML。`make acceptance trace quality` 汇总现有证据；`make signoff` 会对未通过 Gate 返回非零；quality 同时保存原始套件审计结果与本地混合证据适配后的判定；signoff 检查后者的全部 Gate。当前 G0–G5 通过：原始 DUT 行覆盖 91.62%，按用户授权以 90% 验收，功能与必需断言仍为 100%。

依赖来自 workspace 根 pyproject.toml 的 ip-dev extra，通过根 `uv sync --extra ip-dev` 安装；不创建 IP 私有虚拟环境。VCS W-2024.09-SP1、UVM 1.2、SpyGlass X-2025.06、DC V-2023.12-SP3 用于本次验收，许可证须可达。默认构建离线且不修改依赖锁。

综合先执行 `make pdk` 生成本机 PDK 配置，再运行 `make synth CONFIG=small/default/max`。本次已有真实 GF 28nm TT/HVT 配置及结果；PDK 库不随 IP 分发。constraints/characterization.sdc 是实验预算，目标板级约束与量产冻结须依据集成条件处理。

FuseSoC VLNV 为 `aixsilicon:ip:spi_master:1.0.0`，提供 default/elab/lint/sim/smoke/synth 目标。sim/smoke 是默认参数；参数矩阵使用上述 Python runner，源文件和编译参数经哈希校验。生成软件/文档及本次候选实现版本不代表完成独立人工技术审批。

原始文本日志、综合网表及编译源副本归档在 `reports/evidence/`；新 checkout 可用 `uv run --offline --no-sync python scripts/archive_evidence.py --restore` 恢复受哈希校验的 build 证据。VCS runtime、VDB 和 PDK 库不归档，重新运行需要已安装工具与许可证。
