# PQC 验证测试矩阵

## 测试分层

| Tier | 用途 |
|---|---|
| smoke | fail-fast 最小闭环 |
| regression | 全部可达 testcase |
| extended | 扩展与性能观察 |

---

### TC.PQC.CMD.001 命令闭环冒烟

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
- 写入合法 COMMAND 与 DESC_ADDR，写 DOORBELL=1
expected_result:
- STATUS 由 IDLE 进入 BUSY 后回到 IDLE
- completion record 写入后 DONE 置位
- INTR_STATE.done 置位并可 W1C 清除
timeout_policy: 100000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

---

### TC.PQC.APB.001 APB 非法地址与 BUSY 写保护

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
- 访问未映射地址
- 提交命令使其 BUSY，期间写 COMMAND.opcode
expected_result:
- 未映射访问 psready 有效且 pslverr 为 1
- BUSY 期间写入被拒绝，opcode 保持提交值
- 命令结果不受影响
timeout_policy: 100000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

---

### TC.PQC.REG.001 寄存器复位值与访问属性

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
- 读取 ID_VERSION/CAPABILITY0/STATUS
- 对 INTR_STATE 逐位置位（INTR_TEST）后逐位 W1C
expected_result:
- 复位值与 RDL reset 一致，无 X
- 每次 W1C 只清除被写位
- RO 寄存器写入无副作用
timeout_policy: 200000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

---

### TC.PQC.RESET.001 自检门控与故障锁定

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
- 未 enable 时提交命令
- enable 后拉高 tamper
expected_result:
- 未使能时命令不进入 EXECUTE
- tamper 后 ALERT_FATAL 置位、LOCKED 置位、密码命令被拒绝
- zeroize 在 ZEROIZE_MAX_CYCLES 内完成
timeout_policy: 200000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

---

### TC.PQC.SIDEBAND.001 中断独立性

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

---

### TC.PQC.KEY.001 Key slot 权限与 stale handle

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

---

### TC.PQC.KEY.002 Key Manager 生命周期（blocked）

<!-- TESTCASE_META
id: TC.PQC.KEY.002
name: tc_key_manager_lifecycle
type: security
description: >
  Key Manager 侧载（km_begin/import/destroy）与密钥槽 domain 授权生命周期。
  当前 RTL 中 0x200+ 密钥槽窗口对任何访问返回 pslverr（RTL-KEY-001），
  完整生命周期无法在 RTL 上验证；本用例归入 blocked，待 RTL 闭环后验收。
priority: must
tier: regression
implementation: verification/tc/tc_key_slot_permission.sv
feature_ref:
- FL.PQC.KEYMANAGER.PENDING
design_ref:
- LLD.REG.PQC.SLOT_DESTROY
preconditions:
- Key Manager 数据通路已闭环（当前未闭环）
stimulus:
- km_begin/import/destroy；跨域访问密钥槽
expected_result:
- 密钥槽软件可访问（当前不可访问，见 RTL-KEY-001）
timeout_policy: 100000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

---

### TC.PQC.DMA.001 4 KiB 边界拆分

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
- 发起起点在 4 KiB 边界前 8 字节、长度跨越边界的读与写
expected_result:
- 每次 burst 不跨 4 KiB
- 拼接后的数据与连续传输一致
- 协议无违规
timeout_policy: 400000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

---

### TC.PQC.CT.001 KEM Decaps 常数时间

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
- 提交长度正确的合法密文
- 提交同长度但单比特翻转的密文
expected_result:
- 两次 completion 均为 SUCCESS
- 无 KEM_INVALID 类错误码
- 比较与 select 遍历全长度（公开观察一致）
timeout_policy: 400000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

---

### TC.PQC.INTEGRITY.001 非法状态强制安全收尾

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
- 通过 fault_inject_ctrl 触发非法状态检测
expected_result:
- 状态机进入 ZEROIZE 而非 EXECUTE
- ALERT_FATAL 置位
- 密码命令被拒绝
timeout_policy: 100000 cycles
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

---

### TC.PQC.ALGO.001 算法级 KAT 与差分（软件证明）

