# Watchdog：G1 风险与交接检查

<!-- HLD_GATE_META
gate: G1
status: pass
architecture_freeze: true
approvals:
- source: user
  input: "approve, complete the rest"
  evidence: reports/full_flow/g1_approval.md
END_HLD_GATE_META -->

本基线已获用户明确批准，G1 冻结记录见 reports/full_flow/g1_approval.md。
后续进入 LLD；下表仍保留实现与验证阶段需要取得的证据。

| 风险 | 处置/后续证据 | 当前状态 |
|---|---|---|
| 最大通道/客户端规模的原子快照与配置组合路径 | LLD 量化存储/组合路径，真实多配置 elab/synth/timing | 待执行 |
| 域复位及 warm 到达同步链中的在途请求 | LLD 冻结 cancel/epoch 逻辑，CDC/RDC 与相位扰动验证 | 待执行 |
| DIAG_INJECT_EN=1、SAFETY_EN=0 能力/拒绝语义 | 保留合法构建空间，仅允许实际检测对象注入；能力/错误返回需 G1 审查并在 LLD/RTL 对齐 | 待评审 |
| 旧 CSR 源文本审计命中条件断言 | 核对 SYNTHESIS 宏预处理与实际商业工具；不手改生成源码 | 待 G3 核验 |
| CBB core 元数据与已装 FuseSoC 不兼容 | 以 owner 修复或记录的临时 metadata 适配完成真实解析 | 待 G3 核验 |
| APB VIP qualification 未闭合 | 预备复用并完成 IP 所需精确协议范围证据，不能以未发布标签自证 | 待 G4 核验 |
| 原生 APB 接口与现有 HWIF profile 不直接匹配 | 使用基础契约明确 15 位地址/PPROT 绑定；不宣称 CSR profile 兼容，集成端防地址别名 | 待 LLD 绑定 |
| 实际工艺/库/corner 与冗余综合保留尚未证实 | 三配置真实 PPA、综合网表诊断与防合并检查 | 待 G5 核验 |
| 外部时钟/电源/复位/身份可信性 | 集成手册和系统安全假设独立列明，IP 不宣称覆盖系统共因 | 系统责任 |

## 作者检查要求

- 单文档头/单 Gate，平铺语义分册和完整索引；没有 HLD 越界的 RTL 文件映射或位表。
- 139 条需求逐项有合理 L1 owner，16 参数都有架构影响对象，内外接口分开。
- clock/reset/power/CDC、模块接口、flow participants、保护对象和配置引用闭合。
- PC 当前模型/语义报告与 HLD 输入一致，原始抽取日志及文件哈希可复核。
- 本表中后续 EDA/PPA/协议证据未执行项仍保留，不能因此删掉 required 交付或写 PASS。
