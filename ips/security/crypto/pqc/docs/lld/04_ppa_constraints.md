# PQC 微架构 PPA 与派生约束（恢复中）

### LLD.PPA.PQC.POLY

<!-- LLD_PPA_META
id: LLD.PPA.PQC.POLY
module_ref: LLD.MOD.PQC.POLY
area_strategy: 每 lane 配置 23x23 乘法器，KEM 使用低 12 bit；Level 2 两算术 share 独立资源
timing_strategy: 乘法、三段约减、规范化和加减分级；按六 batch slot 调度，不以未测频率宣称路径达标
power_strategy: 按公开调度使能；两 share 对称活动，不使用秘密或 share 值门控
ppdg_target: 面积主导（Tiny）到吞吐主导（Throughput）
req_ref:
- LRS.PERF.PQC.LATENCY.001
applicability:
  expr: 'true'
END_LLD_PPA_META -->

### LLD.PPA.PQC.KECCAK

<!-- LLD_PPA_META
id: LLD.PPA.PQC.KECCAK
module_ref: LLD.MOD.PQC.KECCAK
area_strategy: 单 permutation 数据通路 + 双 context state（避免第二套 permutation）
timing_strategy: Level 0/1 的 r=2 串接两轮路径；Level 2 单轮寄存隔离，不串接 masked chi
power_strategy: 按公开轮 FSM 使能 permutation；计算不依赖 absorb/squeeze 同拍 valid
ppdg_target: Level 0/1 轮展开与组合深度权衡；Level 2 包含 gadget 寄存和随机带宽代价
req_ref:
- LRS.PERF.PQC.OVERLAP.001
- LRS.CFG.PQC.KECCAK_ROUNDS.001
applicability:
  expr: 'true'
END_LLD_PPA_META -->

### LLD.PPA.PQC.SRAM

<!-- LLD_PPA_META
id: LLD.PPA.PQC.SRAM
module_ref: LLD.MOD.PQC.SRAM
area_strategy: 每 share 8 bank，数据 32 bit 加 ECC；Level 2 镜像，32 KiB 逻辑档位按页复用
timing_strategy: bank 仲裁为单周期确定性决策，避免长组合路径
power_strategy: 未访问 bank 门控；zeroize 期间全 bank 使能
ppdg_target: 面积与最大工作集约束的平衡点
req_ref:
- LRS.CFG.PQC.LOCAL_SRAM.001
- LRS.FUNC.PQC.KEM_DATAFLOW.001
applicability:
  expr: 'true'
END_LLD_PPA_META -->

## 派生需求与设计决策

### LLD.DERIVED.PQC.LAZY

<!-- LLD_DERIVED_META
id: LLD.DERIVED.PQC.LAZY
statement: 保留旧 ID 追踪；取消跨乘积 lazy 累加，每次乘加规范化到 [0,q)。中间约减范围按 POLY 分级证书验证。
derived_from:
- HDR.PQC.LAZY_RANGE.001
status: proposed
END_LLD_DERIVED_META -->

### LLD.DERIVED.PQC.BANKHASH

<!-- LLD_DERIVED_META
id: LLD.DERIVED.PQC.BANKHASH
statement: bank 三位分别为 i0^i3^i6、i1^i4^i7、i2^i5；row=i[7:3]。各 power-of-two 蝶形和 1/2/4 lane 调度按模型枚举。
derived_from:
- HDR.PQC.BANK_CONFLICT.001
status: proposed
END_LLD_DERIVED_META -->

### LLD.DERIVED.PQC.KCTX

<!-- LLD_DERIVED_META
id: LLD.DERIVED.PQC.KCTX
statement: 实现两个 Keccak context（CTX_MSG、CTX_XOF），仅一套 permutation 数据通路，
  block 边界切换；同一 context 不被抢占
derived_from:
- HDR.PQC.KECCAK_CTX.001
status: proposed
END_LLD_DERIVED_META -->

### LLD.DECISION.PQC.DEFERRED_COMMIT

<!-- LLD_DECISION_META
id: LLD.DECISION.PQC.DEFERRED_COMMIT
decision: 候选签名先在 staging buffer 中完成全部格式检查与长度确定，再一次性 DMA commit
rationale: 拒绝原因及候选签名不外露，总尝试次数影响总时延；最大签名 4627 B 占五个逻辑页
alternatives:
- 边算边写输出（存在部分结果可见窗口）
consequences:
- staging 容量固定
- DMA commit 需要单调完成信号
req_ref:
- LRS.FUNC.PQC.DSA_SIGN.002
END_LLD_DECISION_META -->

### LLD.DECISION.PQC.REDUCE_SCHEDULE

<!-- LLD_DECISION_META
id: LLD.DECISION.PQC.REDUCE_SCHEDULE
decision: 约减采用固定位置插入而非数据相关分支
rationale: 数据相关分支会引入秘密相关时序
alternatives:
- 数据相关条件约减（简单但非常数时间）
consequences:
- 需要逐级约减的同余及位宽证明；不允许跨乘积隐式 lazy 范围
req_ref:
- LRS.SEC.PQC.CT.001
END_LLD_DECISION_META -->

## 验证钩子

### LLD.VHOOK.PQC.BANK

<!-- LLD_VERIFY_HOOK_META
id: LLD.VHOOK.PQC.BANK
design_ref: LLD.DERIVED.PQC.BANKHASH
concern: bank 冲突是否被静态消除
suggested_check: 断言同一 cycle 的 a/b bank 不同；冲突时 stall 为确定性
req_ref:
- LRS.PERF.PQC.LATENCY.001
END_LLD_VERIFY_HOOK_META -->

### LLD.VHOOK.PQC.CT

<!-- LLD_VERIFY_HOOK_META
id: LLD.VHOOK.PQC.CT
design_ref: LLD.SAFE.PQC.CT_SELECT
concern: 秘密是否影响可观察行为
suggested_check: 形式 taint 分析；KEM valid/invalid 的公开 trace 与周期分布一致
req_ref:
- LRS.SEC.PQC.CT.001
- LRS.FUNC.PQC.KEM_DECAPS.002
END_LLD_VERIFY_HOOK_META -->

### LLD.VHOOK.PQC.ATTEMPT

<!-- LLD_VERIFY_HOOK_META
id: LLD.VHOOK.PQC.ATTEMPT
design_ref: LLD.FSM.PQC.DSASEQ.ATTEMPT
concern: 拒绝轮次输出不可见性与上限行为
suggested_check: 强制 0/1/多次拒绝；验证 A_EXHAUST 无输出
req_ref:
- LRS.FUNC.PQC.DSA_SIGN.002
END_LLD_VERIFY_HOOK_META -->