# GPIO 全流程当前状态

本次已按用户“请继续，本次运行不需要额外人工审核”的授权继续执行。设计审批记录为
用户委托审批，不冒称独立人类评审。全流程尚未完成，当前被 CDC/RDC 高级许可证阻塞。
机器结果见 [gate_report.md](gate_report.md)，本次状态见
[resume_execution_state.json](resume_execution_state.json)。旧 execution_state.json 保留为历史记录。

| 阶段 | 当前结果 | 主要证据 |
|---|---|---|
| G0 / LRS | pass；258 项需求，来源及审批输入绑定有效 | model/requirements.yaml、docs/reviews/lrs_authorization.md |
| G1 / HLD | pass；当前架构/接口模型已重建 | model/architecture.yaml、docs/reviews/hld_authorization.md |
| G2 / LLD、寄存器 | pass；753 实例、110 字段模板；当前 CSR/adapter 真编译通过 | register_check.md、reports/registers/contract_structure.json |
| 参数合同 | 269 项 Schema 检查通过；不是硬件参数验证 | parameter_semantics.json |
| RTL/Core/CSR 一致性 | pass；修复包 vendor/library 与 Core 生成同步 | gate_report.md 的 G3 子检查 |
| 模块单测 | 当前最终输入 13/13 pass，包含生成的 CSR ACK bind checker | module_ut_summary.md |
| lint / elab / synth | 三项通过；含实际执行前后输入快照 | rtl_check_summary.md |
| CDC | fail；部分规则因 cdc_adv_checker 缺失未执行 | review_findings.yaml、build/rtl/resume_cdc_02.log |
| RDC | fail；缺少 cdc_adv_checker、rdc_adv_checker | review_findings.yaml、build/rtl/resume_rdc_01.log |
| 静态追踪 | 258 req→HLD、12 HLD→LLD、12 LLD→RTL、382 req→test 链接 | trace_matrix.md（precheck） |
| G3 | fail；普通 RTL 检查和 UT 已通过，专项签核未通过 | gate_report.md |
| G4 / G5 | blocked；UVM、硬件参数回归、覆盖率、最终 RTM、文档与发布待完成 | gate_report.md |
| 原始证据保留 | 46 个文件已校验并按内容哈希保留 | reports/evidence/index.json |

## 实现与工具修复

- 由生成器将 PeakRDL 的两条仿真 ACK 检查移入 verification/assertions/；
  对照原生输出确认可综合逻辑不变，工作区审计为 0 错误、0 告警。
- 修复 SpyGlass waiver 通配符格式，保留 4067 条原始告警的分类/范围；
  本轮 lint 报告为 0 错误、0 未豁免告警。编码风格豁免不覆盖 CDC/RDC。
- 再生包含 CDC/RDC target 的 Core；模块 UT 补齐完整输入快照和全部 14 个 RTL 模块的覆盖映射。
- CBB 仍通过 FuseSoC depend 引用；仅在被忽略的 build/cbb_adapter 物化未修改的依赖源码并绑定来源哈希。
- 生成真正的 UVM RAL package 和 manifest；未宣称其环境接入或寄存器测试完成。
- 套件修正 DC 告警中引用 $error/名为 error 的字段被误判为执行错误的问题，
  并修正未引用历史快照被当成当前证据根的问题；对应正负向回归通过。

## 物理与 Formal 边界

真实综合使用 N_GPIO=8、28nm HVT TT 1.00V/25°C 库和既有 characterization SDC。
原始 area/timing/power/网表均在 build/rtl/resume_synth_02/；该单点综合仅支持
当前 G3 检查，不能替代参数空间 PPA sweep 或最终 SoC 物理签核。

扩展搜索定位到 VCS W-2024.09-SP1/vcfca/bin/vcf。设置 VC_STATIC_HOME 为 vcfca 根，
并在 LD_LIBRARY_PATH 中加入同版本 Verdi platform/linux64/lib/Qt5/lib 后，FPV
启动及 help check_fv 成功。见 build/formal/preflight/console02.log。
这是环境探测，GPIO 属性证明尚未执行。

## 继续条件与验证

需由合法许可证环境提供 cdc_adv_checker 和 rdc_adv_checker，再重跑完整 CDC/RDC
目标并处理全部结果；不能跳过未运行的规则或把静态审查代替专项 PASS。通过 G3 后
继续 UVM/硬件参数验证/覆盖率/正式属性证明，再做文档、PPA 签核与发布。

已完成工作区 make check、pre-commit、IP 套件完整脚本回归及本次证据保留修复的
定向回归；套件结构复核为 24 skills、0 errors、0 warnings。
未提交、推送、上传 PeakRDL HTML 或生成正式发布包。
