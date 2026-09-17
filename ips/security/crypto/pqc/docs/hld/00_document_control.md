# PQC 加速器高层设计：文档控制

<!-- HLD_DOC_META
schema_version: '2.0'
ip_name: pqc
ip_display_name: 可配置 ML-KEM + ML-DSA 后量子密码加速器
delivery_model: parameterized
lrs_baseline: PQC-20260916-WORKKEY
document_version: 1.1.0
status: reviewed
architecture_baseline: PQC-HLD-1.1.0
END_HLD_DOC_META -->

## 设计输入

| 输入 | Baseline | 状态 |
|---|---|---|
| LRS（`docs/lrs/`，84 条需求） | `PQC-20260916-WORKKEY` | 用户确认 G0，机器 PASS |
| 参数合同（`model/parameter_space.yaml`，9 参数） | 同上 | extracted |
| FIPS 203 / FIPS 204 / SP 800-227 | final | frozen basis |
| 原始契约 `pqc_contract.md` SHA-256 | `4bd5e557b56f644ac7a5ee625b663bc9bfa4da80c3e95f853b185eca99ed1b89` | 只读输入 |

## 架构目标

| ID | 目标 | 需求来源 |
|---|---|---|
| HLD.GOAL.PQC.001 | 算法合规优先，字节级符合 FIPS 203/204 | LRS.FUNC.PQC.KEM_*、LRS.FUNC.PQC.DSA_* |
| HLD.GOAL.PQC.002 | 秘密不离开安全边界，常数时间无 oracle | LRS.SEC.PQC.CT.*、LRS.FUNC.PQC.KEM_DECAPS.* |
| HLD.GOAL.PQC.003 | 统一控制面 + 共享计算底座 + 算法专用 sequencer | LRS.FUNC.PQC.CMD.* |
| HLD.GOAL.PQC.004 | 参数化档位共享同一 ABI 与结果 | LRS.CFG.PQC.* |
| HLD.GOAL.PQC.005 | PPA 可优化的双模数据路径与 bank 化 SRAM | LRS.PERF.PQC.* |
| HLD.GOAL.PQC.006 | 故障与零化路径独立于主数据路径 | LRS.SEC.PQC.ZEROIZE.001、LRS.RESET.PQC.SAFE.001 |

## 架构原则

1. **Requirement Traceable**：每个 L1 模块与关键流均可追踪到 LRS。
2. **Shared Datapath, Dedicated Sequencing**：Keccak/NTT/Codec/Sampler 为共享底座，
   ML-KEM 与 ML-DSA 各自序列控制，避免两套重复运算单元。
3. **No Runtime Modulus**：模数与根为综合期常量 ROM，运行时仅选择标准参数集。
4. **Streaming Matrix**：矩阵逐 polynomial 生成/使用/释放，不常驻整矩阵。
5. **Safety Path Independent**：zeroize/tamper/fatal 路径不依赖主 FSM 正常运行。
6. **Verification Friendly**：公开状态可控制可观察，秘密状态不可观测。

## HLD / LLD 边界

本 HLD 冻结 L1 模块划分、接口组、时钟/复位/电源域、寄存器架构、控制与调度策略、
性能预算与关键架构决策。**不含** signal 级端口、FSM 状态编码、pipeline 拍数、
FIFO 指针、synchronizer 电路与 bit 级寄存器字段。这些由 `05-lld-microdesign` 承接。

## 阶段状态

`status: reviewed`（作者自校验完成）。G1 门禁见 [`99_quality_gate.md`](99_quality_gate.md)，
保持 `open`；未提供独立人类评审结论，不代填审批。

## 本轮架构恢复

G0 依据用户“确认，请继续”记录于 `docs/reviews/g0_authorization.md`，并通过 evaluator。
HLD 仍为待审架构，不能沿用历史清单的 PASS 宣称；本轮重建模块责任、专用密钥接口、
算法流、提交/取消、存储生命周期与可分析的带宽上界。性能按代码结构与周期预算分析，
不进行物理 PPA 表征。参数契约已由 19 重新抽取并校验为 9 参数、3 命名配置、15 支持点。
