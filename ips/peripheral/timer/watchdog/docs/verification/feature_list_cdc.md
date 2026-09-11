# 单在途邮箱与跨域：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.CDC
name: 单在途邮箱与跨域
description: 单在途邮箱与跨域的可执行正确性证明
priority: must
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.CONS.WATCHDOG.NFR.002
- LRS.CONS.WATCHDOG.VER.004
design_ref:
- LLD.MOD.WATCHDOG.TRANSPORT
applicability:
  expr: 'true'
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

两时钟相位扫描、源快/目的快、停WDT后读状态；邮箱忙时重复写；请求经过每一级同步时施加preset或warm；序号回卷。

独立判据：事务队列以APB接受事件建账；EXEC或CANCEL恰一次且序号对应；preset不重发；warm取消未执行者；停WDT仍可读APB；负载全程稳定。

风险与边界：同步级数×时钟比×复位相位×忙/完成；取消边界前/当拍/后一拍。

### LRS.INTF.WATCHDOG.CDC.001

所有跨域状态修改通过单个单在途命令邮箱执行。APB 写成功只表示命令被邮箱接收；CMD_STATUS.EXEC_DONE 和 DONE_SEQ 表示 WDT 域执行完成。忙时新状态修改命令返回 PSLVERR/BUSY，不排队、不覆盖。

验收：APB 接收与域内执行分离；忙时拒绝新命令，DONE_SEQ/RESULT 只反映实际完成。

### LRS.INTF.WATCHDOG.CDC.002

单在途命令的 channel/client/op/data/source/auth 与完整配置快照应从接收到执行保持一致，跨域传递不得撕裂。每条命令最多执行一次，执行序号为 32-bit 自然回卷数，相邻命令可区分。

验收：任意时钟比下请求负载一致且最多执行一次；序号跨 0xffffffff 回卷仍可区分相邻命令。

### LRS.INTF.WATCHDOG.CDC.003

命令邮箱、请求序号及完成记录应在 preset_n 和 warm_reset_evt 下保留。preset_n 只复位 APB 接口事务、staging、选择器及接口输出镜像；已接收命令继续完成且不重发。重启软件先查询 BUSY/DONE_SEQ/RESULT 再发下一命令。

验收：在请求/接收/执行/应答各相位施加 preset，已接收命令不丢失不重放，完成记录可查询。

### LRS.INTF.WATCHDOG.CDC.004

warm_reset_evt 到达 WDT 域时取消尚未执行的命令，结果 CANCELED_RESET；已经执行命令不回滚。该边沿服务不得在恢复启动后被重放。POR 同时初始化两个域邮箱；任何单域功能复位不得清握手 toggle 造成伪命令。

验收：warm 前已执行结果不回滚；未执行命令完成为 CANCELED_RESET，同拍服务不在重启后重放。

### LRS.INTF.WATCHDOG.CDC.005

wdt_clk 停止后邮箱可能一直 BUSY；APB 状态读仍可完成，软件不可假定完成并重发。独立时钟监视器负责该失效。邮箱握手非法状态在 SAFETY 实例置 CDC_PROTOCOL。

验收：停 wdt_clk 时状态读可完成且 BUSY 保持；恢复后不重发；SAFETY 非法握手产生 CDC_PROTOCOL。

### LRS.CONS.WATCHDOG.NFR.002

从命令接收至执行的 CDC 固定延迟和最大仲裁延迟必须在架构文档中给出，以 pclk/wdt_clk 周期表达。只在两个时钟持续运行的假设下给出该上界；不得承诺停钟后仍有有限命令完成时间。

验收：架构给出两个时钟持续时的 CDC/仲裁上界与计量单位；停止任一时钟不承诺有限完成。

### LRS.CONS.WATCHDOG.VER.004

一个被APB成功接收的邮箱命令最多执行一次；未接收/返回PSLVERR的写无对应状态副作用；执行、取消、错误结果与DONE_SEQ一一对应。

验收：接收、执行、取消、拒绝与完成序号逐一对账，返回错误的请求没有对应操作副作用。
