# APB Secure Demux 统一结论报告

G0–G3 通过；完整覆盖率经用户授权暂缓，其他 G4 缺项仍待闭环，G5 阻塞。

适用对象为本工作区 apb_secure_demux 1.0.0、CFG_TYPICAL_DIRECT。2026-09-14 本轮重新生成设计模型、参数矩阵和 CSR 检查，并实际执行 SpyGlass X-2025.06、VCS W-2024.09-SP1、DC V-2023.12-SP3。历史审批通过保留的原始记录及输入清单核验；这不代表新增人工审批。

| Gate | 状态 | 本轮范围及缺口 |
|---|---|---|
| G0 | pass | 37 份 LRS、169 条需求及参数模型 |
| G1 | pass | HLD 追踪及审批输入核验 |
| G2 | pass | LLD、寄存器结构与原生 CSR 编译检查 |
| G3 | pass | lint/elaboration/synthesis 和 10/10 模块 UT；综合零 unmapped、零 latch |
| G4 | fail | 典型 DIRECT、seed=42 的 17/17 UVM 用例通过；三个静态检查、RAL 交接、配置矩阵、RTM 和形式证据仍缺失。覆盖率按用户授权暂缓。 |
| G5 | blocked | G4 未通过；四点 PPA、系统签核及交付门禁未闭环 |

单点综合仅作 G3 可综合性检查，不能替代四点 PPA。lint warning 未做全面豁免，历史分类审查位于本地 build/reports/quality/lint_warning_review.md；reset 信任条件并入 CR-005。

| ID | 状态 | 问题 / 影响 | Owner / 下一步 |
|---|---|---|---|
| F-G4-001 | open | 静态用例、RAL 交接、RTM 与参数执行未闭环 | IP/VIP 验证维护者：补齐三个静态检查和 RAL 交接，执行配置矩阵回归并关闭 RTM。 |
| F-FORMAL-001 | open | 四项安全性质尚无全支持范围的形式证明 | IP/VIP 验证维护者：提供可用形式工具并执行非空证明，或完成可审计的参数化穷尽证明。 |
| CR-004 | open | 受控 IHI0024 版本审查证据缺失 | 集成方：集成方提供受控版本及协议审查证据。 |
| CR-005 | open | 实际 SoC/X2P 身份绑定、路径、reset/DFX 信任证据缺失 | 集成方：集成方提供当前实例及跨缓冲、仲裁、CDC 的关联证据。 |
| F-PPA-001 | open | 四点 PPA 和产品约束尚未闭环 | IP/VIP 验证维护者：执行典型/最大、DIRECT/REGISTER 四点表征并核对产品约束。 |
| F-VIP-001 | open | APB VIP 仍为预集成候选 | IP/VIP 验证维护者：保留 qualification 缺口，取得 VIP owner 的正式闭环证据。 |

继续完成静态检查、RAL 交接、配置矩阵、形式和系统证据、四点 PPA及最终交付检查；完整覆盖率不再单独阻止后续推进。复现入口见 [README](../README.md)；机器证据和原始日志只保留在本地 build/，新工作区需重新生成。

本批运行：lint_1789378574109910857、elab_1789378556048442705、synth_1789378555191282344；UT batch_1789378530885904670；UVM batch_1789378522964290525。EDA 执行使用冻结套件副本 v2；覆盖率条件由本轮测试通过的 canonical evaluator 评估，原始检查结果保留。

2026-09-14：修复 REQ-APB-005 的空闲/SETUP PREADY，并补充检查；修正 checker 的等待周期数据判断。17 个 UVM 用例通过不代表全部 VPLAN 场景或全参数范围已覆盖。依赖 parity_gen_check 的 delta-cycle 断言误报已局部修复，通过 42 组合 × 1024 向量及故意错误检测；没有提升其发布资格。

RAL 已从 SystemRDL 生成，并在先编译 UVM 库后实际编译通过（build/sim/run/ral/1789379024981001782）；frontdoor、predictor 和交接证据仍需完成。URG 覆盖汇总两次均在许可证初始化调用栈崩溃，日志位于 build/reports/coverage/typical_direct_1789378522964290525；没有虚构覆盖率数值。

用户于 2026-09-14 明确授权：“如果是覆盖率一直无法通过，可以pass with condition; 先不收完整覆盖率”。条件 C-COV-001 仅暂缓 g4.coverage_closure；Owner 为 IP 验证维护者，关闭要求为恢复工具后完成各配置覆盖分析及缺口关闭。门禁保留覆盖检查失败和用户原话哈希；其他 G4 检查通过后才能转为 pass_with_condition。此授权不豁免实际功能失败、形式证明、系统信任或 PPA。

<!-- IP_REPORT_METADATA
schema_version: '1.0'
report_type: ip_summary
ip_name: apb_secure_demux
status: blocked
conclusion: G0–G3 通过；完整覆盖率经用户授权暂缓，其他 G4 缺项仍待闭环，G5 阻塞。
gates:
  G0: pass
  G1: pass
  G2: pass
  G3: pass
  G4: fail
  G5: blocked
findings:
- id: F-G4-001
  status: open
  summary: 静态用例、RAL 交接、RTM 与参数执行未闭环
  next_action: 补齐三个静态检查和 RAL 交接，执行配置矩阵回归并关闭 RTM。
- id: F-FORMAL-001
  status: open
  summary: 四项安全性质尚无全支持范围的形式证明
  next_action: 提供可用形式工具并执行非空证明，或完成可审计的参数化穷尽证明。
- id: CR-004
  status: open
  summary: 受控 IHI0024 版本审查证据缺失
  next_action: 集成方提供受控版本及协议审查证据。
- id: CR-005
  status: open
  summary: 实际 SoC/X2P 身份绑定、路径、reset/DFX 信任证据缺失
  next_action: 集成方提供当前实例及跨缓冲、仲裁、CDC 的关联证据。
- id: F-PPA-001
  status: open
  summary: 四点 PPA 和产品约束尚未闭环
  next_action: 执行典型/最大、DIRECT/REGISTER 四点表征并核对产品约束。
- id: F-VIP-001
  status: open
  summary: APB VIP 仍为预集成候选
  next_action: 保留 qualification 缺口，取得 VIP owner 的正式闭环证据。
- id: C-COV-001
  status: open
  summary: 完整覆盖率按用户明确授权暂缓；技术覆盖未签核
  next_action: 由 IP 验证维护者恢复工具后完成各配置覆盖分析及缺口关闭。
evidence:
- path: build/reports/quality/quality.yaml
  sha256: 10783a23f451ad0a5c17952ed538ed1f648dbb2217f996291d040e56bd6ae6b5
END_IP_REPORT_METADATA -->
