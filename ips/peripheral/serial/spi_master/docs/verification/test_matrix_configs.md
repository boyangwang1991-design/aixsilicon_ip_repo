# 参数矩阵

<!-- CONFIG_SET_META
id: CFGSET.SPI_MASTER.SMALL
strategy: boundary
parameters:
  NUM_CS: 1
  TX_FIFO_DEPTH: 4
  RX_FIFO_DEPTH: 4
  CMD_FIFO_DEPTH: 2
purpose: SMALL
END_CONFIG_SET_META -->

<!-- CONFIG_SET_META
id: CFGSET.SPI_MASTER.DEFAULT
strategy: default
parameters:
  NUM_CS: 4
  TX_FIFO_DEPTH: 32
  RX_FIFO_DEPTH: 32
  CMD_FIFO_DEPTH: 4
purpose: DEFAULT
END_CONFIG_SET_META -->

<!-- CONFIG_SET_META
id: CFGSET.SPI_MASTER.MAX
strategy: boundary
parameters:
  NUM_CS: 8
  TX_FIFO_DEPTH: 256
  RX_FIFO_DEPTH: 256
  CMD_FIFO_DEPTH: 16
purpose: MAX
END_CONFIG_SET_META -->

<!-- CONFIG_SET_META
id: CFGSET.SPI_MASTER.ASYMMETRIC
strategy: boundary
parameters:
  NUM_CS: 3
  TX_FIFO_DEPTH: 8
  RX_FIFO_DEPTH: 16
  CMD_FIFO_DEPTH: 4
purpose: ASYMMETRIC
END_CONFIG_SET_META -->

合法空间以 LRS 为准；补充逐参数非法值失败测试，不穷举全部笛卡尔积。
