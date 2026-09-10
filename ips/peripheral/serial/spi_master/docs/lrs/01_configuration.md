# 静态参数合同

| Parameter | Kind | Type | Default | Legal Values | 对应需求 ID |
|---|---|---|---|---|---|
| NUM_CS | elaboration | int | 4 | 1..8 | LRS.CFG.SPI_MASTER.PAR.001 |
| TX_FIFO_DEPTH | elaboration | int | 32 | [4, 8, 16, 32, 64, 128, 256] | LRS.CFG.SPI_MASTER.PAR.002 |
| RX_FIFO_DEPTH | elaboration | int | 32 | [4, 8, 16, 32, 64, 128, 256] | LRS.CFG.SPI_MASTER.PAR.003 |
| CMD_FIFO_DEPTH | elaboration | int | 4 | [2, 4, 8, 16] | LRS.CFG.SPI_MASTER.PAR.004 |

<!-- CONFIG_META
id: CFG_SMALL
purpose: SMALL
values:
  NUM_CS: 1
  TX_FIFO_DEPTH: 4
  RX_FIFO_DEPTH: 4
  CMD_FIFO_DEPTH: 2
END_CONFIG_META -->

<!-- CONFIG_META
id: CFG_DEFAULT
purpose: DEFAULT
values:
  NUM_CS: 4
  TX_FIFO_DEPTH: 32
  RX_FIFO_DEPTH: 32
  CMD_FIFO_DEPTH: 4
END_CONFIG_META -->

<!-- CONFIG_META
id: CFG_MAX
purpose: MAX
values:
  NUM_CS: 8
  TX_FIFO_DEPTH: 256
  RX_FIFO_DEPTH: 256
  CMD_FIFO_DEPTH: 16
END_CONFIG_META -->

<!-- CONFIG_META
id: CFG_ASYMMETRIC
purpose: ASYMMETRIC
values:
  NUM_CS: 3
  TX_FIFO_DEPTH: 8
  RX_FIFO_DEPTH: 16
  CMD_FIFO_DEPTH: 4
END_CONFIG_META -->
