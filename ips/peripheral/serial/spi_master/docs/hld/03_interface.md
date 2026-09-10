# 接口与数据流

APB 请求完成后才改变配置或队列；响应不等待串行状态。SPI 接口为专用推挽。

<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.SPI_MASTER.APB
name: APB
scope: external
protocol: APB4
role: slave
owner_module: HLD.MOD.SPI_MASTER.CSR
signals:
- name: pclk
  direction: input
  width: 1
  clock: pclk
  reset: preset_n
- name: preset_n
  direction: input
  width: 1
  clock: pclk
  reset: preset_n
- name: psel
  direction: input
  width: 1
  clock: pclk
  reset: preset_n
- name: penable
  direction: input
  width: 1
  clock: pclk
  reset: preset_n
- name: pwrite
  direction: input
  width: 1
  clock: pclk
  reset: preset_n
- name: paddr
  direction: input
  width: 12
  clock: pclk
  reset: preset_n
- name: pwdata
  direction: input
  width: 32
  clock: pclk
  reset: preset_n
- name: pstrb
  direction: input
  width: 4
  clock: pclk
  reset: preset_n
- name: pprot
  direction: input
  width: 3
  clock: pclk
  reset: preset_n
- name: prdata
  direction: output
  width: 32
  clock: pclk
  reset: preset_n
- name: pready
  direction: output
  width: 1
  clock: pclk
  reset: preset_n
- name: pslverr
  direction: output
  width: 1
  clock: pclk
  reset: preset_n
req_ref:
- LRS.INTF.SPI_MASTER.IF.002
END_HLD_INTERFACE_META -->
<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.SPI_MASTER.SPI
name: SPI
scope: external
protocol: SPI
role: master
owner_module: HLD.MOD.SPI_MASTER.ENGINE
signals:
- name: spi_sclk_o
  direction: output
  width: 1
  clock: pclk
  reset: preset_n
- name: spi_mosi_o
  direction: output
  width: 1
  clock: pclk
  reset: preset_n
- name: spi_miso_i
  direction: input
  width: 1
  clock: pclk
  reset: preset_n
- name: spi_cs_n_o
  direction: output
  width: NUM_CS
  clock: pclk
  reset: preset_n
req_ref:
- LRS.INTF.SPI_MASTER.IF.002
END_HLD_INTERFACE_META -->
<!-- HLD_INTERFACE_META
id: HLD.IF.EXT.SPI_MASTER.IRQ
name: IRQ
scope: external
protocol: event
role: master
owner_module: HLD.MOD.SPI_MASTER.CSR
signals:
- name: irq_o
  direction: output
  width: 1
  clock: pclk
  reset: preset_n
req_ref:
- LRS.INTF.SPI_MASTER.IF.002
END_HLD_INTERFACE_META -->
<!-- HLD_INTERFACE_META
id: HLD.IF.INT.SPI_MASTER.QUEUE
name: QUEUE
scope: internal
protocol: fifo_push_pop
owner_module: HLD.MOD.SPI_MASTER.QUEUES
signals:
- name: push
  width: 1
- name: pop
  width: 1
- name: data
  width: 32 or 64
- name: count
  width: clog2(DEPTH+1)
req_ref:
- LRS.FUNC.SPI_MASTER.FIFO.003
END_HLD_INTERFACE_META -->

配置分 CONTROL/CONFIG/STATUS/IRQ/ERROR/COMMAND。CS 配置与等待阈值仅 disabled 可写；命令 shadow 可写，PUSH 原子提交；sticky 使用硬件置位优先的 W1C。RX 仅完整帧提交，队列和执行进度独立。
