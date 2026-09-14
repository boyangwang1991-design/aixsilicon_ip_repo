# GPIO 0.1.0 集成指南

本文适用于 `aixsilicon:ip:gpio:0.1.0`，寄存器 VERSION 的编码为 0x00010000。版本号分别表示资产包版本与硬件寄存器协议版本，不应互换。设计依据为 [LRS](../lrs/index.md)、[HLD](../hld/index.md)、[LLD](../lld/index.md)；验证状态以 [Gate 报告](../../reports/quality/gate_report.md) 为准。

## 交付条件

本次用户明确授权 G3 为 **PASS WITH CONDITION** 并继续完整流程。CDC/RDC 高级许可证缺失，相关规则未完成；这不是 crossing 正确性的证明。集成方须在具有 cdc_adv_checker/rdc_adv_checker 的环境中对最终实例重跑，并处理全部路径与复位交叉结果。低功耗数字验证不替代 SoC UPF、PAD 电气与掉电隔离签核。后续回归、Formal、PPA 的实测结果见 reports，不以该授权抬升未通过的技术指标。

## 参数选择与编译

`N_GPIO=1..128`，Bank 数为 ceil(N_GPIO/32)，每 Bank 地址间隔 0x100。`SYNC_STAGES=2..4`，`N_IRQ_GROUPS=1..4`；`EVENT_FIFO_DEPTH` 支持 0、4、8、16、32、64。宽度相关位图必须恰为 N_GPIO 位；RESET_OE/HW_SAFE_OE 不得超出 OUTPUT_CAP_MASK，RESET_IN_EN 不得超出 INPUT_CAP_MASK。详细配置定义见 [参数文档](../lrs/01_configuration_meta_1.md)。

裁剪 OUT_INV_EN、AON_WAKE_EN、SNAPSHOT_EN、STRAP_EN、DIAG_EN、ACCESS_CTRL_EN、CFG_PARITY_EN 时，软件首先读 FEATURE 和 GEOMETRY，再访问可用功能。CFG_PARITY_EN 默认关闭，诊断关闭不自动关闭 parity 安全锁存。BOOT_SECURE_ONLY/BOOT_PRIV_ONLY 决定启动保护策略。

编译入口为根 `aixsilicon_ip_gpio.core`；生成顺序由 generated、rtl fileset 定义，必须先编译 gpio_csr_pkg/gpio_reg_desc_pkg，再编译 CSR 与业务 RTL。parity 通过 `aixsilicon:cbb:parity_gen_check:0.1.0` depend 引用。本地 build/cbb_adapter 是来源哈希绑定的兼容性物化，正式系统应提供相同版本的 CBB。禁止把验证 bind 或 UVM 文件放入综合 RTL fileset。

## 总线连接

GPIO 是 APB4 slave，PADDR 为 14 位局部字节地址，PWDATA/PRDATA 为 32 位，PSTRB 为 4 位，PPROT 为 3 位。上层解码器将对齐的 16 KiB 窗口映射到该局部地址，不可静默截断未命中的高地址。PSEL/PENABLE/PWRITE 按 APB Setup/Access 时序驱动，Access 完成时采样 PREADY/PSLVERR/PRDATA；读值是完成沿前快照。PREADY 固定为 1，软件不能以等待状态判断错误。

PPROT[2] 为 instruction 标识，本 IP 拒绝 instruction 访问；默认 PPROT=3'b001 是安全特权数据访问。无 PSTRB 的互联需明确绑定为 4'b1111，不能悬空；不能把全部 PPROT 绑零后假定默认访问有权限。未对齐、越界、权限和语义错误返回 PSLVERR，错误读返回零，业务写入原子取消，错误诊断状态可更新。

## 引脚与中断连接

