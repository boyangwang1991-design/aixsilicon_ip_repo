# SPI Master IP — APB4 Slave 接口需求规格

| 项目 | 内容 |
|---|---|
| IP 名称 | `spi_master` |
| 文档标识 | `aixsilicon:ip:spi_master:req` |
| 目标版本 | V1.0 |
| 文档版本 | 0.1，工程评审草案 |
| 日期 | 2026-09-10 |
| 实现形式 | Parameterized SystemVerilog IP |
| 用途 | CPU 经 APB4 配置并执行外部 SPI 外设访问 |
| 规范词 | “应/必须”为验收要求；“建议”为架构提示 |

本规格给出一套可实施的产品选择，包含接口、事务、寄存器、异常及验收契约。未声明兼容现有商业 IP 的寄存器。文内数值、地址、策略为本 IP 的设计要求，不代表 SPI 通用标准。本文可用于需求评审、HLD/LLD、RTL、驱动和验证计划输入；不代表实现已通过验证。

## 1. 产品定位与参考依据

本 IP 面向传感器、ADC/DAC、PMIC、板级器件、EEPROM 及 SPI Flash 的软件控制访问。基础形态为一个 SPI Master，共享 SCLK/MOSI/MISO，通过多个低有效 CS 选择一个外设。APB 完成只表示寄存器访问完成；外部 SPI 事务完成须通过状态或中断判断。

参考资料及采用范围：