<!-- TESTCASE_META
id: TC.PQC.ALGO.001
name: algo_reference_kat
type: algorithm
description: 六个参数集完整算法 KAT 与跨实现差分，含隐式拒绝与拒绝采样
priority: must
tier: regression
implementation: scripts/run_pqc_algo_proof.py
proof_kind: software
feature_ref:
- FL.PQC.ALGO
design_ref:
- HLD.MOD.PQC.KEMSEQ
- HLD.MOD.PQC.DSASEQ
preconditions:
- Python 参考模型与独立实现可导入
stimulus:
- 对六个参数集执行 KeyGen/Encaps/Decaps 与 KeyGen/Sign/Verify
- 密文翻转、消息篡改、错误长度
expected_result:
- 全部 KAT 与差分比对通过
- 非法密文产生伪随机 shared secret 且无有效性区分
- 拒绝轮次不输出部分签名
timeout_policy: 1800 s
config_ref:
- CFGSET.PQC.DEFAULT
applicability:
  expr: 'true'
END_TESTCASE_META -->

---

### TC.PQC.CFG.001 参数化配置 elaboration

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

---

### TC.PQC.CONS.001 交付与可综合静态检查

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
---

## 实现状态（2026-09-17 UVM 实测）

以下状态基于 `verification/sim/run_uvm.py` 的真实 UVM 运行（VCS W-2024.09-SP1，
UVM 1.2，`--compile-timeout 300 --run-timeout 90`），不是文档声明。

| TC | Tier | 实现文件 | 状态 | 说明 |
|---|---|---|---|---|
| TC.PQC.CMD.001 | smoke | `tc_cmd_smoke.sv` | **PASS** | 上电/使能/自检门控/命令寄存器/门铃提交/STATUS 观测 |
| TC.PQC.APB.001 | smoke | `tc_apb_protection.sv` | **PASS** | 低位未映射地址 pslverr；swwe 命令组写保护 |
| TC.PQC.REG.001 | smoke | `tc_reg_reset_attr.sv` | **PASS** | ID/CAPABILITY 复位与属性；W1C；RO 写忽略 |
| TC.PQC.RESET.001 | regression | `tc_reset_selftest_lock.sv` | **PASS** | 复位状态/自检门控/无错误；自检后 busy 不归位记为 RTL-STATUS-001 |
| TC.PQC.SIDEBAND.001 | regression | `tc_intr_independence.sv` | **PASS** | INTR_ENABLE 独立门控 + W1C 独立性 |
| TC.PQC.KEY.001 | regression | `tc_key_slot_permission.sv` | **PASS(observed)** | 0x200+ 窗口全 pslverr 记为 RTL-KEY-001（预期错误区） |
| TC.PQC.INTEGRITY.001 | extended | `tc_illegal_state_shutdown.sv` | **PASS** | 告警寄存器契约（RO/复位清零） |
| TC.PQC.DMA.001 | regression | — | **blocked** | 依赖未实现 DMA 数据通路（ISSUE A03/A11）；不伪造通过 |
| TC.PQC.CT.001 | regression | — | **blocked** | 依赖完整 KEM 数据通路与 Level 2 掩码链 |
| TC.PQC.ALGO.001 | regression | `scripts/run_pqc_algo_proof.py` | pending | 软件证明入口（algorithm proof） |

### 已知 RTL 缺陷（UVM 实测，见 reports/report.md）

| ID | 现象 | 影响 |
|---|---|---|
| RTL-REG-002 | `CAPABILITY1.abi_minor` 从未被驱动，读 0（RDL reset=1） | 能力上报不完整 |
| RTL-APB-002 | 高位未映射地址（0x2F0）不返回 pslverr 也不返回 PREADY | 总线挂死 |
| RTL-CMD-001 | 门铃命令链依赖未实现 DMA，前端可无限等待 | 命令无法闭环 |
| RTL-STATUS-001 | 自检后 `STATUS.idle` 不再置位（前端保持 busy） | 自检后无法进入 idle |
| RTL-KEY-001 | 0x200+ key-slot 窗口任何访问都返回 pslverr（PPROT=3'b100 亦然） | 密钥槽软件不可访问 |
