# PQC LRS：配置模型与用法

本 IP 的 `delivery_model = parameterized`。综合期参数决定面积/吞吐档位；运行时配置
只允许选择已综合存在的标准算法与参数集，禁止软件写入任意 q、根或安全敏感微码。

<!-- CONFIG_META
id: CFG_TINY
purpose: "Tiny SKU：MCU/安全启动，面积优先"
values:
  NTT_LANES: 1
  KECCAK_ROUNDS_PER_CYCLE: 1
  LOCAL_SRAM_KIB: 32
  DMA_DATA_WIDTH: 64
  KEY_SLOT_NUM: 8
  SCA_LEVEL: 1
END_CONFIG_META -->

<!-- CONFIG_META
id: CFG_BALANCED
purpose: "Balanced SKU：通用 SoC，V1.0 推荐"
values:
  NTT_LANES: 2
  KECCAK_ROUNDS_PER_CYCLE: 2
  LOCAL_SRAM_KIB: 64
  DMA_DATA_WIDTH: 128
  KEY_SLOT_NUM: 8
  SCA_LEVEL: 1
END_CONFIG_META -->

<!-- CONFIG_META
id: CFG_THROUGHPUT
purpose: "Throughput SKU：网关/服务器卸载"
values:
  NTT_LANES: 4
  KECCAK_ROUNDS_PER_CYCLE: 2
  LOCAL_SRAM_KIB: 96
  DMA_DATA_WIDTH: 256
  KEY_SLOT_NUM: 16
  SCA_LEVEL: 1
END_CONFIG_META -->

<!-- CONSTRAINT_META
- "LOCAL_SRAM_KIB >= 32"
- "KECCAK_ROUNDS_PER_CYCLE <= 2"
- "DMA_DATA_WIDTH in [64, 128, 256]"
- "SCA_LEVEL <= 2"
END_CONSTRAINT_META -->

### LRS.CFG.PQC.NTT_LANES.001 NTT 通道数

<!-- LRS_META
id: LRS.CFG.PQC.NTT_LANES.001
category: CFG
feature: ntt_lanes
priority: P0
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
name: NTT_LANES
type: int
category: compile_time
default: 2
domain: [1, 2, 4]
depends_on: []
description: 双模多项式引擎的并行蝶形 lane 数，决定面积/吞吐档位
END_PARAM_META -->

#### Requirement

`NTT_LANES` 应支持 `{1, 2, 4}` 三个综合期档位，分别对应面积型、推荐基线与吞吐型配置。
所有档位应保持完全相同的软件 ABI 与算法结果。

#### Acceptance Criteria

- 三个合法值均可完成 elaboration 且结果一致；
- 非法值（如 0、3、8）在 elaboration 阶段被拒绝；
- 默认值为 2。

---

### LRS.CFG.PQC.KECCAK_ROUNDS.001 Keccak 每周期轮数

<!-- LRS_META
id: LRS.CFG.PQC.KECCAK_ROUNDS.001
category: CFG
feature: keccak_rounds
priority: P0
status: active
source_ref:
- pqc_contract.md#§5.2
applicability:
  expr: 'true'
verification_method:
- elaboration
- simulation
END_LRS_META -->

<!-- PARAM_META
name: KECCAK_ROUNDS_PER_CYCLE
type: int
category: compile_time
default: 2
domain: [1, 2]
depends_on: []
description: Keccak-f[1600] permutation 每周期计算轮数
END_PARAM_META -->

#### Requirement

`KECCAK_ROUNDS_PER_CYCLE` 应支持 `{1, 2}`；V1.0 不应支持完全展开的 24 轮/周期。

#### Acceptance Criteria

- 两个合法值均可 elaboration 并产生相同哈希结果；
- 大于 2 的值被拒绝；
- 默认值为 2。

---

### LRS.CFG.PQC.LOCAL_SRAM.001 本地 SRAM 容量

<!-- LRS_META
id: LRS.CFG.PQC.LOCAL_SRAM.001
category: CFG
feature: local_sram
priority: P0
status: active
source_ref:
- pqc_contract.md#§5.4
- pqc_contract.md#§19.1
applicability:
  expr: 'true'
verification_method:
- elaboration
- static
END_LRS_META -->

<!-- PARAM_META
name: LOCAL_SRAM_KIB
type: int
category: compile_time
default: 64
domain: [32, 64, 96]
depends_on: []
description: 本地工作 SRAM 逻辑容量（KiB），4 或 8 bank
END_PARAM_META -->

#### Requirement

`LOCAL_SRAM_KIB` 应支持 `{32, 64, 96}` KiB。每个合法容量下，最大 ML-DSA 工作集应通过
页生命周期复用完成，不应以常驻完整矩阵 `A(k×l)` 为前提。

#### Acceptance Criteria

- 三个容量均可容纳各参数集最大工作集；
- 容量不足导致的页分配冲突被检测为内部错误而非静默错误结果；
- 默认值为 64。

---

### LRS.CFG.PQC.DMA_WIDTH.001 DMA 数据宽度

<!-- LRS_META
id: LRS.CFG.PQC.DMA_WIDTH.001
category: CFG
feature: dma_width
priority: P1
status: active
source_ref:
- pqc_contract.md#§8.1
applicability:
  expr: 'true'
verification_method:
- elaboration
- simulation
END_LRS_META -->

<!-- PARAM_META
name: DMA_DATA_WIDTH
type: int
category: compile_time
default: 128
domain: [64, 128, 256]
depends_on: []
description: AXI4 master 数据通道宽度（bit）
END_PARAM_META -->

#### Requirement

`DMA_DATA_WIDTH` 应支持 `{64, 128, 256}`，并影响持续消息哈希带宽；算法结果不应随宽度改变。

#### Acceptance Criteria

- 三个宽度均可完成 DMA 与算法闭环；
- 非 2 的幂宽度被拒绝；
- 默认值为 128。

---

### LRS.CFG.PQC.KEY_SLOT.001 Key slot 数量

<!-- LRS_META
id: LRS.CFG.PQC.KEY_SLOT.001
category: CFG
feature: key_slot_num
priority: P0
status: active
source_ref:
- pqc_contract.md#§3.2
applicability:
  expr: 'true'
verification_method:
- elaboration
- simulation
END_LRS_META -->

<!-- PARAM_META
name: KEY_SLOT_NUM
type: int
category: compile_time
default: 8
domain: 8..32
depends_on: []
description: 逻辑 key slot 数量，最少 8
END_PARAM_META -->

#### Requirement

`KEY_SLOT_NUM` 应至少为 8，支持 ML-KEM secret key、ML-DSA secret key 与 public key
三类 slot 类型。

#### Acceptance Criteria

- 小于 8 的配置被拒绝；
- 合法配置下每个 slot 可独立承载类型与用途元数据；
- 默认值为 8。

---
