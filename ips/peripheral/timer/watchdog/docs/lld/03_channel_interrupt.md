# Watchdog：IRQ、留痕与快照

## 粘滞IRQ与活动请求

<!-- LLD_IRQ_META
id: LLD.IRQ.WATCHDOG.CHANNEL.RAW
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
- LRS.FUNC.WATCHDOG.ESC.001
- LRS.FUNC.WATCHDOG.ESC.002
- LRS.FUNC.WATCHDOG.ESC.003
- LRS.FUNC.WATCHDOG.FLT.001
- LRS.FUNC.WATCHDOG.FLT.002
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
applicability:
  expr: 'true'
source: events[18:0]
trigger: level
status: EVENT_RAW
mask: IRQ_ENABLE
clear: w1c
output: irq_o[channel]
priority: 0
END_LLD_IRQ_META -->

raw_next=(raw & ~accepted_clear_mask)|new_events，IRQ_MASK命令整字替换mask；同拍
新mask在WDT更新后用于IRQ电平，再经APB同步。IRQ_TEST只置DIAG_TEST_EVENT和测试
标记，不推进C/D。raw中旧PREWARN不随刷新自动清除；本轮prewarn标志随刷新清零。
NMI/alert来自active_fault，final/safe来自独立保持请求，均不经过IRQ mask。
wake=(raw[PREWARN]&WAKE_EN)|active_fault，pclk停时仍有效。

## 一致更新后镜像

<!-- LLD_DATAPATH_META
id: LLD.DP.WATCHDOG.CHANNEL.SNAPSHOT
module_ref: LLD.MOD.WATCHDOG.CHANNEL
hld_ref:
- HLD.MOD.WATCHDOG.CHANNEL
req_ref:
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
- LRS.REG.WATCHDOG.REG.001
- LRS.REG.WATCHDOG.REG.002
- LRS.REG.WATCHDOG.REG.003
- LRS.REG.WATCHDOG.REG.004
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
applicability:
  expr: 'true'
input_width: complete post-update channel state
output_width: snapshot_t
latency: 0
signed: false
saturation: false
END_LLD_DATAPATH_META -->

snapshot_next在唯一n完成后形成，包含全通道和全客户端；SNAPSHOT执行边沿把整份
镜像锁到reply_snapshot。APB确认同步返回后再复制到指定通道保持镜像，置valid/seq。
软件多笔高低字始终读同一已发布镜像；只有下一次成功SNAPSHOT替换。失败/取消不
替换、无valid读零；CLIENT_SELECT只选已捕获表，不进行新CDC读取。
TOKEN未实现或模式不使用token时读零，非FLOW elapsed读零；保留位补零。FIRST
镜像读其已捕获上下文，不以当前n覆盖历史FIRST。DIAG_CLEAR只清选中的FIRST/COUNT，
无活动故障且授权/额度满足时执行；不清锁/恢复次数/活动请求。

