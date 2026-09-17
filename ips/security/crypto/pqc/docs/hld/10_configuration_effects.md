# PQC 配置对架构的影响


### HLD.CFG.PQC.NTT_LANES

<!-- HLD_CONFIG_META
id: HLD.CFG.PQC.NTT_LANES
config_ref: PARAM.PQC.NTT_LANES
affects:
  modules:
  - HLD.MOD.PQC.POLY
  performance:
  - HLD.PERF.PQC.KEM768
  - HLD.PERF.PQC.DSA65SIGN
architecture_effect: 蝶形实例数 1/2/4；NTT 周期数由实际 lane 计算及存储收集/写回共同决定；SRAM bank 访问并发度变化
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

### HLD.CFG.PQC.KECCAK_ROUNDS

<!-- HLD_CONFIG_META
id: HLD.CFG.PQC.KECCAK_ROUNDS
config_ref: PARAM.PQC.KECCAK_ROUNDS_PER_CYCLE
affects:
  modules:
  - HLD.MOD.PQC.KECCAK
  performance:
  - HLD.PERF.PQC.HASHBW
architecture_effect: permutation 周期数 24 或 12；Keccak 与 NTT 重叠窗口变化
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

### HLD.CFG.PQC.LOCAL_SRAM

<!-- HLD_CONFIG_META
id: HLD.CFG.PQC.LOCAL_SRAM
config_ref: PARAM.PQC.LOCAL_SRAM_KIB
affects:
  modules:
  - HLD.MOD.PQC.SRAM
  performance:
  - HLD.PERF.PQC.SRAM
architecture_effect: 可用页数与 pack/unpack staging 深度；影响 32 KiB 档位是否需
  缩减并发工作集
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

### HLD.CFG.PQC.DMA_WIDTH

<!-- HLD_CONFIG_META
id: HLD.CFG.PQC.DMA_WIDTH
config_ref: PARAM.PQC.DMA_DATA_WIDTH
affects:
  modules:
  - HLD.MOD.PQC.DMA
  performance:
  - HLD.PERF.PQC.HASHBW
architecture_effect: AXI 数据通道宽度与内部拼装逻辑规模
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

### HLD.CFG.PQC.SCA

<!-- HLD_CONFIG_META
id: HLD.CFG.PQC.SCA
config_ref: PARAM.PQC.SCA_LEVEL
affects:
  modules:
  - HLD.MOD.PQC.KECCAK
  - HLD.MOD.PQC.POLY
  - HLD.MOD.PQC.SRAM
architecture_effect: Level 2 采用两 share 候选架构，镜像逻辑 SRAM 与 Key RAM 数据域；
  Keccak/NTT/采样/转换/比较全链路保持 masking，增加随机带宽及周期，见 09_masking_level2.md
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

### HLD.CFG.PQC.ALGO_MASK

<!-- HLD_CONFIG_META
id: HLD.CFG.PQC.ALGO_MASK
config_ref: PARAM.PQC.ENABLE_ALGO_MASK
affects:
  modules:
  - HLD.MOD.PQC.KEMSEQ
  - HLD.MOD.PQC.DSASEQ
architecture_effect: 裁剪参数集后对应 sequencer 可移除，CAPABILITY 随之变化
applicability:
  expr: 'true'
END_HLD_CONFIG_META -->

