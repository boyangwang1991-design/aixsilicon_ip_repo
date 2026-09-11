# Watchdog LRS 准备阶段历史执行结果

本文保留 G0 交接前的检查记录。当前阶段状态见 execution_results.md。

本次完成的是全流程恢复的 LRS 准备与现状审计；**用户要求的完整交付尚未完成**。
HLD/LLD/VPLAN 的规则重整是 required 后续工作，当前未声明它们已经重写或通过。

| 实际执行 | 结果 | 证据 |
|---|---|---|
| bootstrap --ensure | skills 指纹一致，复用物化副本 | 套件源 `768872ec6ab4` |
| aix wf status / repo status ip | 初始 clean；修改后仅目标 IP 文档及模型/报告新增 | IP HEAD `2fd687b61943`，profile all |
| aix wf doctor | exit 0 | 所需仓存在，依赖 DAG 无环 |
| preflight_ip_tools.py --require-eda | exit 0 | Python/exporter 包完整；VCS/URG/SpyGlass/DC 可定位；vcformal 不在 PATH |
| 原始工作区 audit | 1 error / 9 warning | 9 个模型缺失，生成 CSR 条件断言触发文本筛查；详见 document_review.md |
| owner extract_requirements.py | 每册更新后 exit 0 | `lrs_extraction.log`，最终 `model/requirements.yaml` |
| LRS 作者检查 | 15 项结构/来源检查通过 | `lrs_check.json` / `lrs_check.md`，139 条需求、35 文件、原 109 编号全覆盖 |
| evaluate_quality.py --fail-on-gate | **exit 2**，未通过全流程门禁 | `../quality/gate_report.md` / `../../model/quality.yaml` |
| make check | exit 0 | `workflow_check.log`，125 项工作区测试执行通过 |
| pre-commit run --all-files | exit 0 | `workflow_precommit.log` |

## 机器检查与冻结的区别

当前 evaluator 的 G0 检查只验证 LRS Markdown 头和 requirements model，因此机器报告
显示 G0 pass；它没有核对 LRS_GATE_META 的真实评审/requirement_freeze。
规范需求模型仍明确保持 G0 open、requirement_freeze=false。**不能借此机器检查范围
不足跳过真实冻结**。G1 fail，G2–G5 blocked；所有状态以报告原文和实际证据为准。

## 复现 LRS 抽取

在 workflow 根目录、根 uv 环境运行：

```bash
uv run --locked python .roo/skills/ip-development-suite/skills/01-lrs-author/scripts/extract_requirements.py \
  --lrs-dir repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/docs/lrs \
  --output repos/aixsilicon_ip_repo/ips/peripheral/timer/watchdog/model/requirements.yaml \
  --ip-name watchdog
```

抽取只生成 canonical 投影，不执行审批。内容变化须重建来源哈希及对应下游证据。

## 后续交接

待真实 G0 需求评审结论后，继续参数合同/配置空间，然后重整 HLD、LLD 和 VPLAN。
每阶段按规则分册、抽取和核对引用，技术冻结独立记录；依赖阶段前置未满足时不
生成虚构模型或用旧 RTL/UT 结果补签。未提交 Git、未推送、未发布。
