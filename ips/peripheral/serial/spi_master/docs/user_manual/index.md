# 软件使用手册

1. 为 spi_master_io 填写平台 read32/write32、MMIO barrier、单调 ticks 和锁；APB bridge 负责完整字写和 PSLVERR。
2. 用 spi_master_init 配置各 CS 的 mode、位序、DIV、setup/hold/idle/gap 和 dummy。SCLK=PCLK/(2*(DIV+1))，实际频率须符合外设时序预算。
3. spi_master_execute 接收段数组。数据 LEN 为帧数，DUMMY LEN 为周期数，RELEASE LEN/FRAME_BITS 为零。数据帧实际宽 1..32，uint32_t entry 右对齐。
4. 同一事务的中间段 keep_cs=true，最后一段 false；保持期间只允许同一 CS。传入覆盖全部段的总期限。
5. SPI_ETIME/SPI_EIO 后使用 spi_master_recover。ABORT 完整结束当前帧及 hold/idle，可能保留 RX，不可立即改配置。若保留 RX，应先处理数据再恢复。

[驱动 API](../../sw/include/spi_master.h)、[驱动实现](../../sw/src/spi_master.c)、[普通写／Dummy 读／长全双工示例](../../sw/examples/transactions.c)。IRQ 服务预算、尾部 RX、水位和并发规则见 [集成指南](../integration.md)。DONE_COUNT 模 2^32 差值用于计完成，TAG 可重复；SPI 没有 ACK，不自动检测未接设备。

同步流式 API 允许帧边界暂停。禁止暂停的外设需要容量内预排完整事务的专用提交路径，不应直接使用该流式 API。
