# PQC 测试矩阵：控制与配置

本计划共 21 个参数化 testcase，参数/向量/seed 作为运行维度，不复制测试 ID。
所有用例先按输入契约生成预期，实际观察必须来自握手 monitor。
现有同名源码不代表实现了本版全部义务；执行状态只在 reports/report.md 维护。

## TC.PQC.CMD.001 tc_cmd_smoke

<!-- TESTCASE_META
id: TC.PQC.CMD.001
name: tc_cmd_smoke
type: directed
description: 上电使能、自检通过、门铃提交合法命令并收到 completion 与 DONE
priority: must
tier: smoke
implementation: verification/tc/tc_cmd_smoke.sv
feature_ref:
- FL.PQC.CMD
design_ref:
- LLD.FSM.PQC.TOP.MAIN
preconditions:
- rst_n 释放，CTRL.enable 置位
stimulus:
- 通过 AXI memory 放置 CRC 正确描述符和有效 ML-KEM-512 输入，经 APB 提交真实 Encaps
- 对输出 B 与 completion B 分别施加延迟，轮询 STATUS 并观察 IRQ
expected_result:
- 真实密文及共享秘密通过 oracle 比较；输入读取、输出写与 completion 均非零
- 所有 payload B 成功后才写 completion，completion B 成功后 DONE/IRQ
- 第二命令使用新 tag 与不同输入，不能复用上一命令结果；队列清空
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.APB.001 tc_apb_protection

<!-- TESTCASE_META
id: TC.PQC.APB.001
name: tc_apb_protection
type: negative
description: 未映射地址返回 pslverr；BUSY 期间写命令组被拒绝且值不变
priority: must
tier: smoke
implementation: verification/tc/tc_apb_protection.sv
feature_ref:
- FL.PQC.APB
design_ref:
- LLD.IF.PQC.FE.APB
- LLD.TIMING.PQC.APB.RW
preconditions:
- IP 处于 IDLE
stimulus:
- 遍历全部 PPROT/PSTRB、未对齐与高低未映射地址
- BUSY 与 command_pending 时改写所有受保护组和重复门铃；读回并完成原命令
expected_result:
- 有界响应、拒绝无副作用，命令快照与原结果保持
- 全地址空间无永久等待；非特权/非安全访问不绕过保护
timeout_policy: 100000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.REG.001 tc_reg_reset_attr

<!-- TESTCASE_META
id: TC.PQC.REG.001
name: tc_reg_reset_attr
type: register
description: 复位后 RO/RW 字段读回符合 RDL reset；W1C 只清除对应位
priority: must
tier: smoke
implementation: verification/tc/tc_reg_reset_attr.sv
feature_ref:
- FL.PQC.REG
design_ref:
- LLD.REG.PQC.ID_VERSION
- LLD.REG.PQC.STATUS
- LLD.REG.PQC.INTR_STATE
preconditions:
- 复位释放后立即读取
stimulus:
- 通过生成 RAL frontdoor 访问所有寄存器定义与槽数组；检查 reset/RO/RW/保留位/PSTRB
- 全部 W1C 字段逐 bit 清除并与 HW set 同拍；单拍请求不粘连；SW clear 与计数器 HW 更新冲突
- 对每个综合配置检查动态 capability 和 ABI；运行期读取 PERF/completion/slot metadata
expected_result:
- RDL 结构及 LLD 字段行为均满足；RAL adapter/predictor 只由 monitor 驱动
- 拒绝事务不改模型；HW set 优先的 W1C 不丢事件；保留/未映射/未对齐行为符合合同
- 不能把整个 key-slot 窗口或动态状态当作无条件跳过区域
timeout_policy: 200000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.SIDEBAND.001 tc_intr_independence

<!-- TESTCASE_META
id: TC.PQC.SIDEBAND.001
name: tc_intr_independence
type: directed
description: 五类中断可独立置位、屏蔽、清除
priority: must
tier: regression
implementation: verification/tc/tc_intr_independence.sv
feature_ref:
- FL.PQC.SIDEBAND
design_ref:
- LLD.IRQ.PQC.DONE
- LLD.IRQ.PQC.TAMPER
preconditions:
- IP 已使能并进入 IDLE
stimulus:
- 分别置位 INTR_TEST 各位
- 在各 enable 组合下观察 irq 输出
- W1C 清除单一位
expected_result:
- 每个中断独立可控
- enable=0 时对应位不产生外部 irq 但仍置位
- W1C 不影响其他位
timeout_policy: 100000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.DMA.001 tc_dma_boundary

