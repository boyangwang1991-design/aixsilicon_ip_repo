# PQC 参数与配置执行计划

## 单一配置来源

合法空间只来自 LRS CFG 及派生 `model/parameter_space.yaml`。当前 9 个参数、
3 个命名配置；VPLAN 不重新定义参数合法性。下列集合引用真实存在的 ID，替代
历史 CFG_DEFAULT/CFG_NTT_LANES_MIN 等不存在引用。

<!-- CONFIG_SET_META
id: CFGSET.PQC.DEFAULT
name: named_configurations
strategy: risk_based
configs:
- CFG_TINY
- CFG_BALANCED
- CFG_THROUGHPUT
purpose: 默认使用 Balanced；Tiny 与 Throughput 作为边界运行维度，每个执行记录明确唯一配置
END_CONFIG_SET_META -->

| 配置 | 必需执行 |
|---|---|
| CFG_BALANCED | 全量20 testcase与18正常操作；全部KAT、negative、恢复和随机反压 |
| CFG_TINY | 18操作KAT、最大DSA工作集、64-bit DMA、1轮Keccak、1 lane |
| CFG_THROUGHPUT | 18操作KAT、256-bit DMA、4 lane、96KiB、16 slots |

相同输入跨配置逐字节比较，不能用三次 elaboration 代替三次功能执行。
TC.PQC.CFG.001 验证 elaboration，TC.PQC.CFG.002 验证结果等价，分别记录。

## 尚需由 19-PC 建立的实例配置

以下是必须准备的执行维度，不是现有 canonical 配置 ID，也不宣称已执行。
由 19 owner 生成并校验 `configs/` 实例，manifest 绑定具体参数值后才能用于回归。

| 类别 | 维度/风险 | 义务 |
|---|---|---|
| DEFAULT | Balanced | 完整基线 |
| MIN/MAX | 9参数合法端点，KEY_SLOT_NUM 8/32 | 每个端点 elaboration 与对应功能；不能只覆盖命名配置的16槽 |
| FEATURE_ON/OFF | ENABLE_HASH_ML_DSA、ENABLE_PIO | 功能与capability一致；禁用访问失败且无副作用 |
| 算法裁剪 | ENABLE_ALGO_MASK 单bit、KEM-only、DSA-only、全开 | 每个保留参数集计算，禁止参数集在秘密访问前拒绝 |
| 安全级别 | SCA_LEVEL 0/1/2 | 全18操作输出等价；Level2另做全链随机/掩码验证 |
| RISK | 最大DSA、32KiB、Level2；最大slots与最小存储 | 容量、页生命周期、双share存储、清除上界 |
| 结构组合 | NTT 1/2/4、Keccak 1/2、DMA64/128/256 | 合法 pairwise 加上述高风险点；不全笛卡尔穷举 |
| 非法值 | 每个离散域外值、范围外值、非法组合 | elaboration/生成入口必须拒绝，不能静默默认 |
| ASYNC | 核内单时钟，不存在额外计算域 | 不适用核内多时钟组合；旁带相位与复位仍必须测 |

CFGSET 只包含已存在 ID；新实例完成后由 owner 更新该集合及追踪，不预填 PASS。
版本差异、VIP接口、DUT配置、向量、编译宏与工具版本构成构建身份，不兼容 VDB
不混合成单一百分比。统计每配置已计划/执行/成功/失败/未实现 testcase 数。

<!-- CONFIG_COVERAGE_META
id: CCOV.PQC.CFG_MATRIX
name: config_matrix_coverage
dimensions:
- NTT_LANES
- KECCAK_ROUNDS_PER_CYCLE
- LOCAL_SRAM_KIB
- DMA_DATA_WIDTH
- KEY_SLOT_NUM
- SCA_LEVEL
- ENABLE_ALGO_MASK
- ENABLE_HASH_ML_DSA
- ENABLE_PIO
feature_ref:
- FL.PQC.CFG
applicability:
  expr: 'true'
END_CONFIG_COVERAGE_META -->

没有参数执行证据的维度保持未覆盖；结构裁剪导致不可达须独立审查，不自动豁免
feature off 时的拒绝行为。所有配置在 full regression 之后、coverage closure 之前
由 19-PV 汇总真实逐配置日志。
