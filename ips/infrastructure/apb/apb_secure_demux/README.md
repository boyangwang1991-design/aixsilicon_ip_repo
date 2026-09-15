# 安全 APB Demux

APB4 1→N安全路由IP，目标版本1.0.0，资产编号 INF-046。设计文档、原生CSR多视图、RTL与验证入口随本工程维护；当前资格和未关闭项统一读取[结论报告](reports/report.md)。

- [当前结论与后续工作](reports/report.md)
- [LRS](docs/lrs/index.md) / [HLD](docs/hld/index.md) / [LLD](docs/lld/index.md)
- [寄存器生成与检查](regs/README.md) / [G2字段行为批准](docs/reviews/g2_behavior_approval.md)
- [验证方案](docs/verification/index.md) / [VP0评审包](docs/reviews/vp0_review.md)
- 机器 Gate/RTM/UT 结果生成到 `build/reports/quality/`，仅本地保留。

Python使用workflow根uv环境，EDA运行产物位于build。实际集成配置与验证夹具分开受控。

在 workflow 根运行：

```bash
uv run python repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/scripts/run_rtl_checks.py lint --suite .roo/skills/ip-development-suite
uv run python repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/scripts/run_rtl_checks.py elab --suite .roo/skills/ip-development-suite
uv run python repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/scripts/run_rtl_checks.py synth --suite .roo/skills/ip-development-suite
uv run python repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/scripts/run_module_ut.py
```

综合前先用 suite 的 ip_pdk_scan.py（显式 --pdk /home/eda/pdk）及 render_dc_setup.py 生成本地工艺上下文。公开构建可直接消费 Core 的 lint/elab/synth/ut_* targets；`--suite` 仅供本地证据适配器使用。SpyGlass 的原始返回码11仅在零Fatal/零Error且明确完成检查时归为“含告警完成”，完整告警仍须评审，其他失败原样传播。
