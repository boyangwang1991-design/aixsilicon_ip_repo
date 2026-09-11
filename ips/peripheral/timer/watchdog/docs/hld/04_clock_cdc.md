# Watchdog：CDC / RDC 架构路径

## COMMAND

<!-- HLD_CDC_META
id: HLD.CDC.WATCHDOG.COMMAND
source_domain: HLD.DOM.CLK.WATCHDOG.APB
destination_domain: HLD.DOM.CLK.WATCHDOG.WDT
information_type: bus
transfer_requirement:
  lossless: true
  ordered: true
architecture_strategy: handshake
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.CFG.001
- LRS.REG.WATCHDOG.CFG.002
- LRS.REG.WATCHDOG.CFG.003
- LRS.REG.WATCHDOG.CFG.004
- LRS.REG.WATCHDOG.CFG.005
- LRS.REG.WATCHDOG.CFG.006
- LRS.REG.WATCHDOG.CFG.007
applicability:
  expr: 'true'
END_HLD_CDC_META -->

完整命令和配置负载保持至应答；单在途、有序、无撕裂、最多执行一次。

## REPLY

<!-- HLD_CDC_META
id: HLD.CDC.WATCHDOG.REPLY
source_domain: HLD.DOM.CLK.WATCHDOG.WDT
destination_domain: HLD.DOM.CLK.WATCHDOG.APB
information_type: bus
transfer_requirement:
  lossless: true
  ordered: true
architecture_strategy: handshake
req_ref:
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
- LRS.REG.WATCHDOG.SNP.001
- LRS.REG.WATCHDOG.SNP.002
- LRS.REG.WATCHDOG.SNP.003
applicability:
  expr: 'true'
END_HLD_CDC_META -->

完整执行/取消结果和快照负载保持，应答可见后统一发布镜像。

## ACCESS_ERROR

<!-- HLD_CDC_META
id: HLD.CDC.WATCHDOG.ACCESS_ERROR
source_domain: HLD.DOM.CLK.WATCHDOG.APB
destination_domain: HLD.DOM.CLK.WATCHDOG.WDT
information_type: event
transfer_requirement:
  lossless: true
  ordered: true
architecture_strategy: handshake
req_ref:
- LRS.INTF.WATCHDOG.BUS.001
- LRS.INTF.WATCHDOG.BUS.002
- LRS.INTF.WATCHDOG.BUS.003
- LRS.INTF.WATCHDOG.CDC.001
- LRS.INTF.WATCHDOG.CDC.002
- LRS.INTF.WATCHDOG.CDC.003
- LRS.INTF.WATCHDOG.CDC.004
- LRS.INTF.WATCHDOG.CDC.005
applicability:
  expr: 'true'
END_HLD_CDC_META -->

独立四相合并事件；允许连续错误合并但不丢失已捕获事件，preset 不复位发送状态。

## IRQ_STATUS

<!-- HLD_CDC_META
id: HLD.CDC.WATCHDOG.IRQ_STATUS
source_domain: HLD.DOM.CLK.WATCHDOG.WDT
destination_domain: HLD.DOM.CLK.WATCHDOG.APB
information_type: level
transfer_requirement:
  lossless: false
  ordered: true
architecture_strategy: synchronizer
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
END_HLD_CDC_META -->

状态电平同步，允许陈旧；preset 后从保留原状态恢复，不能用该镜像判断命令已完成。

## WARM_CANCEL

<!-- HLD_CDC_META
id: HLD.CDC.WATCHDOG.WARM_CANCEL
source_domain: HLD.DOM.CLK.WATCHDOG.WDT
destination_domain: HLD.DOM.CLK.WATCHDOG.APB
information_type: event
transfer_requirement:
  lossless: true
  ordered: true
architecture_strategy: handshake
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
END_HLD_CDC_META -->

暖复位取消的 epoch/完成记录与在途命令一致；同步链中未执行请求也须取消，不产生重放。

## INTEGRITY

<!-- HLD_CDC_META
id: HLD.CDC.WATCHDOG.INTEGRITY
source_domain: HLD.DOM.CLK.WATCHDOG.APB
destination_domain: HLD.DOM.CLK.WATCHDOG.WDT
information_type: level
transfer_requirement:
  lossless: true
  ordered: true
architecture_strategy: synchronizer
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
END_HLD_CDC_META -->

邮箱控制完整性异常以保持电平跨域并进入不可屏蔽响应，不能依赖接口软件清除。

## 数据稳定窗口与复位交错

源负载先稳定再送出控制，目的域仅在控制同步可见且负载稳定约束满足时捕获；源在
返回确认前不改负载。数据传播界与同步路径裕量必须由 LLD/SDC 显式约束并由 CDC
工具核对，不能把多位总线逐位同步或全部 false-path 后宣称无撕裂。

必须检查 POR_APBxPOR_WDT 的释放、APB_INTERFACE 到 POR_APB 保持状态、接口失效
期间命令继续完成，以及 warm 与请求同步/执行/应答四阶段交错。目的时钟停止时
事务可以一直 BUSY，但 APB 查询/忙拒绝仍有限响应。系统域同步外部可信恢复/暂停
输入；无损硬件事件桥在 IP 之外，本接口不接受异步裸脉冲。
