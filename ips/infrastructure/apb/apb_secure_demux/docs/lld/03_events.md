# EVENTS 微设计

<!-- LLD_MODULE_META
id: LLD.MOD.APB_SECURE_DEMUX.EVENTS
name: events
hld_ref:
- HLD.MOD.APB_SECURE_DEMUX.EVENTS
req_ref:
- LRS.FUNC.APB_SECURE_DEMUX.LOG.001
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00201
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00202
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00203
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00301
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00302
- LRS.FUNC.APB_SECURE_DEMUX.LOG.004
- LRS.FUNC.APB_SECURE_DEMUX.LOG.005
- LRS.FUNC.APB_SECURE_DEMUX.LOG.006
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00701
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00702
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00801
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00802
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00901
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00902
- LRS.FUNC.APB_SECURE_DEMUX.LOG.010
- LRS.FUNC.APB_SECURE_DEMUX.LOG.01101
- LRS.FUNC.APB_SECURE_DEMUX.LOG.01102
- LRS.FUNC.APB_SECURE_DEMUX.LOG.012
- LRS.FUNC.APB_SECURE_DEMUX.LOGFORMAT.009
objects:
- LLD.DP.APB_SECURE_DEMUX.EVENTS
rtl_intent:
  separate_module: true
  suggested_name: apb_secure_demux_events
clock_domains:
- CLK_PCLK
reset_domains:
- RST_PRESET_N
END_LLD_MODULE_META -->

## 候选、序列与记录

每周期候选为 new_integrity、bus_failure、wait_first、synthetic。按此顺序选择最多一条；候选数量用足够宽度计数，仲裁丢失=数量-选中数量。IRQ 接收所有候选，与记录选择无关。总线失败仅完成边沿出现一次；拒绝统计区分唯一 CSR 和非 CSR，downstream_error 不计权限拒绝。

256 位记录由八个32位字组成，布局来源是需求合同；事务信息仅由锁存上下文产生，版本来自 SETUP，时间戳用事件边沿前值。非事务事件把 request/address/master/prot/write/strobe 清零并 REQUEST_VALID=0；完整性事件位置可提供 port_valid；合成完整性注入关联被阻断请求，因此保存该请求并标 TEST。EVENT_SEQUENCE 对每个选中记录递增一次，即使 FIFO 满也递增；落入记录的是递增前值。

FIRST 无效时接受选中记录，LAST 每次替换。FIRST/LAST 各有独立256位快照；成功读字0在完成边沿捕获整条当前记录，返回同一条的字0，后续字1..7读取快照。记录无效返回零；清除目标记录同时清除对应快照。若硬件新事件与读字0同沿，读及快照取沿前可见记录，新记录沿后可见；下一次字0读取才刷新。

## FIFO next-state 顺序

DEPTH=0 不生成数组/指针，仅 COUNT=0、EMPTY=1、FULL=0；丢失只统计候选仲裁。DEPTH>0 使用深度精确的寄存器队列，读写指针宽度 max(1,clog2(DEPTH))，指针到 DEPTH-1 显式归零，不能依赖截断。DEPTH=1 仍用该规则。

同周期顺序：先 FAULT_CLEAR 清 FIFO/OVF/快照/valid，再处理有效 POP，再插入选中事件。POP 写命令的空判断针对沿前 FIFO 状态，空时包括写零均错误；非空写零无弹出；单APB不能同沿同时写 POP 与 CLEAR，因此两者间不存在软件竞争。满队列+POP先释放槽位后允许push；清空+push写入槽0成为首条。若无槽，丢新不覆盖旧，置OVF并增加LOST，FIRST/LAST照常更新。

FIFO_HEAD 组合返回当前队头，空返回零，无读副作用。清空不用逐周期擦除才能完成，复位则清所有可见状态；清空后 count=0保证旧槽不可读。快照清除与新记录同沿：快照维持清零，FIRST/LAST本体可由新事件重新置位。

## 饱和和不反压

全局拒绝、配置拒绝、丢失、下游错误计数各自饱和。每周期 LOST 加仲裁损失再加 FIFO 满损失，不能只增1；先软件清零再加本周期增量，扩展位宽检测溢出。时间戳每个功能周期加一，无论 DFX/FIFO 是否启用。日志满、清除、计数溢出不再递归生成日志。
<!-- LLD_DATAPATH_META
id: LLD.DP.APB_SECURE_DEMUX.EVENTS
module_ref: LLD.MOD.APB_SECURE_DEMUX.EVENTS
operation: 仲裁完整性、事务失败、等待及合成候选，维护首错/最近快照、可裁剪 FIFO、时间戳、序号与全局计数。记录丢失不影响权限和总线进展。
latency: 组合判定；状态仅在 pclk 完成/事件边沿更新
req_ref:
- LRS.FUNC.APB_SECURE_DEMUX.LOG.001
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00201
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00202
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00203
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00301
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00302
- LRS.FUNC.APB_SECURE_DEMUX.LOG.004
- LRS.FUNC.APB_SECURE_DEMUX.LOG.005
- LRS.FUNC.APB_SECURE_DEMUX.LOG.006
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00701
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00702
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00801
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00802
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00901
- LRS.FUNC.APB_SECURE_DEMUX.LOG.00902
- LRS.FUNC.APB_SECURE_DEMUX.LOG.010
- LRS.FUNC.APB_SECURE_DEMUX.LOG.01101
- LRS.FUNC.APB_SECURE_DEMUX.LOG.01102
- LRS.FUNC.APB_SECURE_DEMUX.LOG.012
- LRS.FUNC.APB_SECURE_DEMUX.LOGFORMAT.009
END_LLD_DATAPATH_META -->
<!-- LLD_BUFFER_META
id: LLD.BUF.APB_SECURE_DEMUX.EVENT_FIFO
module_ref: LLD.MOD.APB_SECURE_DEMUX.EVENTS
type: synchronous_fifo
width: 256
depth: EVENT_FIFO_DEPTH
overflow: drop_new
update_order:
- clear
- pop
- push
END_LLD_BUFFER_META -->
<!-- LLD_ARB_META
id: LLD.ARB.APB_SECURE_DEMUX.EVENTS
module_ref: LLD.MOD.APB_SECURE_DEMUX.EVENTS
policy: fixed_priority
priority:
- integrity
- bus_failure
- wait
- synthetic
END_LLD_ARB_META -->
