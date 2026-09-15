# AIXSILICON Watchdog

APB4 参数化看门狗，支持独立监督计时、窗口服务、故障升级与恢复，以及可选多客户端
和安全增强能力。设计输入见 [watchdog_contract.md](watchdog_contract.md)。

**当前结论、门禁、未关闭问题及复现入口统一见 [reports/report.md](reports/report.md)。**
该工程仍在完整设计验证流程中，不代表正式发布或功能安全认证。

- [LRS](docs/lrs/index.md)
- [HLD](docs/hld/index.md)
- [LLD](docs/lld/index.md)
- [VPLAN](docs/verification/index.md)
- [SystemRDL](regs/watchdog.rdl)
- [RTL 顶层](rtl/watchdog_top.sv)
- [使用说明](docs/user_guide.md)与[安全说明](docs/safety_manual.md)
- [持续授权原文](docs/reviews/continuation_authorization.md)

本地执行使用 workflow 根的唯一 uv 环境。设置 UV_PROJECT 为 workflow 根后，
模块回归入口为 `bash verification/unit_test/run_ut.sh`，UVM 入口为
`verification/sim/Makefile`，RTL 检查入口为 `scripts/run_rtl_checks.py`。
恢复输入和追踪使用 `scripts/refresh_design.py`，不手改派生 model/trace。

新运行的机器摘要、日志、数据库及临时产物全部写入被忽略的 `build/`，不上传 GitHub。
历史阶段报告不作为当前完成证据；AI 读取本轮机器结果后更新统一报告。
PPA 表征状态及限制见 [PPA 专报](reports/ppa/ppa_report.md)。
