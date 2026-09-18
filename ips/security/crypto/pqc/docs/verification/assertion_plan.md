# PQC 协议、复位与完成断言计划

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

### ASSERT.PQC.RESET.002 零化有界完成

<!-- ASSERTION_META
id: ASSERT.PQC.RESET.002
name: a_zeroize_bounded
feature_ref:
- FL.PQC.RESET
design_ref:
- LLD.RST.PQC.ZEROPATH
property: zeroize_req 后本地物理清除在冻结预算内完成；全局 done 还要求已接受 AXI 事务真实排空；外部永久阻塞时超时锁定且不得伪造 ack
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

## SVA 实现与形式假设

属性统一由 `verification/assertions/` bind checker 实现，加入唯一 FuseSoC fileset；
目前 META 是计划，不表示已有 bind 或证明。每属性提供触发cover、失败定位与fixture。
正常协议稳定性检查在 cold reset 时 disable；安全清除同拍屏蔽属性不能被 zeroize
本身 disable。异步输入先按 LLD 同步边界观察，不对原始输入虚构核心拍对齐。

zeroize 本地有界证明不依赖主FSM；AXI全局排空必须假设已展示请求最终被接受且
从端有界响应。另做无公平性反例测试，要求锁定且不假成功。形式约束/深度/工具
版本/未证明点随日志保存，bounded PASS不宣称无界活性。
