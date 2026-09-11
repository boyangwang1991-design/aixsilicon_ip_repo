# Watchdog：CDC/RDC 结构与时序

## IRQ_STATUS

<!-- LLD_CDC_META
id: LLD.CDC.WATCHDOG.IRQ_STATUS
module_ref: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.CDC.WATCHDOG.IRQ_STATUS
source_domain: HLD.DOM.CLK.WATCHDOG.WDT
destination_domain: HLD.DOM.CLK.WATCHDOG.APB
signal_type: level
implementation:
  method: 2ff
  depth: SYNC_STAGES
lossless: false
ordered: true
req_ref:
- LRS.INTF.WATCHDOG.IF.001
- LRS.INTF.WATCHDOG.IF.002
- LRS.INTF.WATCHDOG.IF.003
- LRS.INTF.WATCHDOG.IF.004
- LRS.RESET.WATCHDOG.RST.001
- LRS.RESET.WATCHDOG.RST.002
- LRS.RESET.WATCHDOG.RST.003
- LRS.RESET.WATCHDOG.RST.004
- LRS.DFX.WATCHDOG.DIA.001
- LRS.DFX.WATCHDOG.DIA.002
- LRS.DFX.WATCHDOG.DIA.003
- LRS.DFX.WATCHDOG.DIA.004
- LRS.DFX.WATCHDOG.DIA.005
- LRS.DFX.WATCHDOG.DIA.006
applicability:
  expr: 'true'
END_LLD_CDC_META -->

IRQ、active_fault、local/system/safe状态各用S级APB同步，允许多bit镜像非原子，
只能作即时状态提示；一致多字段需SNAPSHOT。接口复位可清输出，但WDT源事件保留，
恢复后重新同步；WDT直接请求输出不走此链。

## WARM_CANCEL

<!-- LLD_CDC_META
id: LLD.CDC.WATCHDOG.WARM_CANCEL
module_ref: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.CDC.WATCHDOG.WARM_CANCEL
source_domain: HLD.DOM.CLK.WATCHDOG.WDT
destination_domain: HLD.DOM.CLK.WATCHDOG.APB
signal_type: event
implementation:
  method: handshake
  depth: SYNC_STAGES
lossless: true
ordered: true
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.FUNC.WATCHDOG.REC.001
- LRS.FUNC.WATCHDOG.REC.002
- LRS.FUNC.WATCHDOG.REC.003
- LRS.FUNC.WATCHDOG.REC.004
- LRS.FUNC.WATCHDOG.REC.005
applicability:
  expr: 'true'
END_LLD_CDC_META -->

warm为WDT同域事件。warm边沿立即取消已可见但未执行的邮箱；同时置S位取消
标记全1，以后每边沿移入0。req同步链始终继续推进且不复位。在取消标记有效期间
到达末级的请求属于warm边沿或之前首级已采样的请求，返回CANCELED_RESET并ack，
不产生通道命令。warm后首级首次采样的新请求最早在取消窗口结束后的边沿可见，
因此不会因同一warm被误取消。重复可信warm重新建立对齐窗口，不重放已完成请求。

设warm采样边沿E0：req首级在E0捕获的值最晚在E(S-1)到末级、E(S)用于执行，
此时取消末级仍为1；E1及以后首次捕获的新值最早在E(S+1)用于执行，取消末级已0。
req和取消必须同一S深度、同一旧值判定约定，不能另加请求pipeline而不调整取消标记。
物理采样孔径内的跨域事件顺序由同步器解析；不宣称亚稳窗口内的绝对模拟时间排序。
数字验证须扰动两时钟相位并核对接收序号/最多一次，不仅检查最终寄存值。

## INTEGRITY

<!-- LLD_CDC_META
id: LLD.CDC.WATCHDOG.INTEGRITY
module_ref: LLD.MOD.WATCHDOG.TRANSPORT
hld_ref:
- HLD.CDC.WATCHDOG.INTEGRITY
source_domain: HLD.DOM.CLK.WATCHDOG.APB
destination_domain: HLD.DOM.CLK.WATCHDOG.WDT
signal_type: level
implementation:
  method: 2ff
  depth: SYNC_STAGES
lossless: true
ordered: true
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.SAFE.WATCHDOG.SAF.001
- LRS.SAFE.WATCHDOG.SAF.002
- LRS.SAFE.WATCHDOG.SAF.003
- LRS.SAFE.WATCHDOG.SAF.004
- LRS.SAFE.WATCHDOG.SAF.005
- LRS.SAFE.WATCHDOG.SAF.006
applicability:
  expr: SAFETY_EN == 1
END_LLD_CDC_META -->

req/反码一致性在源域形成保持型异常，经S级同步；目的ack反码和稳定邮箱payload
奇偶校验在目的域检查。异常转CDC_PROTOCOL，不让坏握手变成合法服务；最终请求
与异常保持后不受软件清除。检测的2拍预算从WDT可观测异常开始，不包括同步等待。

