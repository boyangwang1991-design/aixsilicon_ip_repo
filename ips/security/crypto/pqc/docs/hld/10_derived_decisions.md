# PQC 派生约束与本轮决策

## 派生的架构约束

### HDR.PQC.BANK_CONFLICT.001

<!-- HLD_DERIVED_META
id: HDR.PQC.BANK_CONFLICT.001
type: derived_architecture_requirement
derived_from:
- LRS.PERF.PQC.LATENCY.001
- LRS.FUNC.PQC.KEM_DATAFLOW.001
statement: NTT 地址生成器必须保证同一 cycle 的 a/b 访问落在不同 bank，或在无法避免时
  产生确定性 stall；bank 冲突不得由 coefficient 值决定
status: proposed
END_HLD_DERIVED_META -->

### HDR.PQC.LAZY_RANGE.001

<!-- HLD_DERIVED_META
id: HDR.PQC.LAZY_RANGE.001
type: derived_architecture_requirement
derived_from:
- LRS.SEC.PQC.INTEGRITY.001
statement: 双模引擎的 lazy reduction 范围上限必须按最大 k=8 证明，并在超界前插入固定
  位置 reduction；范围证明由形式验证冻结
status: proposed
END_HLD_DERIVED_META -->

### HDR.PQC.KECCAK_CTX.001

<!-- HLD_DERIVED_META
id: HDR.PQC.KECCAK_CTX.001
type: derived_architecture_requirement
derived_from:
- LRS.PERF.PQC.OVERLAP.001
- LRS.FUNC.PQC.DSA_MU.001
statement: 需要至少两个 Keccak context（消息增量哈希 + 矩阵/采样 XOF），在 block 边界
  切换且同一 context 不被抢占
status: proposed
END_HLD_DERIVED_META -->

### HLD.DECISION.PQC.WORKKEY

<!-- HLD_DECISION_META
id: HLD.DECISION.PQC.WORKKEY
title: 外部长期所有权与内部单份工作态 Key RAM
status: decided
req_ref:
- LRS.SEC.PQC.SLOT.006
- LRS.SEC.PQC.SLOT.007
- LRS.SEC.PQC.SLOT.008
decision: 单个逻辑 8 KiB ECC 工作态材料区，Level 2 物理双 share 共 16 KiB，专用导入与仅新生成密钥的托管接口，普通总线无材料地址窗口
rationale: 满足用户指定边界；单上下文无需每 slot 复制最大私钥 RAM
alternatives:
- 每 slot 常驻完整私钥（不符合长期所有权边界且扩大存储）
- 普通 DMA 导入（用户明确禁止）
consequences:
- sequencer 必须接通授权材料读取，元数据不能替代材料
- KeyGen 成功提交须等待外部 Key Manager 明确确认
- 工作态副本退休不改变外部长期密钥所有权
END_HLD_DECISION_META -->

### HLD.DECISION.PQC.HASH_BUDGET

<!-- HLD_DECISION_META
id: HLD.DECISION.PQC.HASH_BUDGET
title: 保留 1/2 轮结构并采用可达周期预算
status: decided
req_ref:
- LRS.PERF.PQC.OVERLAP.001
- LRS.CFG.PQC.KECCAK_ROUNDS.001
decision: 64-bit rate 接口；Level 0/1 完整块预算 ceil(R/8)+24/r+2，Level 2 预算 ceil(R/8)+1896+2，按分级合同验收
rationale: 用户明确选择周期预算；单 sponge 受置换依赖限制，DMA 加宽不能使算法吞吐无限增加
alternatives:
- 保留总线峰值 50% 并增加轮数（用户未选择）
- 用 DUT 内部背压降低测试分母（无效验收）
consequences:
- byte RTL 接口需扩展；增加两 word 供数与尾字节 mask
- 当前算法周期目标仍须完整仿真核验，不能仅凭局部上界宣称达标
END_HLD_DECISION_META -->
