# QUEUES 微架构

复用 aixsilicon:cbb:sync_fifo:0.1.0，IMPL=0、OUTPUT_REG=0，DATA_W 为 32/32/64。
队列数据不全量复位；指针/count 复位。原资产无同步 clear 输入，采用PCLK 上升沿寄存的清除请求复位胶水；
只在已接受清除/终止后执行，清除覆盖窗口内禁止 push/pop。软件 clear 的 APB 完成后、下一传输前清除完毕。
所有 APB 满写/空读按沿前状态拒绝，三个 count 不包含活动 descriptor/shift entry。
RX 只有执行引擎写入；单活动帧开始时检查可用槽，无第二写者，故不会覆盖或溢出。

<!-- LLD_MODULE_META
id: LLD.MOD.SPI_MASTER.QUEUES
name: QUEUES
hld_ref:
- HLD.MOD.SPI_MASTER.QUEUES
responsibility: 同步 TX/RX/命令队列及清除胶水；复用 sync_fifo
END_LLD_MODULE_META -->
<!-- LLD_DATAPATH_META
id: LLD.DP.SPI_MASTER.QUEUES
module_ref: LLD.MOD.SPI_MASTER.QUEUES
width: 32
latency: APB zero wait; SPI counted edges
description: '复用 aixsilicon:cbb:sync_fifo:0.1.0，IMPL=0、OUTPUT_REG=0，DATA_W 为 32/32/64。

  队列数据不全量复位；指针/count 复位。原资产无同步 clear 输入，采用PCLK 上升沿寄存的清除请求复位胶水；

  只在已接受清除/终止后执行，清除覆盖窗口内禁止 push/pop。软件 clear 的 APB 完成后、下一传输前清除完毕。

  所有 APB 满写/空读按沿前状态拒绝，三个 count 不包含活动 descriptor/shift entry。

  RX 只有执行引擎写入；单活动帧开始时检查可用槽，无第二写者，故不会覆盖或溢出。

  '
END_LLD_DATAPATH_META -->
<!-- LLD_RESET_META
id: LLD.RST.SPI_MASTER.QUEUES
reset_domain: preset_n
type: asynchronous assert, synchronous release by integration
module_ref: LLD.MOD.SPI_MASTER.QUEUES
reset_values: contract REC-007; FIFO RAM untouched
END_LLD_RESET_META -->
