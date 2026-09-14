# GPIO 0.1.0 用户手册

本 IP 提供 APB4 配置、数字输入输出、中断、休眠、安全覆盖、AON 唤醒、快照、Strap、事件 FIFO 与回读诊断。软件按 FEATURE/GEOMETRY 发现实际配置；寄存器结构以 [SystemRDL](../../regs/gpio.rdl) 为准，编程顺序见 [寄存器编程指南](gpio_register_programming_guide.md)。

## 启动与输出配置

前置条件是主时钟运行、冷复位及同步释放完成，互联提供安全特权数据访问。先读 IP_ID=0x4750494f、VERSION、FEATURE、GEOMETRY；再读 INPUT_CAP/OUTPUT_CAP 和当前有效性、拥有权。配置方向前先关相应 OE，设置反相/开漏/休眠模式、OUT_DATA，最后开 OE，避免切换瞬间错误驱动。受锁保护的配置写可能被整笔拒绝，必须检查总线异常，不能忽略失败继续开启输出。

并发软件线程优先使用 OUT_SET/OUT_CLR/OUT_TOGGLE 与 OE_SET/OE_CLR，避免对共享 Bank 做无锁读改写。OUT_DATA 是逻辑锁存值，不总等于 PAD 电平：反相、开漏、sleep、safe 和拥有权会改变物理输出。读取 PAD 应使用 IN_SYNC/IN_DATA 并同时核实 IN_VALID。

## 输入、滤波与中断

配置 IN_ENABLE 前确认输入能力与 PAD 路由。input_available 撤销会使该脚失效；恢复后等待同步与处理流水线重新建立。FILTER_CFG 和 DEBOUNCE_CFG 存的是阈值减一，0 表示 1，255 表示 256。Bank 的 debounce DIV 取 0..65535，采样间隔为 DIV+1 个主周期。修改配置会重建历史，首次有效样本建立边沿基线，不应被当成外部跳变。

中断初始化按“配置 PIN_CFG.irq_mode/group → 清历史 pending → 开 IRQ_DETECT_EN → 开 IRQ_ENABLE”执行。ISR 读取 IRQ_STATUS，记录业务事件，再对 IRQ_PENDING/RISING_PENDING/FALLING_PENDING 写 1 清除；新事件与 W1C 同拍时置位优先，应循环读取直到无待处理源。电平触发输入仍有效时可以立即重置 pending，必须先处理外部源。

## 低功耗与 AON

每脚 SLEEP_MODE 为保持、强制低、强制高或高阻。进入睡眠前完成配置，再请求 sleep 并等 ack；睡眠期间 OUT/OE 可更新正常锁存，改变 SLEEP_MODE 会报错。不要对开漏共享线配置强制高而引发争用。

AON 使用 staged 配置与显式命令。先确认 AON_STATUS.ready 且非 busy，写目标 Bank 的 enable/mode/div/count，发送 COMMIT，等待 done 或 timeout/error，然后检查返回缓存。pending 清除使用 MASK_STAGE+CLR 命令；READ 命令刷新快照。每次最多一个命令；超时并不代表旧请求被取消，须等待恢复/迟到 ACK 排空再复用通道。主暖复位不清 AON 配置、pending 和锁。

休眠/停钟不等于掉电保持。主域掉电必须由 SoC 的 PAD 接管与隔离方案保证；GPIO 软件不能单靠 sleep_ack 推断电源可安全切断。

## 快照、Strap 与事件 FIFO

SNAPSHOT_CMD 或外部请求同时捕获数据与有效性；读取 SNAP_DATA/SNAP_VALID 及 SNAP_SEQ，序号用于发现更新。Strap 在冷复位后一次性采样，过早触发须读取状态诊断，主暖复位的行为按 [复位定义](../lrs/06_clock_reset.md) 使用。

FIFO HEAD0..3 是队首非破坏性读，读完完整记录后写 EVENT_POP。队列空时 HEAD 为零，POP 不产生伪记录；满队列会按合同记录丢失数。软件应同时监控 FIFO_LEVEL/FIFO_LOST 和溢出故障。FLUSH 清队列但并不隐含清所有诊断；FIFO_CMD 对 flush/clear_lost 分别置位。DMA 水位中断是电平请求，服务后应使水位回落或调整配置。

## 故障与保护

FAULT_STATUS 标记错误来源，ACCESS_FIRST 捕获首次错误信息，FAULT_CLEAR 清源。先记录诊断再清除；新的同拍错误可能重新置位。配置/data/global/access 锁具有保持性，主暖复位不能用作解锁手段。CFG_PARITY_EN 启用时 parity 故障会锁存安全覆盖，恢复必须遵循冷复位策略；PARITY_INJECT 只用于授权诊断测试。

回读 mismatch 比较的是有效 PAD 输入与物理输出，需考虑 PAD/板级传播延迟，按实际系统设置 DIAG_CFG.blank 与连续失配阈值。sleep/safe/路由变化会改变比较条件，不要用默认门槛替代板级测量。

## 常见问题

- OUT 写成功但 PAD 不变：检查 OE、能力、output_owned、开漏/反相、sleep/safe 和 Pinmux。
- APB 全部返回错误：检查 14 位局部地址窗口、对齐及 PPROT；默认需要安全特权数据访问。
- 中断清不掉：确认外部电平已撤销；W1C 与新事件竞争时置位优先。
- AON 命令超时：确认常开时钟/电源与 reset；保留诊断，恢复后等待旧请求排空。
- 主暖复位后锁仍在：这是保护保持语义，不能视为复位失效。

本次 CDC/RDC 由于许可证缺失按用户授权有条件继续，未完成检查及实测覆盖率/PPA 限制在交付说明中披露；软件示例不等于 SoC 产品已经完成签核。
