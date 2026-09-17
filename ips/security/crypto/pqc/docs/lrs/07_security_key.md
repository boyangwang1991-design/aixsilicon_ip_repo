# PQC LRS：密钥管理与权限需求

### LRS.SEC.PQC.SLOT.001 Key slot 元数据

<!-- LRS_META
id: LRS.SEC.PQC.SLOT.001
category: SEC
feature: key_slot_meta
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.5
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

key slot 元数据应包含 owner/domain、algorithm、parameter set、usage mask、exportable、
valid、version，并在每次操作前被校验。

#### Acceptance Criteria

- 元数据不全或类型不匹配时操作被拒绝；
- usage mask 生效；
- version 变化使旧 handle 失效。

---

### LRS.SEC.PQC.SLOT.002 私钥不可导出

<!-- LRS_META
id: LRS.SEC.PQC.SLOT.002
category: SEC
feature: key_no_export
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.5
- pqc_contract.md#§20.5
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

长期密钥所有权应由外部 Key Manager 管理。PQC 内应保留工作态安全 Key RAM，
只允许当前授权操作消费私钥。私钥导入应走专用 sideload/安全导入接口，
不得通过普通 AXI DMA 或 descriptor 提供材料；默认不得经 APB、DMA、PIO 或 debug 读回。
KeyGen 新生成私钥的受控托管与普通读回不同，必须满足 SLOT.008 的专用交接要求。

#### Acceptance Criteria

- 私钥 slot 不可被普通读命令读出；
- descriptor 无法指定私钥导出；
- 导出尝试被拒绝并记录。

---

### LRS.SEC.PQC.SLOT.003 Key handle 生成与失效

<!-- LRS_META
id: LRS.SEC.PQC.SLOT.003
category: SEC
feature: key_handle
priority: P0
status: active
source_ref:
- pqc_contract.md#§20.5
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

key handle 应编码 generation 与 slot；slot 被 destroy/reallocate 时 generation 应递增，
旧 handle 必须失败。操作开始后硬件应锁住 slot，防止并发销毁。

#### Acceptance Criteria

- stale handle 被拒绝；
- 并发 destroy 不能破坏执行中的操作；
- fatal/zeroize 可强制抢占锁定。

---

### LRS.SEC.PQC.SLOT.004 Debug 与生命周期约束

<!-- LRS_META
id: LRS.SEC.PQC.SLOT.004
category: SEC
feature: debug_lifecycle
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.5
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

debug 解锁不应自动开放 key RAM；RMA/测试生命周期应先销毁密钥。秘密数据写入后禁止
debug 读取。

#### Acceptance Criteria

- debug 解锁不改变 key slot 可读性；
- 生命周期变化触发密钥销毁；
- debug 读秘密返回定义值且被记录。

---

### LRS.SEC.PQC.SLOT.005 DMA 属性与地址窗口

<!-- LRS_META
id: LRS.SEC.PQC.SLOT.005
category: SEC
feature: dma_security
priority: P0
status: active
source_ref:
- pqc_contract.md#§7.5
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

DMA 请求应携带安全/特权属性；地址窗口应由 IOMMU/安全防火墙与 IP 内部范围检查双重约束。
buffer 过小或越界访问应在写入前被拒绝。

#### Acceptance Criteria

- 每次 DMA 携带属性字段；
- IP 内部范围检查独立生效；
- 越界在写入前被拒绝。

---

### LRS.SEC.PQC.SLOT.006 工作态密钥完整导入

<!-- LRS_META
id: LRS.SEC.PQC.SLOT.006
category: SEC
feature: work_key_import
priority: P0
status: active
source_ref:
- pqc_contract.md#§3.2
- docs/lrs/00_document_control.md#用户决定
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

专用导入应绑定完整 handle、算法、参数集、用途及授权域。仅当完整长度、结束标记与存储完整性检查通过后，工作态私钥才可用于命令；失败或中断的导入不得留下可使用的部分密钥。

#### Acceptance Criteria

- 六参数集分别检查正确长度、短包、长包、提前/缺失结束标记；
- handle、算法、参数集、用途或授权域不匹配时禁止执行；
- 背压期间导入材料稳定；导入未完成时不得报告密钥就绪。


---

### LRS.SEC.PQC.SLOT.007 工作态密钥退休与撤销

<!-- LRS_META
id: LRS.SEC.PQC.SLOT.007
category: SEC
feature: work_key_retire
priority: P0
status: active
source_ref:
- pqc_contract.md#§3.2
- docs/lrs/00_document_control.md#用户决定
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

命令退休、撤销、异常、生命周期转换及全局 zeroize 应使工作态密钥立即失去使用资格，并清除残留材料；清除完成前不得重新发布或覆盖为有效密钥。外部长期密钥不得因工作态副本退休而隐式销毁。

#### Acceptance Criteria

- 运行中撤销应抢占密码操作，禁止继续输出敏感结果；
- 覆盖全部密钥存储及读出暂存后才确认清除完成；
- 导入与撤销同拍时撤销优先；外部 Key Manager 的所有权不变。


---

### LRS.SEC.PQC.SLOT.008 KeyGen 向 Key Manager 托管

<!-- LRS_META
id: LRS.SEC.PQC.SLOT.008
category: SEC
feature: keygen_custody
priority: P0
status: active
source_ref:
- pqc_contract.md#§3.2
- docs/lrs/00_document_control.md#用户决定
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

KeyGen 生成的私钥应通过专用、受授权的安全交接交给外部 Key Manager，普通输出仅允许公钥与不透明 handle。默认通用私钥读回仍应关闭；专用交接不得成为任意已有私钥导出命令。仅外部 Key Manager 确认完整接收并建立所有权后，KeyGen 才可提交成功 completion。

#### Acceptance Criteria

- 专用接收端背压时不得提前报告 KeyGen 成功；
- 拒收、截断、撤销或错误确认应使 KeyGen 失败并清除工作态副本；
- APB、普通 AXI DMA、PIO 和 debug 不出现私钥材料；
- 六参数集均验证托管字节与标准编码一致，并在确认前隐藏待提交 handle。
