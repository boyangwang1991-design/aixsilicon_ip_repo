# 测试矩阵 protocol

## TC.SPI_MASTER.APB.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.APB.001
name: tc_spi_apb
type: directed
priority: must
tier: smoke
feature_ref:
- FL.SPI_MASTER.APB
implementation: verification/tc/tc_spi_apb.sv
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: APB 零等待、字节屏蔽、访问属性和副作用
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- APB 零等待、字节屏蔽、访问属性和副作用
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
## TC.SPI_MASTER.MODES.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.MODES.001
name: tc_spi_modes
type: directed
priority: must
tier: regression
feature_ref:
- FL.SPI_MASTER.MODES
implementation: verification/tc/tc_spi_modes.sv
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: 四模式、两位序、边界位宽及外部从机
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- 四模式、两位序、边界位宽及外部从机
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
## TC.SPI_MASTER.COMMANDS.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.COMMANDS.001
name: tc_spi_commands
type: directed
priority: must
tier: regression
feature_ref:
- FL.SPI_MASTER.COMMANDS
implementation: verification/tc/tc_spi_commands.sv
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: 五种命令、快照、队列和 CS 链
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- 五种命令、快照、队列和 CS 链
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
## TC.SPI_MASTER.FIFO_STALL.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.FIFO_STALL.001
name: tc_spi_fifo_stall
type: directed
priority: must
tier: regression
feature_ref:
- FL.SPI_MASTER.FIFO_STALL
implementation: verification/tc/tc_spi_fifo_stall.sv
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: FIFO 边界、长流、资源等待
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- FIFO 边界、长流、资源等待
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
## TC.SPI_MASTER.RECOVERY.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.RECOVERY.001
name: tc_spi_recovery
type: directed
priority: must
tier: regression
feature_ref:
- FL.SPI_MASTER.RECOVERY
implementation: verification/tc/tc_spi_recovery.sv
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: 安全中止、故障和软硬复位
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- 安全中止、故障和软硬复位
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
