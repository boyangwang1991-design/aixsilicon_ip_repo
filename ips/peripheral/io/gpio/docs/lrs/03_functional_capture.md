# GPIO LRS：快照与Strap（1）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.FUNC.GPIO.CAP001.001

<!-- LRS_META
id: LRS.FUNC.GPIO.CAP001.001
category: FUNC
feature: cap001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-CAP-001
applicability:
  expr: SNAPSHOT_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-CAP-001 定义的场景下，SNAPSHOT_CMD bit0 或 snapshot_req_i 触发时，同一主边沿捕获所有 Bank 的边沿前 IN_DATA 与 IN_VALID。

#### Acceptance Criteria

- SNAPSHOT_CMD bit0 或 snapshot_req_i 触发时，同一主边沿捕获所有 Bank 的边沿前 IN_DATA 与 IN_VALID。
- 检查同拍触发、首次/重复/过早请求、SEQ 回绕及暖复位，比较数据和有效位。

### LRS.FUNC.GPIO.CAP001.002

<!-- LRS_META
id: LRS.FUNC.GPIO.CAP001.002
category: FUNC
feature: cap001
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-CAP-001
applicability:
  expr: SNAPSHOT_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-CAP-001 定义的场景下，软件读 SNAP_DATA/SNAP_VALID 为冻结值；SNAP_SEQ 加 1（32-bit 回绕）。同拍软硬件请求合并一次；允许下一拍覆盖，SEQ 用于检测读取期间更新。

#### Acceptance Criteria

- 软件读 SNAP_DATA/SNAP_VALID 为冻结值；SNAP_SEQ 加 1（32-bit 回绕）。同拍软硬件请求合并一次；允许下一拍覆盖，SEQ 用于检测读取期间更新。
- 检查同拍触发、首次/重复/过早请求、SEQ 回绕及暖复位，比较数据和有效位。

### LRS.FUNC.GPIO.CAP002.001

<!-- LRS_META
id: LRS.FUNC.GPIO.CAP002.001
category: FUNC
feature: cap002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-CAP-002
applicability:
  expr: STRAP_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-CAP-002 定义的场景下，Strap 使用 IN_SYNC 的物理值，忽略 IN_INV/滤波/去抖；仅在所有 INPUT_CAP_MASK 指定输入均处于可用且同步填充完成后接受第一次 strap_sample_i=1。

#### Acceptance Criteria

- Strap 使用 IN_SYNC 的物理值，忽略 IN_INV/滤波/去抖；仅在所有 INPUT_CAP_MASK 指定输入均处于可用且同步填充完成后接受第一次 strap_sample_i=1。
- 检查同拍触发、首次/重复/过早请求、SEQ 回绕及暖复位，比较数据和有效位。

### LRS.FUNC.GPIO.CAP002.002

<!-- LRS_META
id: LRS.FUNC.GPIO.CAP002.002
category: FUNC
feature: cap002
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-CAP-002
applicability:
  expr: STRAP_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-CAP-002 定义的场景下，捕获 STRAP_DATA、STRAP_VALID=1，之后忽略请求直至主域复位。过早请求忽略并置 FAULT_STATUS.STRAP_EARLY，软件/启动逻辑须重新请求。

#### Acceptance Criteria

- 捕获 STRAP_DATA、STRAP_VALID=1，之后忽略请求直至主域复位。过早请求忽略并置 FAULT_STATUS.STRAP_EARLY，软件/启动逻辑须重新请求。
- 检查同拍触发、首次/重复/过早请求、SEQ 回绕及暖复位，比较数据和有效位。

### LRS.FUNC.GPIO.CAP003.001

<!-- LRS_META
id: LRS.FUNC.GPIO.CAP003.001
category: FUNC
feature: cap003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-CAP-003
applicability:
  expr: STRAP_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-CAP-003 定义的场景下，Strap 只能用于主域时钟和复位已可用后的配置读取。

#### Acceptance Criteria

- Strap 只能用于主域时钟和复位已可用后的配置读取。
- 检查同拍触发、首次/重复/过早请求、SEQ 回绕及暖复位，比较数据和有效位。

### LRS.FUNC.GPIO.CAP003.002

<!-- LRS_META
id: LRS.FUNC.GPIO.CAP003.002
category: FUNC
feature: cap003
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-CAP-003
applicability:
  expr: STRAP_EN == 1
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-CAP-003 定义的场景下，决定主时钟/复位释放本身的启动 Strap 必须由专用 Boot/AON 模块承担。

#### Acceptance Criteria

- 决定主时钟/复位释放本身的启动 Strap 由专用 Boot/AON 模块承担。
- 检查同拍触发、首次/重复/过早请求、SEQ 回绕及暖复位，比较数据和有效位。

