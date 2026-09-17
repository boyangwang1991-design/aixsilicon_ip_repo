# PQC 验证断言与形式化检查计划

## 断言

### ASSERT.PQC.CLKRESET.001 单时钟域与复位极性

<!-- ASSERTION_META
id: ASSERT.PQC.CLKRESET.001
name: a_single_clock_domain
feature_ref:
- FL.PQC.CLKRESET
design_ref:
- LLD.RST.PQC.MAIN
property: 所有时序元件由同一 clk 驱动，rst_n 为低有效异步复位且同步释放
severity: error
verification_method: static
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

静态结构分析 + 复位释放时序检查。

#### Property Intent

设计只声明单一时钟域与单一异步低有效复位（LRS.RESET.PQC.CLK.001、
LRS.INTF.PQC.CLKRESET.001）。

#### Failure Meaning

存在未声明的时钟域或错误复位极性，集成时会出现亚稳态或复位失效。

---

### ASSERT.PQC.ENTROPY.001 熵请求授权门控

<!-- ASSERTION_META
id: ASSERT.PQC.ENTROPY.001
name: a_entropy_gated
feature_ref:
- FL.PQC.ENTROPY
design_ref:
- LLD.CDC.PQC.ENTROPY
property: entropy_ready 只可在算法执行且熵 health 正常时置位，且 domain tag 与命令匹配
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

任意时钟沿观察 `entropy_ready`。

#### Property Intent

随机数只能来自批准路径，health 异常时立即停止（LRS.INTF.PQC.ENTROPY.001）。

#### Failure Meaning

可能在熵失效后继续消费随机数，破坏密钥质量。

---

### ASSERT.PQC.PERF.001 无算法级软件回退

<!-- ASSERTION_META
id: ASSERT.PQC.PERF.001
name: a_no_software_fallback
feature_ref:
- FL.PQC.PERF
design_ref:
- LLD.PPA.PQC.POLY
property: 命令完成不产生需要软件续算的中间状态；性能计数器不暴露签名尝试次数
severity: error
verification_method: static
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

静态检查命令完成路径与性能计数器读出字段清单。

#### Property Intent

任一参数集不得依赖软件执行 NTT/采样/pack/unpack/重加密比较
（LRS.PERF.PQC.NOSW.001），且生产模式不泄露秘密相关细粒度事件。

#### Failure Meaning

实时性与安全前提被破坏，且可能引入侧信道。

---

### ASSERT.PQC.DFX.001 秘密不进入可观测路径

<!-- ASSERTION_META
id: ASSERT.PQC.DFX.001
name: a_no_secret_observability
feature_ref:
- FL.PQC.DFX
design_ref:
- HLD.SAFETY.PQC.DFXTEST
property: scan chain、MBIST 端口与 debug/trace 出口不得承载密钥或秘密中间态
severity: error
verification_method: static
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

静态审查 scan 排除清单、MBIST 使能序列与 debug 可观察信号清单。

#### Property Intent

秘密寄存器与 key RAM 不进入普通扫描链，MBIST 前后受控清零且不泄露 retained key
（LRS.DFX.PQC.SCAN.001、LRS.DFX.PQC.MBIST.001、LRS.DFX.PQC.DEBUG.001）。

#### Failure Meaning

测试机制成为秘密泄露通道。

---

### ASSERT.PQC.RESET.001 复位后合法初始状态

<!-- ASSERTION_META
id: ASSERT.PQC.RESET.001
name: a_reset_initial_state
feature_ref:
- FL.PQC.RESET
design_ref:
- LLD.FSM.PQC.TOP.MAIN
property: rst_n 释放后顶层 FSM 必须处于 DISABLED，且不得处于 EXECUTE
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

`$rose(rst_n)` 后第一拍。

#### Property Intent

复位定义明确且可复现，避免未定义初值进入执行态。

#### Failure Meaning

复位电路或状态编码错误，可能让器件上电即处于执行态。

---

### ASSERT.PQC.CMD.001 完成写序

<!-- ASSERTION_META
id: ASSERT.PQC.CMD.001
name: a_completion_order
feature_ref:
- FL.PQC.CMD
design_ref:
- LLD.FSM.PQC.TOP.MAIN
property: DONE 置位时 completion record 必须已经写入，且 COMMIT 前无输出可见
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

`fe_fsm_state` 进入 COMPLETE。

#### Property Intent

软件观察到 DONE 时所需信息已全部可见；COMMIT 前不泄露部分结果。

#### Failure Meaning

软件可能读到陈旧或不完整结果。

---

### ASSERT.PQC.SIDEBAND.001 W1C 不丢事件

<!-- ASSERTION_META
id: ASSERT.PQC.SIDEBAND.001
name: a_w1c_set_wins
feature_ref:
- FL.PQC.SIDEBAND
design_ref:
- LLD.REG.PQC.INTR_STATE
property: INTR_STATE 同周期 HW set 与 SW W1C 冲突时结果必须为置位
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

