# PQC 测试矩阵：安全与生命周期

本计划共 21 个参数化 testcase，参数/向量/seed 作为运行维度，不复制测试 ID。
所有用例先按输入契约生成预期，实际观察必须来自握手 monitor。
现有同名源码不代表实现了本版全部义务；执行状态只在 reports/report.md 维护。

## TC.PQC.RESET.001 tc_reset_selftest_lock

<!-- TESTCASE_META
id: TC.PQC.RESET.001
name: tc_reset_selftest_lock
type: reset
description: 自检成功前拒绝密码命令；tamper 触发零化与锁定
priority: must
tier: regression
implementation: verification/tc/tc_reset_selftest_lock.sv
feature_ref:
- FL.PQC.RESET
design_ref:
- LLD.FSM.PQC.TOP.MAIN
- LLD.RST.PQC.ZEROPATH
preconditions:
- 复位释放
stimulus:
- 冷复位、自检失败/成功、warm reset、掉电请求、tamper/lifecycle/abort/zeroize/KM revoke
- 在 fetch/input/primitive/staging/output/completion 各阶段及 stall 中触发，覆盖结果发布同拍
- 对清除期间的新门铃/导入、连续清除、迟到总线响应及超时执行负向刺激
expected_result:
- 自检通过前无密码执行，失败锁定；身份立即失效，所有秘密物理清除后才 ack
- 已展示的 AXI 请求保持并排空；公平响应条件下满足清除预算，永久阻塞只可锁定不能假 ack
- warm reset 不自行假定 persistent key 保留；正常恢复后新命令正确且不残留旧结果
timeout_policy: 100000000 cycles to reach injection point; ZEROIZE_MAX_CYCLES for local wipe plus declared AXI drain bound
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.KEY.001 tc_key_slot_permission

<!-- TESTCASE_META
id: TC.PQC.KEY.001
name: tc_key_slot_permission
type: negative
description: 非特权访问 key slot 窗口被拒；destroy 后旧 handle 失效
priority: must
tier: regression
implementation: verification/tc/tc_key_slot_permission.sv
feature_ref:
- FL.PQC.KEY
design_ref:
- LLD.REG.PQC.SLOT_CTRL
- LLD.REG.PQC.SLOT_DESTROY
preconditions:
- privileged=1 完成一次 import
stimulus:
- privileged=0 访问 KEY_SLOT_CTRL
- destroy 后再用旧 generation 提交命令
expected_result:
- 非特权访问返回 pslverr
- destroy 递增 generation，旧 handle 的 key_handle_ok 为 0
- 命令返回 BAD_KEY 且不访问秘密
timeout_policy: 100000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.KEY.002 tc_key_manager_lifecycle

<!-- TESTCASE_META
id: TC.PQC.KEY.002
name: tc_key_manager_lifecycle
type: security
description: 专用密钥导入、KeyGen 托管、确认身份、授权域与撤销/退休完整生命周期
priority: must
tier: regression
implementation: verification/tc/tc_key_manager_lifecycle.sv
feature_ref:
- FL.PQC.KEYMANAGER.PENDING
design_ref:
- LLD.REG.PQC.SLOT_DESTROY
preconditions:
- 专用 KM 接口及可信上下文就绪；不通过普通 DMA 导入私钥
stimulus:
- 完整/短/长/错误 last 导入，头与材料背压，错 handle/owner/domain/algorithm/pset/usage
- 托管完整确认/错误确认/旧 epoch ACK/重复 ACK；撤销与确认/读响应同拍
- 命令退休后重用旧工作态 key，重新授权导入后再执行
expected_result:
- 只有完整且授权匹配的材料可用；部分导入永不发布 READY
- 只有本命令生成的私钥可托管；完整 ACK 后才提交 KeyGen
- 撤销优先且旧结果不可重新发布；外部长期密钥不被工作态退休销毁
timeout_policy: 100000000 cycles per keygen; 1000000 cycles for lifecycle subcase
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.CT.001 tc_kem_decaps_constant_time

<!-- TESTCASE_META
id: TC.PQC.CT.001
name: tc_kem_decaps_constant_time
type: directed
description: 合法与非法密文的公开 trace 形状与周期分布一致，无有效性 oracle
priority: must
tier: regression
implementation: verification/tc/tc_kem_decaps_constant_time.sv
feature_ref:
- FL.PQC.CT
design_ref:
- LLD.SAFE.PQC.CT_SELECT
preconditions:
- IP 完成 KeyGen 得到 dk slot
stimulus:
- 每 KEM 参数集对同一 key/相同公开长度执行合法和不同失配位置的密文
- 固定并重放相同 AXI/entropy 服务时序，记录地址、请求数、cycle、状态与中断
- Sign 定向触发 0/1/多次拒绝及上限，记录单尝试调度；不假设总时延固定
expected_result:
- KEM 合法/非法公开 trace 与完成周期一致，输出为 oracle 指定的不同秘密值
- Sign 每次尝试走固定检查/擦除序列；拒绝候选无普通 DMA 输出，超限为通用错误
- 仿真 trace 一致仅证明采样执行；秘密依赖还须 formal/static taint 证据
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.INTEGRITY.001 tc_illegal_state_shutdown

