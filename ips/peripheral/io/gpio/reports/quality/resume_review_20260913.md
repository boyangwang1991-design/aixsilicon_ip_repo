# GPIO 全流程恢复检查（2026-09-13）

执行模式为 ip-development-suite full-flow。完整流程尚未完成；以当前
`gate_report.md` 和 `model/quality.yaml` 为准，不沿用旧摘要中的上游 PASS。

## 本次完成的核查

- registry 指向 `ips/peripheral/io/gpio`，版本为 0.1.0。
- 与历史 `execution_state.json` 的逐文件 SHA-256 比较，45 份 LRS 和 33 份 HLD
  均与历史委托批准基线一致。
- 当前 owning LRS extractor 成功重新生成 `model/requirements.yaml`，补入来源指纹；
  未修改需求正文、设计 Gate 或审批状态。
- 当前 evaluator 重算 G0–G5。G0 缺少新版要求的输入绑定 approval；G1–G5 被上游阻塞。
- 工作区审计发现原生 PeakRDL CSR 的两条断言位于 `ifndef SYNTHESIS` 内；
  当前审计仍报 embedded-assertion。保留原生成物，未手改派生 RTL 或宣称审计通过。
- PATH 中找到 VCS/vlogan、SpyGlass、Design Compiler；未找到 vc_formal/vcf。
  此项仅为命令发现检查，不代表许可证可用或完整安装扫描。

## 待批准的具体操作（未执行）

将现有 GPIO 设计阶段委托授权迁移到当前套件的输入绑定格式：

1. 在 `docs/reviews/{lrs,hld,lld}_authorization.md` 记录既有授权原文、适用阶段与限制。
2. 逐阶段完成实际校验后，在对应 Markdown Gate 的 `approval` 下填写
   `kind: user_delegated`、执行 Agent 身份、实际时间、授权文件 SHA-256 和输入指纹。
3. 仅通过 owning extractor 重建派生模型，再由 evaluator 重新判定门禁。
   不把自动审批解释为独立人类评审，不代替 EDA、CDC/RDC、formal、覆盖率、PPA 或发布证据。

当前 LRS 待批准输入指纹（由 design_provenance.py 只读计算）：

`9c7aeafa3e71d26c5d29cf7f95837e0d655740ce2a4243ec92d9041a36a1ed57`

HLD/LLD 指纹须在上游审批和模型重建后重新计算，以包含真实上游状态。
历史授权原文分别为 `automatically approve the lrs for me later;` 和
`approve, complete the rest`，来源为工程已有记录。

自动审批审核拒绝了上述审批迁移脚本，理由是本次继续流程指令未明确授权
修改治理审批元数据。脚本未执行，`docs/reviews/` 未创建；本报告不是审批记录。

## 恢复审批后仍需完成

- G2：更新 CSR 来源/输出集合清单并重跑真实编译，核验 LLD 当前来源与审批。
- G3：全模块 UT 输入快照与覆盖映射、FuseSoC lint/elab/synth 真实执行清单，
  告警闭环和 CDC/RDC 签核；排查 CSR 审计问题。
- G4：UVM testcase/RM/checker、smoke/完整回归、硬件参数验证、覆盖率与 RTM，
  formal 及 RAL 交接证据。
- G5：集成/用户文档、真实 PPA、证据保留与发布检查。

旧 full_process.md/execution_state.json 保留为历史恢复材料，其时间和哈希不代表本次通过。
未提交、推送、上传 HTML 或发布归档。
