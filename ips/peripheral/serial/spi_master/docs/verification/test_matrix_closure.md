# 测试矩阵 closure

## TC.SPI_MASTER.IRQ.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.IRQ.001
name: tc_spi_irq
type: directed
priority: must
tier: regression
feature_ref:
- FL.SPI_MASTER.IRQ
implementation: verification/tc/tc_spi_irq.sv
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: 事件、水位、屏蔽、W1C
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- 事件、水位、屏蔽、W1C
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
## TC.SPI_MASTER.EXTENDED.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.EXTENDED.001
name: tc_spi_extended
type: directed
priority: must
tier: regression
feature_ref:
- FL.SPI_MASTER.EXTENDED
implementation: verification/tc/tc_spi_extended.sv
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: 精确时序、最大计时值、MISO 延迟
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- 精确时序、最大计时值、MISO 延迟
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
## TC.SPI_MASTER.RANDOM.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.RANDOM.001
name: tc_spi_random
type: random
priority: must
tier: regression
feature_ref:
- FL.SPI_MASTER.RANDOM
implementation: verification/tc/tc_spi_random.sv
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: 随机配置和数据
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- 随机配置和数据
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
## TC.SPI_MASTER.RACES.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.RACES.001
name: tc_spi_races
type: directed
priority: must
tier: regression
feature_ref:
- FL.SPI_MASTER.RACES
implementation: verification/tc/tc_spi_races.sv
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: 完成/W1C 同沿、复位阶段
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- 完成/W1C 同沿、复位阶段
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
## TC.SPI_MASTER.DELIVERY.001

<!-- TESTCASE_META
id: TC.SPI_MASTER.DELIVERY.001
name: tc_spi_delivery
type: static
priority: must
tier: regression
feature_ref:
- FL.SPI_MASTER.DELIVERY
implementation: scripts/check_delivery.py
config_ref:
- CFGSET.SPI_MASTER.SMALL
- CFGSET.SPI_MASTER.DEFAULT
- CFGSET.SPI_MASTER.MAX
- CFGSET.SPI_MASTER.ASYMMETRIC
description: 软件、参数空间、静态集成和交付
stimulus:
- 执行对应测试组的有界场景，逐次比较引脚、CSR、计数和错误状态
expected_result:
- 软件、参数空间、静态集成和交付
timeout_policy: 180 seconds; bounded status polling
END_TESTCASE_META -->