| 资料 | 可借鉴内容 | 本 IP 的选择 |
|---|---|---|
| [OpenTitan SPI_HOST Theory of Operation](https://opentitan.org/book/hw/ip/spi_host/doc/theory_of_operation.html) | 分段执行、片选保持、收发方向、片选时序 | 采用分段思想；仅标准单数据线 SPI；自定义 APB CSR |
| [OpenTitan Programmer’s Guide](https://opentitan.org/book/hw/ip/spi_host/doc/programmers_guide.html) | 软件准备数据、提交命令和读取响应的流程 | 明确提交与完成分离、流式搬运和恢复顺序 |
| [OpenTitan Registers](https://opentitan.org/book/hw/ip/spi_host/doc/registers.html) | 状态、FIFO、命令及错误寄存器组织 | 不继承其地址和字段定义 |
| [AMD AXI Quad SPI PG153 Feature Summary](https://docs.amd.com/r/en-US/pg153-axi-quad-spi/Feature-Summary) | 位序、FIFO、回环、多片选等产品能力 | 采用常用基础能力；不采用 AXI/QSPI/XIP 架构 |
| [AMD PG153 Clocking](https://docs.amd.com/r/en-US/pg153-axi-quad-spi/Clocking-SPI-Clock-Phase-and-Polarity-Control) | CPOL/CPHA 四种组合 | 明确首位、采样和末尾时钟行为 |
| Arm AMBA APB Protocol Specification，IHI 0024 | APB4 握手、PSTRB、PPROT、PSLVERR | APB4 从接口的规范依据；项目归档适用版本并执行一致性检查 |

资料核对说明：本次已读取上述 OpenTitan 和 AMD 官方公开页面；Arm 官方文档入口本次未能读取正文，因此不声称已逐条核对 IHI 0024。APB4 部分按下文明确契约设计，正式冻结时须与项目持有的 Arm 正版协议文本复核。SPI 外设的最高时钟、CS 时序、是否允许暂停等，以具体器件数据手册为准。

## 2. V1.0 功能范围

| ID | 必须支持的能力 | 范围 |
|---|---|---|
| SCP-001 | APB4 Slave | 32 位数据，4 位 PSTRB，3 位 PPROT，PREADY/PSLVERR |
| SCP-002 | SPI Master | 标准四线、单主机、单目标同时选通 |
| SCP-003 | 四种模式 | Mode 0/1/2/3，运行时配置 |
| SCP-004 | 帧格式 | 1～32 位，MSB-first/LSB-first |
| SCP-005 | 数据方向 | TX-only、RX-only、全双工、Dummy |
| SCP-006 | 缓冲 | 独立 TX/RX FIFO、命令 FIFO |
| SCP-007 | 片选 | 自动片选、跨段保持、显式 RELEASE 命令 |
| SCP-008 | 时序配置 | 整数分频、CS setup/hold/idle、帧间间隔 |
| SCP-009 | 软件访问 | 轮询和电平中断；无须 DMA 亦可完成全部功能 |
| SCP-010 | 异常恢复 | 无效访问拒绝、资源等待、连续模式资源错误、等待超时、中止、软复位 |
| SCP-011 | 调试 | 内部回环、状态、累计完成计数、最后完成 TAG |

V1.0 不包含 SPI Slave、Dual/Quad/Octal、3-wire 共用数据线、DDR/DTR、XIP/存储器映射读取、多主机仲裁、硬件 Flash 指令解析、内建 DMA、独立 SPI 内核时钟域及功能安全诊断机制。后续新增能力不得隐式改变 V1.0 寄存器语义。

这是一款通用外设访问控制器；SPI Flash 可通过软件发送命令，但擦写完成、WIP 轮询、写使能及协议级重试由驱动负责。

## 3. 静态参数与外部接口

### 3.1 参数

| ID | 参数 | 支持值 | 默认值 | 契约 |
|---|---|---|---|---|
| PAR-001 | `NUM_CS` | 1～8 | 4 | CS 输出数量 |
| PAR-002 | `TX_FIFO_DEPTH` | 4/8/16/32/64/128/256 | 32 | 单位：32 位 entry |
| PAR-003 | `RX_FIFO_DEPTH` | 4/8/16/32/64/128/256 | 32 | 单位：32 位 entry |
| PAR-004 | `CMD_FIFO_DEPTH` | 2/4/8/16 | 4 | 单位：待执行 descriptor；不含活动 descriptor |

非法参数组合应在 elaboration 阶段报错。所有参数组合保持同一 CSR 地址图；不存在的 CS 配置槽访问返回错误。固定 4 KiB 本地寄存器窗口、12 位本地 PADDR；SoC 外层译码负责选择窗口。可通过参数生成裁剪后的 RTL，无须专用拓扑 Generator。

### 3.2 端口

| 信号 | 方向 | 位宽 | 说明 |
|---|---|---|---|
| `pclk` | 输入 | 1 | APB 和全部内部逻辑时钟 |
| `preset_n` | 输入 | 1 | 低有效复位，集成层保证异步置位、同步释放 |
| `psel, penable, pwrite` | 输入 | 各 1 | APB 控制 |
| `paddr` | 输入 | 12 | 字节地址，本地偏移 |
| `pwdata` | 输入 | 32 | 写数据 |
| `pstrb` | 输入 | 4 | 字节写使能 |
| `pprot` | 输入 | 3 | APB 保护属性 |
| `prdata` | 输出 | 32 | 读数据 |
| `pready, pslverr` | 输出 | 各 1 | 访问完成和错误 |
| `spi_sclk_o` | 输出 | 1 | 寄存后的 SCLK |
| `spi_mosi_o` | 输出 | 1 | 寄存后的 MOSI |
| `spi_miso_i` | 输入 | 1 | 来自外设的 MISO |
| `spi_cs_n_o` | 输出 | NUM_CS | 寄存后的低有效片选 |
| `irq_o` | 输出 | 1 | 高有效电平中断 |

IF-001：V1.0 无 IO 三态控制；SCLK/MOSI/CS 为专用推挽输出，Pad 和 pinmux 属于 SoC。RX-only 时 MOSI 仍输出 dummy pattern。MISO 应由板级/Pad 保证未选中器件释放总线。

IF-002：全部内部状态使用 `pclk`；不得以输出 SCLK 作为内部逻辑时钟。通过 clock enable 产生串行边沿及采样事件。

IF-003：MISO 是受外发 SCLK 和外设输出延迟约束的返回路径。必须给出 IO 时序预算及 STA 约束；不得将其简单标成异步 false path 后宣称时序通过，也不得无补偿地加入两级同步器而造成接收错位。

## 4. APB4 访问契约

| ID | 要求 |
|---|---|
| APB-001 | 副作用仅在 `psel && penable && pready` 的上升沿提交；SETUP 阶段不得提交 |
| APB-002 | 正常运行时首个 ACCESS 周期 `pready=1`，零 wait-state；不得等待 SPI 完成、FIFO 可用或软件恢复 |
| APB-003 | 支持同一 PSEL 下连续传输；每次均需合法 SETUP/ACCESS，恰好一次寄存器/FIFO 操作 |
| APB-004 | 错误仅在完成周期以 PSLVERR 指示；失败读返回 0；失败访问不得部分修改目标寄存器或 FIFO |
| APB-005 | 所有 CSR 地址必须 4 字节对齐。非对齐、未映射、访问权限错误返回 PSLVERR |
| APB-006 | 普通 RW 字段按 PSTRB byte lane 更新；写零 strobe 对合法可写地址成功且无副作用 |
| APB-007 | PSTRB 不用于读；APB 本身不携带访问长度。本 IP 的 RXDATA 一次成功读固定弹出一个 entry |
| APB-008 | PPROT 接入但本版本不实施权限过滤。全部合法属性取值功能一致；访问控制由上游完成 |
| APB-009 | 非零 strobe 的 TXDATA、CMD_PUSH、ACTION 写必须 `PSTRB=4'b1111`，否则报错 |
| APB-010 | RO 写、WO 读报错；保留字段读 0、写忽略；W1C 只清除选中字节中写 1 的位 |

对非法地址/RO 写/WO 读，零 strobe 仍报错。对合法可写地址，零 strobe 优先成为 no-op，不触发忙态限制、FIFO 操作或命令校验。普通 RW 的字段合法性以 byte-merge 后的值检查，不合法则整体拒绝。APB4 支持 PSTRB 不意味着所有带副作用的数据端口必须允许 byte write；上述限制是本 IP 的软件访问契约。

## 5. 数据格式与 SPI 时序

### 5.1 帧与字节顺序

DAT-001：一个 frame 包含 `FRAME_BITS=1..32` 个串行 bit；一个 TX/RX FIFO entry 对应一帧，固定存储 32 位。有效数据右对齐在 `[FRAME_BITS-1:0]`。TX 高位忽略，RX 高位补零。

DAT-002：MSB-first 按 `FRAME_BITS-1` 到 0 发送/接收；LSB-first 按 0 到 `FRAME_BITS-1` 发送/接收。回读数据的数值位置与发送定义一致，不因位序选择而自动 byte swap。

DAT-003：8-bit 帧时一次 TXDATA 写入一字节有效载荷，不把 32 位写数据自动拆成四字节。驱动应使用对齐 32 位 MMIO；多字节协议的字节顺序由 entry 顺序决定。例如地址 `0x123456` 应依协议分别写入 `0x12,0x34,0x56`。

### 5.2 模式

| Mode | CPOL | CPHA | 空闲 SCLK | 采样边沿 | 移出边沿 |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 低 | 上升 | 下降 |
| 1 | 0 | 1 | 低 | 下降 | 上升 |
| 2 | 1 | 0 | 高 | 下降 | 上升 |
| 3 | 1 | 1 | 高 | 上升 | 下降 |

TIM-001：CPHA=0，首个有效 MOSI bit 应在首个 leading edge 前建立；相邻帧连续传输时，在前帧最后 trailing edge 装载下一帧首 bit。CPHA=1，在首个 leading edge 移出首 bit，在 trailing edge 采样。

TIM-002：每个正常完成 frame 必须生成恰好 `2 × FRAME_BITS` 个 SCLK 边沿，包含返回 CPOL 的最后 trailing edge；不得以最后一次 MISO 采样替代整个 frame 完成。

TIM-003：SCLK 半周期为 `H = CLKDIV + 1` 个 PCLK，CLKDIV 为 16 位无符号数：

`f_sclk = f_pclk / (2 × (CLKDIV + 1))`

CLKDIV=0 的逻辑上限为 PCLK/2；这不是未考虑 IO 条件的芯片对外承诺。运行时每次 SCLK 翻转应由计数器确定，非暂停时高低电平各持续 H 个 PCLK。

TIM-004：每个 CS 独立配置以下时序，字段单位均为 PCLK，避免软件对不同 SCLK 重新解释计数值：

| 字段 | 编码 | 精确定义 |
|---|---|---|
| CS_SETUP | 16 位 N | CS 断言到首个 leading edge：N+1 个 PCLK |
| CS_HOLD | 16 位 N | 最后 trailing edge 到 CS 释放：N+1 个 PCLK |
| CS_IDLE | 16 位 N | CS 释放后，在再次启动事务前至少等待 N+1 个 PCLK |
| FRAME_GAP | 16 位 N | 相邻 frame 间，在正常 H 个 PCLK 基础上额外插入 N 个 PCLK |

CS_SETUP 应由软件设为至少满足目标器件的 MOSI/CS 建立时间。无资源等待时 setup/hold 精确遵循配置；idle 是下界。帧间额外间隔只用于同段数据帧，不插入 Dummy 周期之间。段间允许额外调度延迟，不承诺无间隙。

TIM-005：切换器件/CPOL 时：先以旧配置完成 hold 并释放全部 CS，等待旧 CS_IDLE；再更新 SCLK 空闲电平，等待新 CS_IDLE，方可断言新 CS 并执行 setup。若 CPOL 不变，允许合并等待为 `max(old_idle,new_idle)`。CS 有效时严禁因配置写产生 SCLK 跳变。

TIM-006：空闲时 SCLK 保持最近一次实际启用的 CPOL；写配置不立即翻转输出。复位 SCLK=0。MOSI 在活动帧按位输出；正常段间等待保留末位；事务释放后置 0。

## 6. 命令与事务模型

### 6.1 基本对象

CMD-001：segment 为一个 descriptor 描述的重复操作；transaction 为同一个 CS 从断言到释放之间的一组 segment。命令 FIFO 以提交顺序执行，不重排。

CMD-002：软件写 CMD_CFG/CMD_LEN/CMD_TAG，再写 CMD_PUSH bit0=1。仅 CMD_PUSH 成功的 APB 完成沿，将三个 shadow 寄存器原子快照入队。后续修改 shadow 不影响已入队命令。不需要独立 START。

CMD-003：命令包含：`CSID, OP, FRAME_BITS, KEEP_CS, ALLOW_STALL, TAG, LEN`。OP 如下：

| OP | 编码 | LEN 单位 | TX FIFO | RX FIFO | 引脚行为 |
|---|---|---|---|---|---|
| TX | 0 | frame | 每帧消耗 1 entry | 不写入 | 发送有效数据，丢弃 MISO |
| RX | 1 | frame | 不消耗 | 每帧写入 1 entry | MOSI 重复 DUMMY_PATTERN 的有效低位 |
| TXRX | 2 | frame | 每帧消耗 1 entry | 每帧写入 1 entry | 全双工 |
| DUMMY | 3 | 完整 SCLK cycle | 不消耗 | 不写入 | MOSI 固定为 DUMMY_PATTERN[0] |
| RELEASE | 4 | 必须 0 | 不消耗 | 不写入 | 结束 KEEP_CS 保持，不生成 SCLK |

CMD-004：数据/DUMMY 命令 LEN 为实际数量，支持 1～65535；0 非法，不采用减一编码。数据命令 FRAME_BITS 采用 1～32 实际值。DUMMY/RELEASE 要求 FRAME_BITS=0。RELEASE 要求 KEEP_CS=0、ALLOW_STALL=0。

CMD-005：CSID 必须小于 NUM_CS。控制器 ENABLE=0、FAULTED=1、正在中止、命令 FIFO 满或字段非法时拒绝 PUSH，不改变队列；记录对应 sticky 错误。CMD_PUSH=0 无操作。保留位忽略。

CMD-006：CS 的模式、分频、时序、位序、dummy pattern 在 ENABLE=1 时只读；软件必须等 BUSY=0 后清 ENABLE 再修改。这消除了“已排队命令引用配置被悄悄修改”的歧义。命令 shadow 和 FIFO 数据口在使能期间可访问。

### 6.2 启动、执行、完成

CMD-007：数据命令第一次启动前检查 TX/RX 所需资源。资源不足时不提前断言 CS；BUSY=1，进入 WAIT_TX/WAIT_RX。DUMMY 无 FIFO 依赖。RELEASE 在无活动 CS 时合法，为无引脚变化的完成命令。

CMD-008：每个 frame 开始前取得完整 TX entry（如需要）并预留完整 RX entry 空间（如需要）；一旦 frame 开始，不得因 FIFO 流控在 frame 中间停 SCLK。

CMD-009：TX/RX 两种资源同时需要时须原子取得：RX 没有空间不得预先不可逆弹出 TX。移位寄存器和预留槽应单独计入设计状态，防止“FIFO 空”被误认为最后一帧已发送。

CMD-010：最后一帧/最后 Dummy 周期必须完成末尾 trailing edge。KEEP_CS=0 时，进一步满足 CS_HOLD 并释放 CS 后才产生 SEG_DONE；KEEP_CS=1 时，在末尾 trailing edge 且 RX 数据提交完成后产生 SEG_DONE，进入保持或执行下一段。

CMD-011：SEG_DONE 表示 descriptor 完成；XFER_DONE 仅在一个实际断言过的 CS 被正常释放时产生。空闲 RELEASE 只有 SEG_DONE。命令 FIFO 空、TX FIFO 空或最后 TX entry 被弹出均不是完成事件。

CMD-012：BUSY 从命令被接受开始覆盖排队、准备、执行、hold、idle 等待、KEEP_CS 等待及中止过程。仅在无活动段、无待执行命令、无有效 CS、无剩余时序等待及中止时清 0；TX/RX FIFO 残留不单独置 BUSY。

### 6.3 片选保持与段衔接

CS-001：任意时刻最多一个 CS 有效。KEEP_CS=1 保持当前 CS，便于组合指令、地址、Dummy、读数据等阶段。

CS-002：保持期间后续命令必须为同一 CS。CS 不匹配在执行前检出，进入故障恢复，不允许悄悄释放旧 CS 后转移到新器件。正常切换器件须先用 KEEP_CS=0 的末段或 RELEASE 显式结束旧事务。

CS-003：保持期间下一命令尚未到达时，SCLK 保持 CPOL、CS 保持有效，WAIT_CMD=1；适用等待超时。软件须确保目标器件允许该停顿。KEEP_CS 不等价于 SCLK 连续。

CS-004：无 stall 的同段连续帧在 FRAME_GAP=0 时，应保持连续 SCLK，前提是下一帧所需资源在前帧最后 trailing edge 前至少一个 PCLK 已可用。RTL 应预取或等效提前判定。段间不保证连续 SCLK；需要严格无间断的协议应组织为单个 TXRX/TX/RX segment。

CS-005：CS 自动覆盖整个 segment，不在每帧间翻转。如器件要求每个字单独片选，应提交多个单 frame、KEEP_CS=0 的 segment。

## 7. FIFO、暂停与错误策略

FIFO-001：TXDATA 成功写入恰好一 entry；RXDATA 成功读取恰好一 entry。TX 满写和 RX 空读立即 PSLVERR，保持 FIFO 原状，置错误标志。禁止静默丢弃或返回上次数据伪装成功。

FIFO-002：TX_LEVEL/RX_LEVEL 是实际队列 occupancy，不含移位寄存器；CMD_LEVEL 不含活动命令。预留的 RX 槽可减少可用空间，但不得增加软件可读 RX_LEVEL。软件只能读取完整 frame。

FIFO-003：判断本次 APB 操作是否合法，以提交沿之前 occupancy 为准。满 TX 与硬件同沿 pop 时仍拒绝写；空 RX 与硬件同沿 push 时仍拒绝读。非满/非空时允许同时 push/pop，计数和顺序正确。CMD FIFO 满与同沿出队采用相同保守规则。

FIFO-004：清 FIFO 只允许 ENABLE=0、BUSY=0；分别支持 TX/RX/CMD clear。RX 读取不改变命令进度；额外 TX 数据不自动发出，保留供后续命令使用。软件负责 entry 数量和描述符之间的对应关系。

STALL-001：ALLOW_STALL=1 时，资源不足在下一帧开始前暂停；SCLK 保持 CPOL。若事务已开始则 CS 保持有效；补数/读取 RX 后继续，不重复、不跳过 frame。

STALL-002：ALLOW_STALL=0 时，任何需要启动 frame 却资源未及时就绪的情况视为资源错误；不发送伪造数据、不覆盖 RX，进入故障恢复。首帧条件不足也属于错误。此选项不是吞吐保证，驱动仍须满足供数及排空条件。

STALL-003：WAIT_TIMEOUT 为 32 位 PCLK 周期数，0 关闭。仅统计 WAIT_TX/WAIT_RX/WAIT_CMD 连续无进展时间；等待原因切换不清计数。达到非零阈值则 WAIT_TIMEOUT 错误。若同沿出现可执行进展和超时，进展优先；计数清零。CS setup/hold/idle、合法 frame 和 FRAME_GAP 不计入。

STALL-004：无等待超时不代表外部器件响应正常。SPI 没有通用 ACK；MISO 固定 0/1、外设未接、器件内部忙或返回错误数据不能由本 IP 自动判定为超时。软件仍应使用完整操作期限和器件状态检查。

## 8. 中止、故障与复位

REC-001：ABORT 可在 ENABLE=0/1 任意状态接受，重复请求幂等。若 frame/Dummy cycle 已开始，完成当前 frame/当前完整周期后停止，满足 CS_HOLD 并释放 CS；不得为了快速停止制造短 SCLK 脉冲。其间禁止继续预取下一帧或发起下一命令。

REC-002：ABORT 完成时清全部待执行命令及 TX FIFO，保留已经完整接收的 RX entry（包括中止时允许完成的当前 frame），设置 ABORT_DONE；活动 descriptor 不产生正常 SEG_DONE，即使恰好在中止边界送出其末帧。保留上一个正常完成 TAG/计数，FAULTED=1。

REC-003：资源错误、等待超时、保持期间 CS 不匹配按同一安全停止过程进入 FAULTED；无正在传输的 frame 时无须生成额外 SCLK。清待执行命令/TX、保留完整 RX。错误导致的终止不产生正常 XFER_DONE/SEG_DONE；ABORT_DONE 仅用于软件 ABORT。

REC-004：故障时记录 ERROR_STATUS，ACTIVE_TAG/PROGRESS 在恢复前保留终止位置；不自动重试。恢复顺序为等待 BUSY=0、处理或丢弃 RX、写 ENABLE=0、清 sticky 错误和事件、清 FIFO、写 CLEAR_FAULT、重新使能并提交事务。CLEAR_FAULT 只允许 ENABLE=0 且 BUSY=0。

REC-005：APB 操作错误、命令提交被拒绝、忙态配置写错误，只记录错误/返回 PSLVERR，不中断已经正常执行的事务。软件访问错误与串行执行故障须可区分。

REC-006：SW_RESET 仅允许 ENABLE=0 且 BUSY=0，复位全部 CSR、FIFO、计数和状态，效果等同功能复位；因此紧急恢复应先 ABORT。SW_RESET 成功 APB 访问正常完成，其后状态为复位值。

REC-007：硬复位立即清全部状态，CS 全高、SCLK=0、MOSI=0、IRQ=0；允许截断外部事务，不保证复位瞬间外部 SPI 波形完整。解除复位后不自动恢复旧事务。系统应在没有 APB 活动传输时释放复位。

REC-008：同沿优先级：硬复位 > 已接受 ABORT/运行期致命错误 > 正常段完成。RX 已完成帧提交仍可保留；中止抑制正常完成事件。普通软件清状态与新事件同沿时，新事件置位优先。SW_RESET 只能在静止状态接受，不与活动执行竞争。

REC-009：不包含额外排队的中止延迟上界为当前帧剩余时间（最多 `64H` 个 PCLK）+ CS_HOLD+1 + CS_IDLE+1 + 最多 4 个控制周期；BUSY 清零前完成 idle 等待。等待状态下中止不得等待 FIFO 或后续命令。

## 9. 寄存器地址图

所有寄存器 32 位。`RO/RW/WO/W1C` 分别表示只读、读写、只写、写 1 清零。保留位读零。下表与字段定义共同构成软件 ABI；必须从统一寄存器描述生成 RTL 常量、C 头文件和 UVM RAL。

| 偏移 | 名称 | 属性 | 复位值 | 内容 |
|---|---|---|---|---|
| 0x000 | IP_VERSION | RO | 0x00010000 | major[31:16]=1，minor[15:0]=0 |
| 0x004 | CAPABILITY | RO | 参数相关 | 能力与参数编码 |
| 0x008 | CTRL | RW | 0 | ENABLE[0]；其余保留 |
| 0x00C | ACTION | WO | — | 一次性操作，见下文 |
| 0x010 | STATUS | RO | 动态 | 工作状态 |
| 0x014 | FIFO_LEVEL | RO | 0 | TX[8:0]，RX[17:9]，CMD[22:18] |
| 0x018 | WATERMARK | RW | 0x00000200 | TX_WM[8:0]=0；RX_WM[17:9]=1 |
| 0x01C | WAIT_TIMEOUT | RW | 0 | PCLK 周期数，0 关闭 |
| 0x020 | IRQ_STATE | RO/W1C | 0 | sticky 事件 |
| 0x024 | IRQ_ENABLE | RW | 0 | 事件及电平中断使能 |
| 0x028 | IRQ_RAW | RO | 动态 | 未屏蔽中断源 |
| 0x02C | ERROR_STATUS | RO/W1C | 0 | 错误原因 |
| 0x030 | TXDATA | WO | — | 一次写一 frame entry |
| 0x034 | RXDATA | RO | FIFO 数据 | 一次读弹出一完整 frame entry |
| 0x038 | CMD_CFG | RW | 0x00000800 | 命令 shadow，默认 FRAME_BITS=8 |
| 0x03C | CMD_LEN | RW | 1 | LEN[15:0] |
| 0x040 | CMD_TAG | RW | 0 | TAG[15:0]，软件关联标记 |
| 0x044 | CMD_PUSH | WO | — | bit0=1 提交命令 |
| 0x048 | ACTIVE_TAG | RO | 0 | ACTIVE_TAG[15:0] |
| 0x04C | PROGRESS | RO | 0 | 当前/最近活动段完整 frame 或 Dummy cycle 数[15:0] |
| 0x050 | LAST_DONE_TAG | RO | 0 | 最近正常 SEG_DONE 的 TAG[15:0] |
| 0x054 | DONE_COUNT | RO | 0 | 每次正常 SEG_DONE 加 1，32 位自然回绕 |
| 0x058 | ACTIVE_INFO | RO | 0 | CSID[2:0]、OP[6:4]、VALID[8] |
| 0x05C～0x0FC | 保留 | — | — | 访问错误 |
| 0x100+0x20×i | CS_CFG[i] | RW | 0 | CPOL/CPHA/位序/回环 |
| 0x104+0x20×i | CS_CLKDIV[i] | RW | 1 | CLKDIV[15:0]，默认 PCLK/4 |
| 0x108+0x20×i | CS_TIMING0[i] | RW | 0x00000000 | SETUP[15:0]、HOLD[31:16] |
| 0x10C+0x20×i | CS_TIMING1[i] | RW | 0x00000000 | IDLE[15:0]、FRAME_GAP[31:16] |
| 0x110+0x20×i | CS_DUMMY[i] | RW | 0xFFFFFFFF | DUMMY_PATTERN |
| 每个 CS 槽其余地址 | 保留 | — | — | 访问错误 |

### 9.1 位定义及写限制

REG-001：CAPABILITY：NUM_CS[3:0]；log2(TX_DEPTH)[7:4]；log2(RX_DEPTH)[11:8]；log2(CMD_DEPTH)[15:12]；FRAME_MAX[21:16]=32；SEGMENT_SUPPORT[22]=1；LOOPBACK_SUPPORT[23]=1；其余 0。

REG-002：CTRL.ENABLE 置 1 只允许 FAULTED=0；清 0 只允许 BUSY=0。对当前值无变化的写允许。ENABLE=0 时不接受命令提交，但允许准备 TX entry。FIFO 中残留不禁止 ENABLE 切换；驱动必须管理残留。

REG-003：ACTION 位：ABORT[0]、CLEAR_TX[1]、CLEAR_RX[2]、CLEAR_CMD[3]、CLEAR_FAULT[4]、SW_RESET[5]。每次最多一位为 1，全部为 0 无操作，多位为 1 报错；各位受第 7/8 章条件约束。操作是脉冲，读 ACTION 报错。

REG-004：STATUS 位：BUSY[0]、CS_ACTIVE[1]、WAIT_TX[2]、WAIT_RX[3]、WAIT_CMD[4]、ABORTING[5]、FAULTED[6]、TX_FULL[7]、TX_EMPTY[8]、RX_FULL[9]、RX_EMPTY[10]、CMD_FULL[11]、CMD_EMPTY[12]、ENABLED[13]、ACTIVE_VALID[14]。WAIT_TX/WAIT_RX 可同时置位；WAIT_CMD 仅表示保持片选等待下一段。FIFO empty/full 只描述队列，不描述移位器。

REG-005：CMD_CFG：CSID[2:0]；OP[6:4]；FRAME_BITS[13:8]；KEEP_CS[16]；ALLOW_STALL[17]。shadow 可临时包含非法字段，只有 PUSH 时校验组合。CMD_LEN/CMD_TAG 仅低 16 位有效。队列满访问 CMD_PUSH 返回错误而不覆盖旧 descriptor。

REG-006：CS_CFG：CPOL[0]、CPHA[1]、LSB_FIRST[2]、LOOPBACK[3]。内部回环将 MISO 采样源选择为内部 MOSI；不改变外部引脚活动。回环不验证 Pad、板级或外部器件时序。

REG-007：全部 CS 配置、WAIT_TIMEOUT 只允许 ENABLE=0 写入；WATERMARK/IRQ_ENABLE/事件 W1C 可随时写。TX_WM 范围 0..TX_DEPTH，RX_WM 范围 1..RX_DEPTH；非法合并后字段值返回 PSLVERR，寄存器不变。

REG-008：ACTIVE_TAG/INFO 在 descriptor 开始处理（包括等待首帧资源）时更新；PROGRESS 清零，此后每个完整 frame/cycle 加 1。执行结束或失败保留这些数据，VALID 清零；保持 CS 等待下一段时 ACTIVE_VALID=0。RELEASE 进度为 0。LAST_DONE_TAG 仅正常完成更新；DONE_COUNT 防止 sticky 事件合并导致软件误数，差值按模 2^32 计算。

## 10. 中断与错误编码

### 10.1 中断

| bit | 名称 | 类型 | 条件 |
|---|---|---|---|
| 0 | SEG_DONE | sticky/W1C | 一个 descriptor 正常完成 |
| 1 | XFER_DONE | sticky/W1C | 正常结束实际 SPI 事务并释放 CS |
| 2 | ABORT_DONE | sticky/W1C | 软件 ABORT 完成 |
| 3 | ERROR | level | ERROR_STATUS 非零 |
| 4 | TX_WM | level | ENABLE=1 且 TX_LEVEL≤TX_WM |
| 5 | RX_WM | level | RX_LEVEL≥RX_WM |

IRQ-001：IRQ_STATE 只有 bit[2:0] 可读写；IRQ_RAW[2:0] 来自 IRQ_STATE，bit[5:3] 来自实时条件。`irq_o = OR(IRQ_RAW & IRQ_ENABLE)`。IRQ_ENABLE 仅 bit[5:0] 有效。复位所有使能为 0。

IRQ-002：清 IRQ_STATE 不能清电平源；ERROR 必须清 ERROR_STATUS，TX/RX 水位必须服务 FIFO 或屏蔽。事件发生与 W1C 同沿时置位优先。读取状态无清除副作用。

IRQ-003：最后一次接收可能不足 RX_WM，驱动在 SEG_DONE/XFER_DONE 后仍须读取 RX_LEVEL 并排空尾数据。TX 水位在控制器使能但空闲时亦可能持续成立，驱动不供数时应屏蔽该源。

### 10.2 错误

| bit | 错误名 | 触发 | 对执行影响 |
|---|---|---|---|
| 0 | APB_ACCESS | 地址、权限、非对齐、strobe 等非法 | 拒绝本次访问，原事务继续 |
| 1 | TX_FULL_WRITE | 满 FIFO 写 TXDATA | 拒绝本次访问 |
| 2 | RX_EMPTY_READ | 空 FIFO 读 RXDATA | 返回 0 和 PSLVERR |
| 3 | CMD_FULL_PUSH | 满命令队列提交 | 拒绝本次提交 |
| 4 | CMD_INVALID | 命令字段、未使能或状态不允许提交 | 拒绝本次提交 |
| 5 | CONFIG_WRITE | ENABLE=1 写受保护配置或非法字段值 | 保持原配置 |
| 6 | TX_RESOURCE | 非暂停段缺 TX 资源 | 停止并 FAULTED |
| 7 | RX_RESOURCE | 非暂停段缺 RX 空间 | 停止并 FAULTED |
| 8 | WAIT_TIMEOUT | 等待计数达到阈值 | 停止并 FAULTED |
| 9 | CS_MISMATCH | KEEP_CS 链后继 CS 不匹配 | 停止并 FAULTED |

ERR-001：多个运行期条件同时出现允许多位置位；每次 APB 访问先检查地址/方向/对齐/strobe，失败仅记 APB_ACCESS；之后检查目标操作，记相应专用错误。非法 ACTION 组合或忙态 ACTION 记 APB_ACCESS。错误 CSR W1C 清除不解除 FAULTED。

ERR-002：设计应通过资源预留避免真正 RX overflow；不得把覆盖旧数据作为正常流控策略。V1.0 不宣称检测所有内部硬件故障、线上 bit 错误或从机命令执行结果。

## 11. 软件使用场景及顺序

### 11.1 初始化

1. 硬复位后读取 IP_VERSION/CAPABILITY。
2. ENABLE=0 时配置所需 CS 的模式、分频、时序、位序和 dummy pattern。
3. 配置 WAIT_TIMEOUT、水位及中断使能；清旧错误与事件。
4. 置 ENABLE=1；按需要预填 TX，然后提交命令。

### 11.2 普通寄存器写

例如设备协议为“8-bit 写命令 + 8-bit 地址 + 8-bit 数据”：依次写三个 TXDATA entry；提交 TX、FRAME_BITS=8、LEN=3、KEEP_CS=0。等待 XFER_DONE 且检查 ERROR_STATUS，不把 APB 写成功当成外设写完成。

### 11.3 命令后读数据

以软件定义的 24-bit 地址普通 Flash read 为例：TX FIFO 放入四个 8-bit entry（opcode 和三个地址字节），提交 TX LEN=4 KEEP_CS=1；再提交 RX LEN=N KEEP_CS=0。RX 段不消耗 TX FIFO，通过 DUMMY_PATTERN 发送占位内容。器件 opcode、地址宽度和模式由驱动依据 datasheet 决定。

若器件允许段间暂停，采用分段方式；若器件要求从指令到数据严格连续，使用单个 TXRX segment，预装指令/地址/占位数据，软件丢弃前导 RX entry，并满足整个段连续供数条件。

### 11.4 Dummy 周期

按设备要求，在 TX 和 RX 之间插入 DUMMY LEN=8 可产生恰好 8 个完整 SCLK 周期；长度不乘 FRAME_BITS，且不改变 FIFO。Dummy 段 KEEP_CS=1，最后 RX 段 KEEP_CS=0。

### 11.5 长数据传输

LEN 可大于 FIFO 深度，采用 ALLOW_STALL=1 与轮询/中断持续补 TX、读 RX。全双工驱动应交替服务两个方向，不能等待全部数据发完再读取 RX。若外设禁止暂停，须降低 SCLK、增加 FIFO 或限制单次长度以满足最坏软件服务延迟；V1.0 不内建 DMA。

### 11.6 多设备与恢复

不同 CS 的独立事务可顺序排队，前一末段必须 KEEP_CS=0。出现超时/中止后保留 RX 可能只包含部分事务数据，驱动结合 PROGRESS 和自身队列状态处理，不可自动视为成功。事务副作用可能已经发生，重试需遵循设备协议。

### 11.7 并发访问约束

DRV-001：控制器由单个驱动实例串行管理。多线程/CPU/DMA 不得在无锁条件下交错访问 CMD shadow/PUSH 或 TXDATA/RXDATA；驱动对命令构造和对应数据序列加锁，并使用平台规定的 MMIO 顺序屏障。

DRV-002：轮询必须包含软件总期限；WAIT_TIMEOUT 只覆盖资源等待，不能替代总期限。SEG_DONE sticky 可合并多个完成事件，驱动根据 DONE_COUNT 差值和软件队列核对；TAG 不强制唯一，不提供完整 completion FIFO。

## 12. 架构提示

以下是建议模块划分，外部行为仍以下文验收和前述需求为准。

| 模块 | 职责 |
|---|---|
| apb_csr | APB 接入、字节写掩码、访问合法性、寄存器 |
| cmd_queue | shadow 快照、入队、FIFO 水位 |
| transaction_ctrl | 取 descriptor、CS 链、分段、异常停止 |
| timing_engine | 半周期计数、CS 时序、帧间间隔 |
| txrx_engine | 1～32 位移位、位序、采样、dummy、回环 |
| tx_fifo / rx_fifo | 数据缓冲、并发读写、RX 槽预留 |
| irq_error | sticky 事件、level 中断、错误及计数 |

ARCH-001：建议分离 segment/transaction/frame 三层完成条件；FSM 可包含 IDLE、WAIT_RESOURCE、CS_SETUP、SHIFT、FRAME_GAP、CS_HOLD、CS_IDLE、HOLD_CS、ABORT，状态编码不作为外部 ABI。

ARCH-002：PREADY 不依赖串行 FSM，避免 APB 总线被慢外设长期占用。CS/SCLK/MOSI 必须寄存输出，不能用 APB 配置的组合逻辑直接驱动引脚。

ARCH-003：至少实现下一帧预取/资源预测以满足同段连续 SCLK。预取 entry 的所有权必须明确：正常使用一次，中止时丢弃并清 TX；RX 只在完整帧结束后对软件可见。

ARCH-004：默认 FIFO 用同步实现；不得为预留未来 CDC 引入异步 FIFO。寄存器模板、FIFO 或通用计数器是否复用属于实现决策，不影响本 IP 需求。

## 13. 性能、PPA 与集成约束

PERF-001：目标为同段正常资源条件下零额外帧间 bubble（FRAME_GAP=0）；最大逻辑 SPI 频率 PCLK/2。报告必须分别列 PCLK 约束、SPI 分频和外部接口可签核的最大 SCLK，不以仿真频率代替物理承诺。

PERF-002：8-bit、PCLK/2 时，一帧 16 PCLK。无额外总线等待的 APB 32-bit 访问最少两 PCLK，因此全双工每帧一次写加一次读至少消耗 4 PCLK 总线时间，尚未包含 CPU 指令、仲裁和中断延迟。1-bit 帧时不能依赖 APB 持续达到同样最大串行速率。

PERF-003：驱动服务预算按 entry 消耗率计算。数据帧 entry rate 约为 `f_sclk / FRAME_BITS`（忽略 gap）；TX 剩余 entry 或 RX 剩余空间所提供时间约为 `entry_count × FRAME_BITS / f_sclk`。选择水位时预留最坏服务延迟，不以平均延迟设计。

PERF-004：应交付至少 NUM_CS=1、FIFO=4 的小配置，默认配置，以及 NUM_CS=8、FIFO=256、CMD=16 的边界配置综合结果。当前未指定工艺库、Pad、PCLK 和负载，面积、功耗、最高实际 SCLK 不填写虚构指标，项目集成时补充目标。

PPA-001：FIFO RAM 数据无需全量复位，只复位有效指针/计数；空闲移位器/计数器使用使能降低翻转。时钟门控由实现及低功耗流程确定，禁止组合逻辑随意门控 PCLK。

INT-001：BUSY=1 时不得关闭 PCLK或动态改频；安全流程为停止提交、完成或中止、确认 BUSY=0，再实施时钟管理。不能在 CS 保持有效时因系统门控无限挂住总线。

INT-002：驱动及数据手册须注明无从机存在检测、无线上 ACK、无自动校验、无故障自动回滚。上电、硬复位、掉电过程中由 SoC Pad 配置保证 CS 的安全高电平。

## 14. 验证与验收矩阵

每个测试与上文 ID 建立追踪；完成需求覆盖、功能覆盖、断言和代码覆盖评审。覆盖率目标及不可达项豁免需项目评审确认，不能以代码覆盖代替功能通过。

| 测试组 | 必须覆盖内容 | 关联需求 |
|---|---|---|
| V-APB | back-to-back、SETUP 无副作用、PSTRB 全组合、零 strobe、非对齐、保留地址、RO/WO 错误、PPROT 全值 | APB-001～010 |
| V-MODE | 四 Mode × 两位序；首 bit/末 bit、1/2/7/8/9/16/24/31/32 位；CLKDIV=0/1/典型/最大 | DAT、TIM |
| V-DIR | TX/RX/TXRX/DUMMY/RELEASE，FIFO 消耗与 RX entry 数逐项一致 | CMD-003～004 |
| V-CS | 单段、多段保持、显式释放、每帧单独事务、多设备 CPOL 切换、错误 CS 链 | CS、TIM-005 |
| V-QUEUE | 队列空/满/回绕、shadow 修改不影响队列、提交失败不改变旧命令、相同/重复 TAG | CMD、REG |
| V-FIFO | 深度边界、同沿 push/pop、满写空读、RX 预留、预取与中止、帧高位补零 | FIFO、CMD-008～009 |
| V-STALL | 首帧等待、段中等待、保持等待、两个资源同时缺失、补数恢复、禁止暂停错误 | STALL |
| V-TIMEOUT | 0 关闭、阈值 1、精确边界、原因切换、超时同沿进展、中止等待状态 | STALL-003、REC |
| V-IRQ | mask/unmask、W1C 同沿置位、level 持续、尾数据小于水位、多完成事件合并、DONE_COUNT 回绕 | IRQ、REG-008 |
| V-RESET | 各状态硬复位；忙态软复位拒绝；中止末帧与正常完成竞争；故障恢复后新事务 | REC |
| V-TIMING | 无 runt pulse、setup/hold/idle 精确值或下界、FRAME_GAP、连续帧吞吐、MISO 外部延迟 | TIM、PERF |
| V-PARAM | 最小/默认/最大参数、不同 TX/RX 深度、NUM_CS=1/3/8 | PAR |
| V-SYSTEM | SPI 寄存器模型、带 Dummy 读模型、长全双工驱动、从机未接仍产生时钟且不虚报 ACK 错误 | 第 11 章 |

必须具备的关键性质：

1. CS 向量满足最多一位为低。
2. 每次成功 TXDATA/CMD_PUSH/RXDATA 访问恰好一次 push/pop；失败不变更对象。
3. 正常 segment 时钟数严格符合 LEN 与 FRAME_BITS；DUMMY 使用 LEN 周期。
4. 无 frame 中途资源停顿，无 FIFO overflow/underflow，完整 RX 帧才可读。
5. 活动 CS 下 CPOL/分频/位序不因 CSR 写改变。
6. SEG_DONE/XFER_DONE 的时序满足末尾边沿、RX 提交与 CS_HOLD 定义。
7. 无法取得资源时仍可通过 APB 读状态、服务 FIFO 或发 ABORT。
8. 一旦 ABORT 被接受，无新增 frame/descriptor；有限时钟条件下在规定上界恢复。

验证环境应包含 APB master、可配置 SPI slave BFM、独立串行位级 scoreboard、CSR 模型和断言。BFM 应可设置不同的 MISO clock-to-out 延迟、位序及帧长；scoreboard 不应直接照搬 DUT 移位算法。内部回环只能作为补充测试。

## 15. 工程交付与冻结条件

| 交付物 | 最低内容 |
|---|---|
| requirement.md | 本规格评审后的冻结版本，需求 ID 稳定 |
| architecture.md / LLD | 数据路径、FSM、预取/预留、计数边界、异常竞争优先级 |
| 寄存器 SSOT | 字段、复位值、访问类型、写限制和副作用，生成 RTL/C/RAL |
| RTL / FuseSoC core | 可综合 SV、参数检查、仿真/综合目标、lint 配置 |
| verification_plan / RTM | 需求→功能→测试/断言/覆盖的映射 |
| 驱动与示例 | 初始化、读写、全双工、Dummy、IRQ、超时/中止恢复 |
| 集成指南 | IO/时钟/复位约束、寄存器窗口、IRQ、Pad/pinmux、软件并发规则 |
| 验证与质量报告 | 回归、覆盖豁免、lint、复位/时序检查、默认与边界配置综合结果 |

冻结时必须确认：目标器件和允许暂停范围；PCLK 与目标 SCLK；IO 时序预算；NUM_CS/FIFO 默认参数；是否接受 V1.0 单时钟、四线、无 DMA/QSPI 的范围。本草案已给出可实施默认方案，以上内容用于工程评审确认，不阻碍按本规格启动架构和验证设计。
