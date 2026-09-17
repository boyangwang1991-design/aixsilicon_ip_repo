# PQC LRS：安全与功能配置

### LRS.CFG.PQC.SCA_LEVEL.001 侧信道防护等级

<!-- LRS_META
id: LRS.CFG.PQC.SCA_LEVEL.001
category: CFG
feature: sca_level
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.2
applicability:
  expr: 'true'
verification_method:
- elaboration
- review
END_LRS_META -->

<!-- PARAM_META
name: SCA_LEVEL
type: int
category: compile_time
default: 1
domain: [0, 1, 2]
depends_on: []
description: 侧信道防护等级；0=常数时间基线，1=产品推荐基线，2=掩码高安全
END_PARAM_META -->

#### Requirement

`SCA_LEVEL` 应支持 `{0, 1, 2}`。V1.0 产品化配置应至少为 Level 1。若声明 Level 2，
应同时明确 masking scheme、share 数、fresh randomness 上界与 glitch 假设。

#### Acceptance Criteria

- Level 0/1 下常数时间与固定访问性质成立；
- 声明 Level 2 时掩码方案可被独立验证；
- 默认值为 1。

---

### LRS.CFG.PQC.ALGO_MASK.001 参数集裁剪位图

<!-- LRS_META
id: LRS.CFG.PQC.ALGO_MASK.001
category: CFG
feature: algo_mask
priority: P1
status: active
source_ref:
- pqc_contract.md#§2.1
- pqc_contract.md#§9.1
applicability:
  expr: 'true'
verification_method:
- elaboration
- simulation
END_LRS_META -->

<!-- PARAM_META
name: ENABLE_ALGO_MASK
type: int
category: compile_time
default: 63
domain: 1..63
depends_on: []
description: 六个参数集的裁剪位图；bit0..2=ML-KEM-512/768/1024，bit3..5=ML-DSA-44/65/87
END_PARAM_META -->

#### Requirement

`ENABLE_ALGO_MASK` 应以位图裁剪综合的参数集，且裁剪后 CAPABILITY 寄存器应准确反映
已实现的算法与参数集。V1.0 交付基线为全开（63）。

#### Acceptance Criteria

- 每个位组合的 CAPABILITY 与实际可执行命令一致；
- 对未综合的参数集命令返回配置错误而非未定义行为；
- 默认值为 63。

---

### LRS.CFG.PQC.FEATURE_FLAGS.001 可裁剪功能开关

<!-- LRS_META
id: LRS.CFG.PQC.FEATURE_FLAGS.001
category: CFG
feature: feature_flags
priority: P1
status: active
source_ref:
- pqc_contract.md#§9.1
applicability:
  expr: 'true'
verification_method:
- elaboration
- simulation
END_LRS_META -->

<!-- PARAM_META
name: ENABLE_HASH_ML_DSA
type: bool
category: compile_time
default: false
domain: [false, true]
depends_on: []
description: 是否综合 HashML-DSA 预哈希签名接口
END_PARAM_META -->

<!-- PARAM_META
name: ENABLE_PIO
type: bool
category: compile_time
default: true
domain: [false, true]
depends_on: []
description: 是否综合小数据 PIO FIFO 通道
END_PARAM_META -->

#### Requirement

`ENABLE_HASH_ML_DSA` 应控制 HashML-DSA 预哈希接口的综合；`ENABLE_PIO` 应控制 PIO FIFO
通道的综合。裁剪后 opcode 与 capability bit 应保留并报告为不可用。

#### Acceptance Criteria

- 关闭时对应 opcode 返回配置错误且 CAPABILITY 位为 0；
- 开启时功能与 pure ML-DSA 域分离一致；
- 默认值分别为 false 与 true。

---

### LRS.CFG.PQC.EXEC_MODE.001 单上下文执行模型

<!-- LRS_META
id: LRS.CFG.PQC.EXEC_MODE.001
category: CFG
feature: exec_mode
priority: P0
status: active
source_ref:
- pqc_contract.md#§4.2
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

V1.0 运行时执行模型应为单上下文：同一时刻最多一个执行中命令，允许一个 pending descriptor。
多队列并发不作为 V1.0 要求。

#### Acceptance Criteria

- BUSY 期间提交新命令按定义行为处理（拒绝或排队到单 pending）；
- 不存在两个命令同时占用密码数据路径；
- 多队列并发能力在 CAPABILITY 中报告为不支持。