# PQC 测试矩阵：完整算法

本计划共 21 个参数化 testcase，参数/向量/seed 作为运行维度，不复制测试 ID。
所有用例先按输入契约生成预期，实际观察必须来自握手 monitor。
现有同名源码不代表实现了本版全部义务；执行状态只在 reports/report.md 维护。

## TC.PQC.ALGO.001 tc_kem_full_compute

<!-- TESTCASE_META
id: TC.PQC.ALGO.001
name: tc_kem_full_compute
type: algorithm
description: ML-KEM 三参数集 KeyGen/Encaps/Decaps 的 RTL 端到端 KAT、独立互操作与隐式拒绝
priority: must
tier: regression
implementation: verification/tc/tc_kem_full_compute.sv
proof_kind: uvm
feature_ref:
- FL.PQC.ALGO
design_ref:
- HLD.MOD.PQC.KEMSEQ
- LLD.MOD.PQC.KEMSEQ
preconditions:
- 真实 DMA/完整原语链/专用托管就绪；冻结的独立向量及 oracle 可用；测试种子授权有效
stimulus:
- 每参数集执行至少 3 组不同 d/z/m 的 KeyGen、Encaps、Decaps；通过 APB 描述符、AXI memory、entropy/KM 接口驱动
- 重放离线交叉核验的互操作向量：独立公钥/密文输入 RTL，RTL 公钥/密文与其配对冻结结果比对
- 逐位置改变密文字节，包括首、中、末位置和多个位置；保持长度不变
expected_result:
- 公钥、密文、32 B shared secret 与独立期望逐字节一致；独立密文与本地密文均通过
- KeyGen 私钥只在专用托管 monitor 比对，托管 ACK 前不得成功；普通 DMA 无私钥
- 无效密文 shared secret 精确等于独立 oracle 的拒绝输出；状态仍为 SUCCESS
- 六参数之外的能力不得自动默认为可执行；每操作至少一次输出和 completion 比对
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.ALGO.002 tc_dsa_full_compute

<!-- TESTCASE_META
id: TC.PQC.ALGO.002
name: tc_dsa_full_compute
type: algorithm
description: 三参数集真实 DSA KeyGen/Sign/Verify、deterministic/hedged、消息域分离及独立互操作
priority: must
tier: regression
implementation: verification/tc/tc_dsa_full_compute.sv
proof_kind: uvm
feature_ref:
- FL.PQC.ALGO
design_ref:
- LLD.MOD.PQC.DSASEQ
- LLD.MOD.PQC.KECCAK
- LLD.MOD.PQC.CODEC
preconditions:
- UVM 1.2、对应真实接口与独立 oracle 已就绪；构建与输入身份固定
stimulus:
- 每参数集至少 3 个 xi 与 message/context 组合，经专用接口导入并执行完整 KeyGen/Sign/Verify
- deterministic 重复签名；hedged 重放不同的固定32 B randomness向量；独立签名交RTL Verify，RTL签名与离线交叉核验向量比对
- 消息长度 0/1/135/136/137/167/168/169/4095/4096/4097 和超过 LOCAL_SRAM_KIB*1024，ctx 0/1/255，合法任意分段
- HashML-DSA 开启时遍历 HLD 声明的 prehash ID，关闭时拒绝；测试 pure/prehash/context 域隔离
expected_result:
- 公钥、专用托管私钥、签名逐字节符合独立期望；Verify valid 正确
- deterministic 完全一致；hedged 与实际 randomness 对应的 oracle 签名一致且独立 Verify 通过
- 消息及 context 均真正经过 DUT；禁止从 host 注入内部 mu；大消息无截断
- 每次拒绝均不发布候选签名；所有 z/r0/ct0/hint 检查独立覆盖
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.ALGO.003 tc_pqc_invalid_inputs

<!-- TESTCASE_META
id: TC.PQC.ALGO.003
name: tc_pqc_invalid_inputs
type: negative
description: 规范编码、篡改、长度、容量及授权负向算法检查
priority: must
tier: regression
implementation: verification/tc/tc_pqc_invalid_inputs.sv
proof_kind: uvm
feature_ref:
- FL.PQC.ALGO
design_ref:
- LLD.MOD.PQC.FE.VALIDATE
- LLD.MOD.PQC.KEMSEQ
- LLD.MOD.PQC.DSASEQ
preconditions:
- UVM 1.2、对应真实接口与独立 oracle 已就绪；构建与输入身份固定
stimulus:
- KEM 非规范公钥、错误 dk 哈希、短/长密文与全位置失配；DSA 错 pk/sig 长度、z 边界、hint 越界/重复/逆序/尾部非零
- 篡改 message/context/pk/challenge/signature；ctx=256、长度高32bit非零/溢出、非法 opcode/pset/flag
- 输出容量为规范长度-1/相等/+1，合法描述符 CRC 改错及全部保留位
expected_result:
- 公开格式/授权错误在秘密访问和输出前失败，guard bytes 保持；expected status 来自输入契约
- 合法长度 KEM 失配仍 SUCCESS 且 oracle 拒绝秘密匹配；DSA 数学无效返回公开 invalid
- 异常不会挂死、留下旧结果或发生越界；每种负向至少一个断言/scoreboard 命中
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.PERF.001 tc_pqc_performance

<!-- TESTCASE_META
id: TC.PQC.PERF.001
name: tc_pqc_performance
type: performance
description: 周期、计算DMA重叠、Sign统计时延和无软件回退
priority: must
tier: extended
implementation: verification/tc/tc_pqc_performance.sv
proof_kind: uvm
feature_ref:
- FL.PQC.PERF
design_ref:
- HLD.PERF.PQC.KEM768
- LLD.PPA.PQC.POLY
preconditions:
- UVM 1.2、对应真实接口与独立 oracle 已就绪；构建与输入身份固定
stimulus:
- 冻结输入/服务节奏，三命名配置执行六参数操作；Balanced 无反压统计1000次Sign
- 记录命令接受/primitive/input/output/completion/IRQ时间戳和公开PERF；固定输入重放验证测量
- 分别测内部等待、外部反压及安全等级开销，与当前HLD周期模型对照
expected_result:
- 逐阶段计数与实测一致，禁止 host 完成任何算法步骤
- P50/P95/P99、样本数及模型误差可重现，逐项对照当前LRS目标；未达阈值保留失败
- 生产计数器不暴露拒绝原因/细粒度秘密事件
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。
