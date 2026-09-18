# PQC 安全与身份断言计划

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