`hwif_in.INTR_STATE.*.hwset` 与 APB 写同周期。

#### Property Intent

事件不丢失（LLD 冻结 set_wins 优先序）。

#### Failure Meaning

中断事件丢失，导致软件漏处理。

---

### ASSERT.PQC.APB.001 BUSY 写保护

<!-- ASSERTION_META
id: ASSERT.PQC.APB.001
name: a_busy_write_block
feature_ref:
- FL.PQC.APB
design_ref:
- LLD.REG.PQC.COMMAND
property: BUSY 期间对受保护字段的写必须被拒绝（swwe=0）且字段值不变
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

`busy && s_apb_pwrite` 命中受保护地址。

#### Property Intent

运行中命令参数不可被篡改。

#### Failure Meaning

命令结果可能被软件写入破坏。

---

### ASSERT.PQC.CT.001 无秘密相关选择

<!-- ASSERTION_META
id: ASSERT.PQC.CT.001
name: a_no_secret_select
feature_ref:
- FL.PQC.CT
design_ref:
- LLD.SAFE.PQC.CT_SELECT
property: 任何对外可观察的错误码、DMA 地址或授权可见状态不得由 secret-tainted 信号控制
severity: error
verification_method: formal
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

形式化 taint 分析，起点为秘密数据源。

#### Property Intent

常数时间与访问模式要求（LRS.SEC.PQC.CT.001）。

#### Failure Meaning

存在侧信道泄露路径，产品安全等级不成立。

---

### ASSERT.PQC.INTEGRITY.001 非法状态安全收尾

<!-- ASSERTION_META
id: ASSERT.PQC.INTEGRITY.001
name: a_illegal_state_shutdown
feature_ref:
- FL.PQC.INTEGRITY
design_ref:
- LLD.SAFE.PQC.CTRL_SPARSE
property: 状态编码非法或多热时，下一状态必须是 ZEROIZE，且不得进入 EXECUTE
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

`state_illegal` 有效。

#### Property Intent

单比特故障不能把 LOCKED/ZEROIZE 跳到 EXECUTE。

#### Failure Meaning

故障注入可绕过安全状态。

---

### ASSERT.PQC.RESET.002 零化有界完成

<!-- ASSERTION_META
id: ASSERT.PQC.RESET.002
name: a_zeroize_bounded
feature_ref:
- FL.PQC.RESET
design_ref:
- LLD.RST.PQC.ZEROPATH
property: zeroize_req 有效后，zeroize_done 必须在 ZEROIZE_MAX_CYCLES 内出现，且不依赖主 FSM 状态
severity: error
verification_method: formal
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

`zeroize_req` 上升沿，任意 FSM 状态。

#### Property Intent

无死锁与有界完成（LRS.SEC.PQC.ZEROIZE.001）。

#### Failure Meaning

零化可能不完成，秘密长期驻留。

---

### ASSERT.PQC.KEY.001 无私有导出路径

<!-- ASSERTION_META
id: ASSERT.PQC.KEY.001
name: a_no_key_export
feature_ref:
- FL.PQC.KEY
design_ref:
- LLD.REG.PQC.SLOT_META
property: key slot 的私钥字节不得出现在任何 APB 读数据路径上
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

任何 APB 读事务。

#### Property Intent

私钥不可导出（LRS.SEC.PQC.SLOT.002）。

#### Failure Meaning

私钥可能经寄存器路径泄露。

---

### ASSERT.PQC.DMA.001 不跨 4 KiB

<!-- ASSERTION_META
id: ASSERT.PQC.DMA.001
name: a_no_4k_cross
feature_ref:
- FL.PQC.DMA
design_ref:
- LLD.TIMING.PQC.DMA.SPLIT
property: 任一 AXI burst 不得跨越 4 KiB 边界
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

#### Trigger

`m_ar_valid` / `m_aw_valid` 有效。

#### Property Intent

AXI4 合规与互操作（LRS.INTF.PQC.DMA.001）。

#### Failure Meaning

互联或从端可能拒绝或误处理传输。

---

## 形式化检查项

| 项 | 目标 | 方法 |
|---|---|---|
| NTT/INTT round-trip | 系数范围与可逆性 | 等价/形式 |
| 模约减范围 | lazy range 不溢出 | 形式 |
| codec round-trip | bit pack/unpack 与 Compress/Decompress 一致 | 形式 |
| hint 性质 | MakeHint/UseHint 一致性与权重界 | 形式 |
| secret taint | 秘密不控制外部可观察量 | taint 形式 |
| zeroize 有界 | 无死锁、有界完成 | 活性形式 |
| FIFO 边界 | overflow/underflow 不越界 | 形式 |

## 覆盖点（断言相关）

见 [`coverage_plan.md`](coverage_plan.md) 的安全关键 FSM 与 error path 100% 要求。