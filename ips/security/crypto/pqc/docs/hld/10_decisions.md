# PQC 加速器高层设计：架构决策与约束

### HLD.DECISION.PQC.DUALMODE

<!-- HLD_DECISION_META
id: HLD.DECISION.PQC.DUALMODE
title: 单一双模多项式引擎而非双引擎
status: decided
req_ref:
- LRS.CFG.PQC.NTT_LANES.001
- LRS.PERF.PQC.LATENCY.001
decision: 用统一 32 bit 物理蝶形承载 q=3329 与 q=8380417 两个域，lane 数可综合配置
rationale: KEM 与 DSA 不会同时执行（单上下文模型），共享引擎面积显著低于双引擎；
  统一 ABI 与结果不受 lane 数影响
alternatives:
- 双独立引擎（面积大、验证成本高）
- 仅 DSA 引擎 + 软件 KEM（违反 LRS.PERF.PQC.NOSW.001）
consequences:
- 常量 ROM 必须按算法切换且经生成与审计
- lane=1 时需保证时序仍可闭合
END_HLD_DECISION_META -->

### HLD.DECISION.PQC.STREAMMAT

<!-- HLD_DECISION_META
id: HLD.DECISION.PQC.STREAMMAT
title: 矩阵流式生成不常驻
status: decided
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.CFG.PQC.LOCAL_SRAM.001
decision: A_hat / A^T_hat 逐 polynomial 生成、使用、释放
rationale: 最大 k×l 矩阵常驻需要远超 LOCAL_SRAM_KIB 的空间；流式生成配合页生命周期
  复用使 32 KiB 档位可行
alternatives:
- 常驻整矩阵（排除 32 KiB SKU）
consequences:
- ExpandA 需要按 (i,j) 域分离并可重放
- 需要严格的页 tag 与 representation 检查
END_HLD_DECISION_META -->

### HLD.DECISION.PQC.SCA1

<!-- HLD_DECISION_META
id: HLD.DECISION.PQC.SCA1
title: V1.0 产品化默认 SCA Level 1
status: decided
req_ref:
- LRS.CFG.PQC.SCA_LEVEL.001
decision: V1.0 产品化至少 Level 1；Level 2 作为可选综合参数保留
rationale: Level 1 可在不引入 masking 复杂度的前提下满足产品基线；Level 2 需要
  masking scheme 与 fresh randomness 预算，显著改变 Keccak/NTT/SRAM/随机数带宽，
  必须单独安全评审后才能宣称
alternatives:
- 强制 Level 2（超出 V1.0 验证能力）
- 仅 Level 0（不满足产品基线）
consequences:
- Level 2 声明必须在 VPLAN 中有 TVLA/CPA/EMA 计划
- 随机数预算按 Level 1 冻结
END_HLD_DECISION_META -->

### HLD.DECISION.PQC.ATOMIC

<!-- HLD_DECISION_META
id: HLD.DECISION.PQC.ATOMIC
title: Sign 候选签名采用不可见 staging + 原子 commit
status: decided
req_ref:
- LRS.FUNC.PQC.DSA_SIGN.002
decision: 候选签名写入不可见 staging buffer，全部检查通过后一次性 commit
rationale: 拒绝轮次必须不产生任何部分 z/h；与 DMA 的 STAGE 接口把原子性变成接口契约
alternatives:
- 直接写输出 buffer 后回滚（存在部分结果可见窗口）
consequences:
- 需要 staging 容量等于最大签名长度 4627 B
- DMA 需要支持 commit 语义
END_HLD_DECISION_META -->

### HLD.DECISION.PQC.SHADOW

<!-- HLD_DECISION_META
id: HLD.DECISION.PQC.SHADOW
title: 命令配置采用 shadow + transactional commit
status: decided
req_ref:
- LRS.FUNC.PQC.CMD.002
- LRS.FUNC.PQC.CMD.004
decision: descriptor 相关配置在门铃后原子抓取到 shadow registers
rationale: 满足"抓取后软件修改内存不得影响当前命令"与 BUSY 锁定语义
alternatives:
- write-through（无法保证抓取原子性）
consequences:
- 需要 descriptor shadow 存储与 CRC/ABI 校验
END_HLD_DECISION_META -->

### HLD.DECISION.PQC.ZEROPATH

<!-- HLD_DECISION_META
id: HLD.DECISION.PQC.ZEROPATH
title: zeroize 路径独立于主 FSM
status: decided
req_ref:
- LRS.SEC.PQC.ZEROIZE.001
decision: zeroize/lock 由 pqc_fault_ctrl 独立驱动，不依赖主时序状态机正常运行
rationale: 主 FSM 可能已被故障破坏；若 zeroize 依赖它则无法保证有界完成
alternatives:
- 主 FSM 内实现 zeroize 状态（安全性依赖 FSM 正确性）
consequences:
- 需要独立的清零计数器与完成信号
- 需要形式验证"从任意状态有界完成"
END_HLD_DECISION_META -->

### HLD.DECISION.PQC.NOSG

<!-- HLD_DECISION_META
id: HLD.DECISION.PQC.NOSG
title: V1.0 仅线性 buffer，不实现 scatter-gather
status: decided
req_ref:
- LRS.INTF.PQC.DMA.003
decision: V1.0 支持线性 buffer 与分段连续区间；SG 列表作为增强项保留在 capability
rationale: SG 显著增加地址校验与侧信道分析面；线性 buffer 已满足安全启动与 TLS 场景
alternatives:
- V1.0 实现完整 SG（扩大验证面）
consequences:
- capability 必须准确报告 SG 不支持
- 分段等价性仍必须成立
END_HLD_DECISION_META -->

### HLD.CONSTRAINT.PQC.PPA_BUDGET

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.PQC.PPA_BUDGET
type: ppa
req_ref:
- LRS.PERF.PQC.LATENCY.001
statement: Balanced SKU（2 lane、64 KiB、2 rounds/cycle、Level 1）为目标 PPA 档位；
  Tiny SKU（1 lane、32 KiB、1 round/cycle）必须可综合并进行代码结构与周期预算分析
applies_to:
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.SRAM
END_HLD_CONSTRAINT_META -->

### HLD.CONSTRAINT.PQC.NORUNTIME_MODULUS

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.PQC.NORUNTIME_MODULUS
type: security
req_ref:
- LRS.CFG.PQC.ALGO_MASK.001
- LRS.CONS.PQC.CONST.001
statement: 不得提供运行时任意模数、根或安全敏感微码配置；常量来自综合期 ROM
applies_to:
- HLD.MOD.PQC.POLY
- HLD.MOD.PQC.DSASEQ
END_HLD_CONSTRAINT_META -->

### HLD.CONSTRAINT.PQC.NOSECRET_OBS

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.PQC.NOSECRET_OBS
type: security
req_ref:
- LRS.DFX.PQC.DEBUG.001
- LRS.SEC.PQC.CT.001
statement: 任何 debug/trace/perf 出口不得承载秘密或秘密相关细粒度事件
applies_to:
- HLD.MOD.PQC.FE
- HLD.MOD.PQC.FAULT
END_HLD_CONSTRAINT_META -->

### HLD.CONSTRAINT.PQC.NOSW_PRIM

<!-- HLD_CONSTRAINT_META
id: HLD.CONSTRAINT.PQC.NOSW_PRIM
type: architecture
req_ref:
- LRS.PERF.PQC.NOSW.001
statement: IP 不向普通软件暴露 primitive opcode；顶层仅暴露完整算法命令
applies_to:
- HLD.MOD.PQC.FE
END_HLD_CONSTRAINT_META -->

