# PQC 加速器验证方案

<!-- VPLAN_META
schema_version: '2.0'
ip_name: pqc
ip_display_name: 可配置 ML-KEM + ML-DSA 后量子密码加速器
delivery_model: parameterized
lrs_baseline: PQC-CONTRACT-36c592c3ffa1
hld_baseline: PQC-HLD-1.0.0
lld_baseline: PQC-LLD-1.0.0
document_version: 1.0.0
status: reviewed
verification_baseline: PQC-VP-1.0.0
END_VPLAN_META -->

## 验证范围

本方案覆盖全部 80 条 LRS 需求。验证手段按性质分工：

| 手段 | 覆盖对象 | 说明 |
|---|---|---|
| UVM 仿真 | 控制面、寄存器、中断、key slot、DMA 范围、复位/自检、故障锁定、zeroize | G3/G4 主要证据 |
| Module UT | Keccak、poly engine、codec、sampler、SRAM 控制器、fault ctrl | G3 固定步骤 |
| 形式/静态 | 常数时间 taint、有界完成、无越界、非法地址 | formal / static proof |
| 软件证明 | 算法级 KAT 与差分（Python 参考模型 + 独立实现交叉验证） | `proof_kind: software` |
| 评审 | 文档边界、安全手册、交付清单 | review |

**证伪规则**：Requirement 不能仅依靠覆盖率宣称 PASS。覆盖率只回答"场景是否触达"；
checker/assertion/formal/review 才回答"行为是否正确"。

## 算法级验证策略

完整 ML-KEM/ML-DSA 端到端算法正确性以**软件证明**承担（`proof_kind: software`）：

- Python 参考模型（`pqc_accel_model`）与两个独立实现（`kyber-py`/`dilithium-py` 与
  编译期 oracle）交叉验证 KEM KeyGen/Encaps/Decaps 与 DSA KeyGen/Sign/Verify；
- 六个参数集全覆盖；密文翻转、消息篡改、非法长度等负向场景；
- 该证明绑定可执行入口与输入哈希，不依赖 UVM 合成结论。

UVM 不承担完整算法端到端比对（避免伪造 PASS），而验证 RTL 控制面与接口契约。

## 形式与静态策略

- 常数时间：证明 secret-tainted 信号不控制错误码、DMA 地址与授权可见状态；
- 有界完成：zeroize 从任意状态在规定周期内完成；
- 无越界：DMA 地址窗口与 buffer 容量检查在写入前生效；
- 非法地址：APB 未映射地址返回 pslverr 且无副作用。

## 回归策略

- Smoke（fail-fast）：核心控制面最小闭环 6 项；
- Regression：全部可达 testcase；
- Extended：性能计数与非法访问等扩展项；
- 参数化分支：CFG_TINY / CFG_BALANCED / CFG_THROUGHPUT 三档；
- 必选配置类：DEFAULT / MIN / MAX / FEATURE_ON / FEATURE_OFF。

## 覆盖率策略

需求覆盖率 100%（全部 P0 均有 feature 承接）；功能覆盖率 100%（批准的不可达项除外）；
RTL line/toggle/branch/FSM 门限不低于 95%，安全关键 FSM 与 error path 100%。

## 阶段门禁

VPLAN 计划冻结使用 `VP0` 子门禁（见 [`99_quality_gate.md`](99_quality_gate.md)），
不冒充 G3/G4。G3/G4 由后续 RTL 检查、Module UT、回归与覆盖率证据支撑。