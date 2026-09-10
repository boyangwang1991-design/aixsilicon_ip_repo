# QUEUES

同步 TX/RX/命令队列及清除胶水；复用 sync_fifo。

<!-- HLD_MODULE_META
id: HLD.MOD.SPI_MASTER.QUEUES
name: QUEUES
responsibility: 同步 TX/RX/命令队列及清除胶水；复用 sync_fifo
inputs: [pclk, rst_n, clear, push, pop, write_data]
outputs: [head_data, occupancy, full, empty]
req_ref:
- LRS.FUNC.SPI_MASTER.FIFO.001
- LRS.FUNC.SPI_MASTER.FIFO.002
- LRS.FUNC.SPI_MASTER.FIFO.003
- LRS.FUNC.SPI_MASTER.FIFO.004
- LRS.LP.SPI_MASTER.PPA.001
- LRS.CFG.SPI_MASTER.PAR.001
- LRS.CFG.SPI_MASTER.PAR.002
- LRS.CFG.SPI_MASTER.PAR.003
- LRS.CFG.SPI_MASTER.PAR.004
applicability:
  expr: 'true'
END_HLD_MODULE_META -->
