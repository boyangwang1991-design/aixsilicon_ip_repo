# 寄存器字段行为

结构与复位值由 regs/spi_master.rdl 唯一维护，保留原合同软件 ABI。
APB ACCESS 完成沿提交。零 strobe 不发送写请求；非法访问完全拦截，生成 CSR 内不发生部分写入。
普通 RW 用 strobe 合并；CTRL 检查同值/忙态/故障、WATERMARK 检查合并后范围。
全部 CS 字段与 WAIT_TIMEOUT 在 ENABLE=1 拒绝；shadow 三寄存器不提前检查命令合法性。
TXDATA/CMD_PUSH/ACTION 非零 strobe 必须全字写。副作用直接使用当前完成沿数据，
不依赖这些 WO 寄存器的保存值。RXDATA 读取沿提交 pop，返回沿前队头。
IRQ_STATE/ERROR_STATUS 逐位 W1C，hwset 优先；level IRQ 不存储。
STATUS/FIFO_LEVEL/CAPABILITY/ACTIVE_INFO/TAG/PROGRESS/DONE_COUNT 使用硬件只读视图。
SW_RESET 由完成沿注册一个周期的复位请求，与硬复位组合后复位 CSR，包括非零复位值。
不能以 hwclr 代替功能复位：hwclr 清零不等价于还原 FRAME_BITS=8、CLKDIV=1 等值。

<!-- LLD_REG_META
id: LLD.REG.SPI_MASTER.CSR
register_ref: spi_master.*
module_ref: LLD.MOD.SPI_MASTER.CSR
behavior: APB atomic access, protected configuration, queue ports, per-bit W1C
sw_behavior: byte merge for RW; whole-word side effects; errors block all target writes
hw_behavior: live read-only views; per-bit hwset; command snapshot at accepted PUSH
collision: hard reset > accepted abort/fatal > completion; hwset > W1C; FIFO validity uses pre-edge count
update_timing: successful APB ACCESS rising edge; complete frames only in RXDATA
reset_semantics: hard/idle-only soft reset restores all RDL resets and empties queues
END_LLD_REG_META -->
