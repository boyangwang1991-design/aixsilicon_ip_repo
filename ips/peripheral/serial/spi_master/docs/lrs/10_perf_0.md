# PERF 需求


### LRS.PERF.SPI_MASTER.PERF.001

<!-- LRS_META
id: LRS.PERF.SPI_MASTER.PERF.001
category: PERF
feature: PERF-001
priority: P0
status: active
source_ref:
- spi_master_contract.md#PERF-001
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

目标为同段正常资源条件下零额外帧间 bubble（FRAME_GAP=0）；最大逻辑 SPI 频率 PCLK/2。报告必须分别列 PCLK 约束、SPI 分频和外部接口可签核的最大 SCLK，不以仿真频率代替物理承诺。

#### Acceptance Criteria

- 对照原合同 PERF-001 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。

### LRS.PERF.SPI_MASTER.PERF.002

<!-- LRS_META
id: LRS.PERF.SPI_MASTER.PERF.002
category: PERF
feature: PERF-002
priority: P0
status: active
source_ref:
- spi_master_contract.md#PERF-002
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

8-bit、PCLK/2 时，一帧 16 PCLK。无额外总线等待的 APB 32-bit 访问最少两 PCLK，因此全双工每帧一次写加一次读至少消耗 4 PCLK 总线时间，尚未包含 CPU 指令、仲裁和中断延迟。1-bit 帧时不能依赖 APB 持续达到同样最大串行速率。

#### Acceptance Criteria

- 对照原合同 PERF-002 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。

### LRS.PERF.SPI_MASTER.PERF.003

<!-- LRS_META
id: LRS.PERF.SPI_MASTER.PERF.003
category: PERF
feature: PERF-003
priority: P0
status: active
source_ref:
- spi_master_contract.md#PERF-003
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

驱动服务预算按 entry 消耗率计算。数据帧 entry rate 约为 `f_sclk / FRAME_BITS`（忽略 gap）；TX 剩余 entry 或 RX 剩余空间所提供时间约为 `entry_count × FRAME_BITS / f_sclk`。选择水位时预留最坏服务延迟，不以平均延迟设计。

#### Acceptance Criteria

- 对照原合同 PERF-003 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。

### LRS.PERF.SPI_MASTER.PERF.004

<!-- LRS_META
id: LRS.PERF.SPI_MASTER.PERF.004
category: PERF
feature: PERF-004
priority: P0
status: active
source_ref:
- spi_master_contract.md#PERF-004
applicability:
  expr: 'true'
verification_method:
- simulation
- review
END_LRS_META -->

#### Requirement

应交付至少 NUM_CS=1、FIFO=4 的小配置，默认配置，以及 NUM_CS=8、FIFO=256、CMD=16 的边界配置综合结果。当前未指定工艺库、Pad、PCLK 和负载，面积、功耗、最高实际 SCLK 不填写虚构指标，项目集成时补充目标。

#### Acceptance Criteria

- 对照原合同 PERF-004 的全部条件，检查可观察结果及异常路径；不得以成功通路替代边界检查。
