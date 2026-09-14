# GPIO 寄存器编程指南

所有地址为相对于 GPIO 16 KiB 窗口的字节偏移，32 位对齐。结构、字段位宽和访问属性以 [gpio.rdl](../../regs/gpio.rdl) 为准；下面是操作顺序，避免复制完整寄存器结构表形成另一事实源。

## 配置一根推挽输出

场景：Bank 0 的 pin 0，无锁，输出能力与拥有权均有效。先写 OE_CLR(0x138)=1，写 PIN_CFG(0x1000)=0，写 OUT_SET(0x11c)=1，最后写 OE_SET(0x134)=1。后续拉低只写 OUT_CLR(0x120)=1。每一步总线异常都应中止该操作并记录 FAULT_STATUS/ACCESS_FIRST；不能继续假定 PAD 已处于目标电平。

开漏输出则在 OE 关闭时配置 PIN_CFG.out_od=1。逻辑 OUT=1 表示释放，OUT=0 且 OE=1 表示拉低；不能用读 OUT_DATA 代替确认外部线电平。输入能力存在且 IN_VALID=1 时读取 IN_DATA 判断实际 PAD 状态。

## 字节写与原子位操作

PSTRB 对各字节分别生效，PSTRB=0 不更新业务状态，但地址/权限检查仍可能报错。全字 OUT_SET/CLR/TOGGLE 只影响写 1 且选中字节中的位；不能用 C 的非原子读改写代替并发场景的硬件原子别名。尾 Bank 中不存在的 pin 位按实例几何处理，软件以 GEOMETRY 限制 Bank/pin 索引。

## IRQ 示例

前置条件：pin 0 输入可用。配置 PIN_CFG.irq_mode=1（上升沿），清 IRQ_PENDING(0x14c)/RISING_PENDING(0x158)/FALLING_PENDING(0x15c) 的 bit 0，打开 IRQ_DETECT_EN(0x144) 和 IRQ_ENABLE(0x148)。ISR 读 IRQ_STATUS(0x150)，写对应 W1C 位，重新读状态；处理过程中有新事件时重新置位是预期行为。更改模式、滤波参数或可用性后等待基线建立。

## AON 命令示例

目标 Bank b 的窗口为 0x3000+0x100*b。先轮询 AON_STATUS(0x68) 的 ready=1、busy=0。写 WAKE_ENABLE_STAGE、三个位平面的 WAKE_MODE_STAGE0/1/2、WAKE_DIV_STAGE 和 WAKE_COUNT_STAGE，再向 AON_CMD(+0x1c) 写 1（COMMIT）。READ=2、CLR=4、LOCK=8，单次写只能选择一个合法命令。

发送后以有界软件 timeout 轮询全局状态，done/error/timeout 均必须处理；硬件 AON_TIMEOUT(0x6c) 是主时钟周期数，实际等待时间随 pclk 而变。READ 后从 +0x20 起读取 pending/valid/lock/active 配置缓存；CLR 先在 +0x18 写 mask。busy/超时时禁止把新命令覆盖旧请求；恢复 AON 时钟后等通道可用再继续。

## FIFO 与快照

事件流启用前 FLUSH，设置 FIFO_WATERMARK、每 Bank EVENT_ENABLE 与 IRQ 检测模式，最后开 FIFO_CTRL。按 HEAD0..3 顺序读取一整条记录，再写 EVENT_POP=1；每条记录包括事件信息与时间戳，具体字段见合同与寄存器定义。软件必须处理满队列丢失数，不能以一次 HEAD 读取证明消费完成。

快照触发后读取 SNAP_SEQ、各 Bank SNAP_DATA/SNAP_VALID，再复读 SNAP_SEQ；若序号变化则重试，防止多 Bank 读取跨越新快照。Strap 不可用重复触发替代重新冷启动采样。

## 锁、安全与复位后的软件恢复

配置全部验证后再置 CFG_LOCK/DATA_LOCK/GLOBAL_LOCK。不可逆锁操作应在同一安全策略下执行，非安全/非特权写可能被拒绝。暖复位后的驱动初始化必须先读取保持锁，再决定哪些配置仍允许改变；不能无条件重放冷启动设置并忽略错误。

安全请求优先于睡眠和正常输出。软件解除 sleep 不保证 safe_active 消失；外部 safe_req 或 parity_safe 仍可接管。故障恢复流程要分别确认外部原因、诊断清除结果和冷复位要求。