<!-- TESTCASE_META
id: TC.PQC.DMA.001
name: tc_dma_boundary
type: boundary
description: 跨 4 KiB 的传输被拆分为多个 INCR burst 且字节顺序不变
priority: must
tier: regression
implementation: verification/tc/tc_dma_boundary.sv
feature_ref:
- FL.PQC.DMA
design_ref:
- LLD.TIMING.PQC.DMA.SPLIT
preconditions:
- DMA 从端就绪
stimulus:
- 对真实算法 payload/context/output/completion 使用 64/128/256-bit 总线，地址在 4KiB 边界前一个合法 beat
- 长度含 0/1/beat-1/beat/beat+1、多 burst 与尾字节；改变合法分段及 AR/R/AW/W/B 独立反压
- RRESP/BRESP 错误、早/迟 RLAST、地址高位/溢出/重叠、输出 capacity 差一字节，超时与取消
expected_result:
- 逐 WSTRB 更新的观察内存与 oracle 一致；guard bytes 保持；无越界或多余读写
- burst 不跨 4KiB，安全/特权属性符合授权；AXI 接受后取消仍排空
- 输出或 completion B 错误不得成功 IRQ；错误分类符合非敏感合同
timeout_policy: 100000000 cycles per algorithm command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.CFG.001 tc_param_elab

<!-- TESTCASE_META
id: TC.PQC.CFG.001
name: tc_param_elab
type: directed
description: Tiny/Balanced/Throughput 三档配置可 elaboration 且 CAPABILITY 一致
priority: must
tier: extended
implementation: scripts/run_pqc_param_elab.py
proof_kind: static
feature_ref:
- FL.PQC.CFG
design_ref:
- HLD.CFG.PQC.NTT_LANES
- HLD.CFG.PQC.KECCAK_ROUNDS
preconditions:
- vlogan 可用
stimulus:
- 分别以三档参数 elaboration 顶层
expected_result:
- 三档均编译通过
- 非法参数值被拒绝
timeout_policy: 1800 s
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.CONS.001 tc_delivery_static

<!-- TESTCASE_META
id: TC.PQC.CONS.001
name: tc_delivery_static
type: directed
description: RTL 目录无仅仿真构造、core 可解析、寄存器派生文件未被手改
priority: must
tier: extended
implementation: scripts/run_pqc_delivery_check.py
proof_kind: static
feature_ref:
- FL.PQC.CONS
design_ref:
- RTL.PQC.TOP
preconditions:
- 工作区完整
stimulus:
- 扫描 rtl/ 与 generated/，校验 manifest 哈希
expected_result:
- 无 .v/.vh 与仅仿真构造
- core 解析成功
- 生成文件哈希与 manifest 一致
timeout_policy: 600 s
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。

## TC.PQC.CFG.002 tc_pqc_config_equivalence

<!-- TESTCASE_META
id: TC.PQC.CFG.002
name: tc_pqc_config_equivalence
type: directed
description: 跨参数配置结果等价、能力裁剪与最大工作集
priority: must
tier: extended
implementation: verification/tc/tc_pqc_config_equivalence.sv
proof_kind: uvm
feature_ref:
- FL.PQC.CFG
design_ref:
- HLD.CFG.PQC.NTT_LANES
- HLD.CFG.PQC.SCA
preconditions:
- UVM 1.2、对应真实接口与独立 oracle 已就绪；构建与输入身份固定
stimulus:
- 三命名配置对同一向量重放全部18操作；执行配置计划的合法边界/feature on-off/Level0-2风险组合
- 最大算法与32KiB SRAM；三个DMA宽度、两个Keccak轮数、所有NTT lane及key-slot端点
- 裁剪算法后检查capability与禁止操作，无效参数走elaboration拒绝
expected_result:
- 所有保留操作逐字节一致；裁剪操作在秘密访问前拒绝且capability匹配
- 最大工作集不越界，无页别名/旧数据；运行证据逐配置绑定，elaboration不能替代等价执行
timeout_policy: 100000000 cycles per command; 3600 s process watchdog
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

刺激由 virtual sequence 协调相关 agent；观察 APB、AXI、KM、entropy 和 IRQ 的真实握手。
算法期望来自冻结独立 oracle，控制期望来自 RDL/接口契约；checker 逐事务比较并检查队列清空。
失败定位记录 test/config/seed/vector/command/首个不同字节或握手周期；超时或零比较数均失败。
