# FIFO 需求


### LRS.FUNC.SPI_MASTER.FIFO.001

<!-- LRS_META
id: LRS.FUNC.SPI_MASTER.FIFO.001
category: FUNC
feature: FIFO-001
priority: P0
status: active
source_ref:
- spi_master_contract.md#FIFO-001
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

TXDATA 成功写入恰好一 entry；RXDATA 成功读取恰好一 entry。TX 满写和 RX 空读立即 PSLVERR，保持 FIFO 原状，置错误标志。禁止静默丢弃或返回上次数据伪装成功。

#### Acceptance Criteria

- 对照原合同 FIFO-001 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。

### LRS.FUNC.SPI_MASTER.FIFO.002

<!-- LRS_META
id: LRS.FUNC.SPI_MASTER.FIFO.002
category: FUNC
feature: FIFO-002
priority: P0
status: active
source_ref:
- spi_master_contract.md#FIFO-002
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

TX_LEVEL/RX_LEVEL 是实际队列 occupancy，不含移位寄存器；CMD_LEVEL 不含活动命令。预留的 RX 槽可减少可用空间，但不得增加软件可读 RX_LEVEL。软件只能读取完整 frame。

#### Acceptance Criteria

- 对照原合同 FIFO-002 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。

### LRS.FUNC.SPI_MASTER.FIFO.003

<!-- LRS_META
id: LRS.FUNC.SPI_MASTER.FIFO.003
category: FUNC
feature: FIFO-003
priority: P0
status: active
source_ref:
- spi_master_contract.md#FIFO-003
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

判断本次 APB 操作是否合法，以提交沿之前 occupancy 为准。满 TX 与硬件同沿 pop 时仍拒绝写；空 RX 与硬件同沿 push 时仍拒绝读。非满/非空时允许同时 push/pop，计数和顺序正确。CMD FIFO 满与同沿出队采用相同保守规则。

#### Acceptance Criteria

- 对照原合同 FIFO-003 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。

### LRS.FUNC.SPI_MASTER.FIFO.004

<!-- LRS_META
id: LRS.FUNC.SPI_MASTER.FIFO.004
category: FUNC
feature: FIFO-004
priority: P0
status: active
source_ref:
- spi_master_contract.md#FIFO-004
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

清 FIFO 只允许 ENABLE=0、BUSY=0；分别支持 TX/RX/CMD clear。RX 读取不改变命令进度；额外 TX 数据不自动发出，保留供后续命令使用。软件负责 entry 数量和描述符之间的对应关系。

#### Acceptance Criteria

- 对照原合同 FIFO-004 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。
