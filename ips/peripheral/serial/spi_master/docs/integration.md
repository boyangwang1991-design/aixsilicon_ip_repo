# SPI Master 集成与软件指南

IP 为单 PCLK APB4 从机、四线 SPI 主机。默认 NUM_CS=4、TX/RX=32 entries、CMD=4；合法域和引脚见原始合同及 LRS。将本 IP 放入至少 0x200 字节的 APB 窗口，PADDR 为窗口内 12 位偏移。所有 CPU 写必须为 32 位 MMIO；普通 RW 可接受 APB byte strobe，TXDATA/CMD_PUSH/ACTION 的非零写必须全字节。PPROT 被忽略，不提供安全隔离。

PREADY 在复位解除后的所有 ACCESS 周期为 1。错误只通过 PSLVERR/ERROR_STATUS 报告，不等待 SPI 或外设。SPI 没有 ACK，未接从机仍正常产生时钟和采样电平。软件必须依据设备协议校验 ID/内容。

PCLK 是唯一内部时钟。PRESETn 异步拉低，系统负责在 PCLK 域同步解除。soft reset 和 FIFO clear 来自 PCLK 寄存器，禁止用异步 APB 译码组合驱动复位；布局实现须检查这些本域功能复位的 recovery/removal 和 reset tree。CBB FIFO 只复位指针/计数，RAM 数据不清零，empty 时的数据无效。

SCLK/MOSI/CS 接入目标 Pad/pinmux。MISO 是 SCLK 激励的源同步返回数据，直接在调度的 PCLK 边沿采样；不可加未经时序预算的两级同步器，也不可 false-path。constraints/characterization.sdc 的 100 MHz、3 ns MISO 返回延迟、0.02 pF 负载仅为本次可复现的 28nm 表征条件。最终产品必须提供 PCLK、Pad 延迟、PCB 往返延迟、从机 tCO/setup/hold 和负载，再确定允许的 DIV。SCLK=fPCLK/(2*(DIV+1))；不能仅以 RTL 的 DIV=0 功能通过宣称任意外设可工作在 50 MHz。

IRQ 为高有效电平，接入中断控制器。事件 bits 0..2 为 W1C，ERROR/TX/RX 水位为实时 level；清事件不清 level。尾部 RX 可能不足水位，完成处理仍要读取 FIFO_LEVEL 并排空应读数据。DONE_COUNT 差值按 uint32_t 模 2^32 计算，不按 sticky 事件数量计完成。

驱动通过 read32/write32/barrier/ticks/lock/unlock 平台回调访问硬件，见 sw/include/spi_master.h。所有命令 shadow/PUSH 和关联 TX/RX 事务由单个实例串行管理；ISR、其他 CPU、DMA 也必须遵守同一所有权。屏障需实现平台规定的 MMIO 顺序，不能仅用空函数代替。ticks 必须是单调且不依赖被屏蔽 IRQ 的时间源。

spi_master_init 配置器件后使能；spi_master_execute 在整个 segment 数组期间持锁，按 RX 优先顺序服务 FIFO，支持长全双工和同 CS 的 TX→DUMMY→RX。该同步驱动默认允许帧边界暂停，只能用于器件允许暂停的场景。最后段须释放 CS；一次总期限覆盖所有段，硬件 WAIT_TIMEOUT 不替代它。超时或硬件错误时发 ABORT；必须调用 spi_master_recover 等待安全结束后才可复用。recover(discard_rx=false) 遇留存 RX 返回忙，由调用者处理数据后再次恢复。

参考 sw/examples/transactions.c 的普通写、带 Dummy 读、长全双工和恢复。初始化完成后按系统最坏服务延迟配置水位：可服务时间约为可用 entry 数 × FRAME_BITS/fSCLK，需预留余量。禁止暂停的器件须使用容量内预填 TX、预留 RX、完整预排描述符的专用提交路径；本同步流式 API 不承诺无间断服务。

功能设计和实测验收见 reports/acceptance.md。独立人工评审、目标板级 IO/复位签核和任何未运行的形式证明不被自动替代为通过。
