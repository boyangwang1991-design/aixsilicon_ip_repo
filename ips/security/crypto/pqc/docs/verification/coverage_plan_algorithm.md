# PQC 完整计算与安全集成功能覆盖

覆盖是探索记录，必须同时有独立结果检查；bins不存在于当前RTL时保持未覆盖，不删需求。

## COV.PQC.ALGO.001 完整计算组合与比较

<!-- COVERAGE_META
id: COV.PQC.ALGO.001
name: cov_algo_001
type: functional
description: 完整计算组合与比较
feature_ref:
- FL.PQC.ALGO
applicability:
  expr: 'true'
END_COVERAGE_META -->

采样与bins：parameter_set × 合法opcode（18组合）；每组合≥3向量；首/中/末输出字节比较；所有结果完整退休。

## COV.PQC.ALGO.002 数学与编码负向

<!-- COVERAGE_META
id: COV.PQC.ALGO.002
name: cov_algo_002
type: functional
description: 数学与编码负向
feature_ref:
- FL.PQC.ALGO
applicability:
  expr: 'true'
END_COVERAGE_META -->

采样与bins：KEM正确/失配首中末/多位置/非规范公钥/密文长度；DSA消息/ctx/pk/sig篡改、z边界、hint次序/重复/权重/尾零；负向类别×参数集。

## COV.PQC.ALGO.003 消息与随机模式

<!-- COVERAGE_META
id: COV.PQC.ALGO.003
name: cov_algo_003
type: functional
description: 消息与随机模式
feature_ref:
- FL.PQC.ALGO
applicability:
  expr: 'true'
END_COVERAGE_META -->

采样与bins：msg 0/1、rate-1/rate/rate+1、4KiB两侧、超过SRAM；ctx0/1/255/非法256；deterministic/hedged×DSA参数集；pure/prehash开关。

## COV.PQC.COMMIT.001 完成与错误并发

<!-- COVERAGE_META
id: COV.PQC.COMMIT.001
name: cov_commit_001
type: functional
description: 完成与错误并发
feature_ref:
- FL.PQC.CMD
applicability:
  expr: 'true'
END_COVERAGE_META -->

采样与bins：payload最后B/completion B/IRQ次序；output B错误、completion B错误、撤销/abort与最后写同拍；相同tag不同epoch。

## COV.PQC.KEYMANAGER.001 密钥导入托管生命周期

<!-- COVERAGE_META
id: COV.PQC.KEYMANAGER.001
name: cov_keymanager_001
type: functional
description: 密钥导入托管生命周期
feature_ref:
- FL.PQC.KEYMANAGER.PENDING
applicability:
  expr: 'true'
END_COVERAGE_META -->

采样与bins：导入短/长/完整/错误last；owner/domain/usage/算法/pset/generation错误；托管ACK成功/失败/旧ID/重复；revoke×phase。

## COV.PQC.ENTROPY.001 熵与租约

<!-- COVERAGE_META
id: COV.PQC.ENTROPY.001
name: cov_entropy_001
type: functional
description: 熵与租约
feature_ref:
- FL.PQC.ENTROPY
applicability:
  expr: 'true'
END_COVERAGE_META -->

采样与bins：consumer×purpose×SCA；health/tag错误、等待/配额边界、旧epoch、重复release、消费/清除同拍；fresh mask变更。

## COV.PQC.SCA.001 完整两share链

<!-- COVERAGE_META
id: COV.PQC.SCA.001
name: cov_sca_001
type: functional
description: 完整两share链
feature_ref:
- FL.PQC.CFG
applicability:
  expr: 'true'
END_COVERAGE_META -->

采样与bins：SCA0/1/2×18操作；Level2转换/采样/比较/select/Keccak实例全部激活；配额consume/release/clear与完整功能比对。

## COV.PQC.PERF.001 周期与重叠

<!-- COVERAGE_META
id: COV.PQC.PERF.001
name: cov_perf_001
type: functional
description: 周期与重叠
feature_ref:
- FL.PQC.PERF
applicability:
  expr: 'true'
END_COVERAGE_META -->

采样与bins：命名配置×算法×反压；DMA/计算重叠；Sign0/1/多次拒绝与上限；1000样本统计与模型偏差。

## COV.PQC.DFX.001 生命周期测试门控

<!-- COVERAGE_META
id: COV.PQC.DFX.001
name: cov_dfx_001
type: functional
description: 生命周期测试门控
feature_ref:
- FL.PQC.DFX
applicability:
  expr: 'true'
END_COVERAGE_META -->

采样与bins：生产/测试/RMA×debug/故障注入/MBIST请求；清除前/中/后；禁止秘密读回与恢复后功能。

算法维度cross只生成合法opcode/pset组合；被裁剪操作另采拒绝bins。向量与mask种子不穷举全空间，公开记录已执行集合。