<!-- TESTCASE_META
id: TC.PQC.INTEGRITY.001
name: tc_illegal_state_shutdown
type: error_injection
description: 注入控制完整性错误后不得进入 EXECUTE，必须走零化路径
priority: must
tier: extended
implementation: verification/tc/tc_illegal_state_shutdown.sv
feature_ref:
- FL.PQC.INTEGRITY
design_ref:
- LLD.SAFE.PQC.CTRL_SPARSE
preconditions:
- IP 处于 IDLE
stimulus:
- 通过 LLD 测试 hook 注入状态、计数器、command 属性、ECC 单错/双错
- 在 Verify 最终判决及 KEM compare/select 期间逐点注入；生产生命周期重复注入请求
expected_result:
- 可校正错误不改结果；不可校正/完整性错误安全清除并锁定
- invalid 不因单点故障变为 valid；秘密结果不发布，旧 epoch 不退休
- 生产模式测试口不生效；仅观察告警复位值不能使本例通过
timeout_policy: 100000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.ENTROPY.001 tc_entropy_protocol

<!-- TESTCASE_META
id: TC.PQC.ENTROPY.001
name: tc_entropy_protocol
type: error_injection
description: 随机输入授权、反压、身份、配额、故障与清除
priority: must
tier: regression
implementation: verification/tc/tc_entropy_protocol.sv
proof_kind: uvm
feature_ref:
- FL.PQC.ENTROPY
design_ref:
- LLD.MOD.PQC.TOP.RANDOM
preconditions:
- UVM 1.2、对应真实接口与独立 oracle 已就绪；构建与输入身份固定
stimulus:
- 合法域 entropy 随机停顿，valid/ready 长反压；错误 tag/health、中途故障、超时
- 在 seed/mask/refresh 及 chunk 消费/释放/清除边界注入；旧 token、重复 release
- 生产生命周期请求测试 seed，deterministic Sign 与 hedged 分别观察消费
expected_result:
- 只消费握手数据，owner/epoch/primitive/lease 匹配；配额与丢弃尾位符合冻结合同
- 故障同拍停止发布并清除；随机位不跨租约重用，不回退测试 seed
- 算法输出仍与实际 seed/randomness 的 oracle 一致
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.SCA.001 tc_masked_full_compute

<!-- TESTCASE_META
id: TC.PQC.SCA.001
name: tc_masked_full_compute
type: stress
description: Level 2 完整秘密链的功能、随机预算和组合边界
priority: must
tier: extended
implementation: verification/tc/tc_masked_full_compute.sv
proof_kind: uvm
feature_ref:
- FL.PQC.CFG
design_ref:
- LLD.MOD.PQC.TOP.RANDOM
- LLD.MOD.PQC.KECCAK.MASKED_ROUND
preconditions:
- UVM 1.2、对应真实接口与独立 oracle 已就绪；构建与输入身份固定
stimulus:
- 六参数全部操作在 Level 2 以至少两组 fresh masks 重放相同算法输入
- 对各秘密消费者的租约/转换/采样停顿、撤销与 clear 同拍，执行安全静态/形式证明配套检查
expected_result:
- 不同 mask 得到同一标准结果；两个 share 始终在敏感链路保持，普通出口无秘密或单 share
- 每个 gadget 实例、转换及采样均有配额与组合证明绑定；仅 XOR 重组 KAT 不能宣称 SCA 通过
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.DFX.001 tc_dfx_security

<!-- TESTCASE_META
id: TC.PQC.DFX.001
name: tc_dfx_security
type: error_injection
description: 测试生命周期门控、debug、MBIST与可观察信号隔离
priority: must
tier: extended
implementation: verification/tc/tc_dfx_security.sv
proof_kind: uvm
feature_ref:
- FL.PQC.DFX
design_ref:
- HLD.SAFETY.PQC.DFXTEST
preconditions:
- UVM 1.2、对应真实接口与独立 oracle 已就绪；构建与输入身份固定
stimulus:
- 跨生产/测试/RMA生命周期请求debug与故障注入；密钥存在时尝试普通读回
- MBIST前后清除及retention场景；配套检查scan与trace清单
expected_result:
- 生产状态不接受受限测试操作，debug不开放key RAM
- 测试前后秘密失效/清除；scan排除与静态taint证据齐备才接受该需求
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。