| 端口组 | 连接责任 | 不使用时 |
|---|---|---|
| gpio_in_i | PAD 输入；允许异步，由主输入同步器采样 | 无输入能力位绑 0 |
| input_available_i | 主域同步有效性；切路由/隔离前撤销，稳定后恢复 | 未连接输入绑 0，始终可用输入可绑 1 |
| output_owned_i | Pinmux 当前拥有权，必须来自主域同步控制 | 不属于 GPIO 的输出绑 0 |
| gpio_out_o / gpio_oe_o | 接 PAD 数据与输出使能；OE 高有效 | 不可接成多驱动；无能力位 OE 始终为零 |
| irq_pin_o / irq_group_o / irq_summary_o | 主域电平中断，接中断控制器所选层级 | 输出可留空 |
| event_o | 主域单周期事件，异步消费者须握手/展宽 | 输出可留空，不能直接两级同步脉冲 |
| dma_req_o | FIFO 水位电平请求 | 无 DMA 时留空 |
| fault_irq_o | 汇总错误源与 FAULT_IRQ_ENABLE | 无中断路由时软件轮询 FAULT_STATUS |
| snapshot_req_i / strap_sample_i | 主域同步触发；Strap 一次性捕获 | 绑 0 |
| sleep_req_i / safe_req_i | 主域约定的低功耗与硬件安全控制 | 绑 0 |
| sleep_ack_o / safe_active_o | PMU/安全控制观察信号 | 输出可留空 |
| aon_gpio_in_i / aon_input_available_i | 常开 PAD 路径与 AON 同步有效性 | 不使用脚绑 0 |
| wake_req_o | 常开粘滞电平，PMU 自行同步并仲裁睡眠边界 | AON 未使用时留空 |

## 时钟、复位和 CDC

pclk_i 驱动 APB 与主业务，aon_clk_i 驱动 AON。两域允许异步；GPIO 输入同步级数由参数决定，AON 输入固定两级。mailbox 多位载荷依赖请求/响应握手稳定窗口，必须保留同步器属性并设置物理 skew/max-delay 约束，不能仅用 false-path 宣称路径闭合。

por_ni、main_rst_ni、aon_rst_ni 均低有效；内部异步断言、各域同步释放。主暖复位清主业务状态，但 cfg/data/global/access 锁与 parity_safe 等 POR 域状态保持；AON 活动配置与 pending 不受主暖复位清除。POR 清除保持状态。复位释放时确保对应时钟运行，主域/APB 至少等待同步链释放后再访问；AON 命令发送前轮询 ready。

约束入口为 [gpio.sgdc](../../constraints/gpio.sgdc) 和 [characterization SDC](../../constraints/gpio_characterization.sdc)。表征示例 pclk=10 ns、aon_clk=100 ns，分别采用 1 ns/10 ns I/O budget，时钟不确定度 0.1 ns、输出负载 0.01。它们不是产品最大频率承诺。SoC 必须替换为实际时钟、IO delay/load 和工艺角，并计算同步器 MTBF。

## 休眠、停钟与掉电

进入睡眠前先编程每引脚 SLEEP_MODE，拉高 sleep_req_i，等待 sleep_ack_o，再按系统协议停主时钟。保持模式捕获进入沿之前的正常物理输出；同拍 OUT 写更新正常锁存，退出时生效。safe 覆盖优先于 sleep，复位优先于 safe，最终 OE 仍受能力和拥有权约束。强制高/低是推挽行为，开漏线路通常选择保持或高阻。

主域停钟但不断电时锁存输出继续保持。主域掉电没有 RTL 保持保证：PMU 必须先让 AON PAD 控制/retention/isolation 接管，再断电；退出时先恢复电源、复位与配置/路由，再解除接管。UPF、电平转换、隔离极性、PAD 保持值及电气安全由 SoC 实例提供。AON 必须保持供电，wake_req_o 不能经已关断主域中转。

## DFT、安全与实例验收

顶层没有 scan/test-clock 端口；扫描插入、测试模式时钟/复位控制和 ATPG 属于 SoC 后端。同步器与 AON 保持路径应纳入 DFT 约束审查，不能将功能仿真当作可测性签核。

实例集成必须填写逐 PAD 能力/拥有权表、复位与安全默认值的板级影响、时钟范围、AON 供电策略、APB 地址窗口/权限、IRQ/DMA 路由及故障处理责任。数字 parity/回读诊断不能推导为认证等级、诊断覆盖率或板级安全声明。检查清单见同目录 gpio_integration_checklist.xlsx。

## 顶层端口名称核对

下列端口对应前文同名 APB/时钟/复位连接规则；信号宽度以顶层与接口模型为准。

`paddr_i`, `penable_i`, `pprot_i`, `prdata_o`, `pready_o`, `psel_i`, `pslverr_o`, `pstrb_i`, `pwdata_i`, `pwrite_i`。
