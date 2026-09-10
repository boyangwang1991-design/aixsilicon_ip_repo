# STALL 需求


### LRS.FUNC.SPI_MASTER.STALL.001

<!-- LRS_META
id: LRS.FUNC.SPI_MASTER.STALL.001
category: FUNC
feature: STALL-001
priority: P0
status: active
source_ref:
- spi_master_contract.md#STALL-001
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

ALLOW_STALL=1 时，资源不足在下一帧开始前暂停；SCLK 保持 CPOL。若事务已开始则 CS 保持有效；补数/读取 RX 后继续，不重复、不跳过 frame。

#### Acceptance Criteria

- 对照原合同 STALL-001 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。

### LRS.FUNC.SPI_MASTER.STALL.002

<!-- LRS_META
id: LRS.FUNC.SPI_MASTER.STALL.002
category: FUNC
feature: STALL-002
priority: P0
status: active
source_ref:
- spi_master_contract.md#STALL-002
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

ALLOW_STALL=0 时，任何需要启动 frame 却资源未及时就绪的情况视为资源错误；不发送伪造数据、不覆盖 RX，进入故障恢复。首帧条件不足也属于错误。此选项不是吞吐保证，驱动仍须满足供数及排空条件。

#### Acceptance Criteria

- 对照原合同 STALL-002 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。

### LRS.FUNC.SPI_MASTER.STALL.003

<!-- LRS_META
id: LRS.FUNC.SPI_MASTER.STALL.003
category: FUNC
feature: STALL-003
priority: P0
status: active
source_ref:
- spi_master_contract.md#STALL-003
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

WAIT_TIMEOUT 为 32 位 PCLK 周期数，0 关闭。仅统计 WAIT_TX/WAIT_RX/WAIT_CMD 连续无进展时间；等待原因切换不清计数。达到非零阈值则 WAIT_TIMEOUT 错误。若同沿出现可执行进展和超时，进展优先；计数清零。CS setup/hold/idle、合法 frame 和 FRAME_GAP 不计入。

#### Acceptance Criteria

- 对照原合同 STALL-003 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。

### LRS.FUNC.SPI_MASTER.STALL.004

<!-- LRS_META
id: LRS.FUNC.SPI_MASTER.STALL.004
category: FUNC
feature: STALL-004
priority: P0
status: active
source_ref:
- spi_master_contract.md#STALL-004
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

无等待超时不代表外部器件响应正常。SPI 没有通用 ACK；MISO 固定 0/1、外设未接、器件内部忙或返回错误数据不能由本 IP 自动判定为超时。软件仍应使用完整操作期限和器件状态检查。

#### Acceptance Criteria

- 对照原合同 STALL-004 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。
