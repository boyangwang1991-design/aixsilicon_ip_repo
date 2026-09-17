# PQC 加速器逻辑详细设计：文档控制

<!-- LLD_DOC_META
schema_version: '2.0'
ip_name: pqc
ip_display_name: 可配置 ML-KEM + ML-DSA 后量子密码加速器
delivery_model: parameterized
lrs_baseline: PQC-20260916-WORKKEY
hld_baseline: PQC-HLD-1.1.0
document_version: 1.1.0
status: draft
microarchitecture_baseline: PQC-LLD-1.1.0
END_LLD_DOC_META -->

## 设计输入

| Input | Baseline | Status |
|---|---|---|
| LRS（84 需求） | `PQC-20260916-WORKKEY` | reviewed |
| HLD（13 L1 模块） | `PQC-HLD-1.1.0` | reviewed |
| 参数合同（9 参数） | `model/parameter_space.yaml` | extracted |
| FIPS 203 / 204 / SP 800-227 | final | frozen basis |

## LLD 设计原则

1. **HLD Consistent**：不改变冻结的 L1 划分、接口组、寄存器架构与策略。
2. **Cycle Defined**：关键事务给出确定 cycle 行为与 stall 条件。
3. **No Hidden State**：所有影响结果的中间状态显式建模（含 representation 与 page tag）。
4. **Error Complete**：错误与恢复路径与正常路径同等详细。
5. **Configuration Aware**：每个参数对微架构的影响显式记录。
6. **PPA Conscious**：每个微架构选择给出 PPA 取舍理由。
7. **RTL Mappable**：所有设计点映射到 `RTL_MAP_META`。

## 阶段状态

G0/G1 已通过当前输入绑定检查；本轮从冻结 HLD 恢复 LLD，状态保持 draft。
旧文档的“字段行为已冻结”和 PASS 清单不再作为批准依据。G2 保持 open，
寄存器行为需要按当前密钥/提交/错误合同重新审查；结构由 SystemRDL 承载。
后续决策按用户委托推进，实际校验未通过的对象不冻结。
