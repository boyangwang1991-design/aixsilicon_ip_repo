# GPIO 微设计：CDC与RDC

<!-- LLD_CDC_META
id: LLD.CDC.GPIO.MAIN_INPUT
module_ref: LLD.MOD.GPIO.INPUT
source_domain: PAD_ASYNC
destination_domain: CLK_MAIN
signal_type: level
implementation:
  method: 2ff
  depth: SYNC_STAGES
lossless: false
ordered: true
applicability:
  expr: 'true'
END_LLD_CDC_META -->

<!-- LLD_CDC_META
id: LLD.CDC.GPIO.AON_INPUT
module_ref: LLD.MOD.GPIO.AON
source_domain: PAD_AON_ASYNC
destination_domain: CLK_AON
signal_type: level
implementation:
  method: 2ff
  depth: 2
lossless: false
ordered: true
applicability:
  expr: AON_WAKE_EN == 1
END_LLD_CDC_META -->

<!-- LLD_CDC_META
id: LLD.CDC.GPIO.REQ
module_ref: LLD.MOD.GPIO.MAILBOX
source_domain: CLK_MAIN
destination_domain: CLK_AON
signal_type: bus
implementation:
  method: handshake
  depth: 2
lossless: true
ordered: true
applicability:
  expr: AON_WAKE_EN == 1
END_LLD_CDC_META -->

<!-- LLD_CDC_META
id: LLD.CDC.GPIO.ACK
module_ref: LLD.MOD.GPIO.MAILBOX
source_domain: CLK_AON
destination_domain: CLK_MAIN
signal_type: bus
implementation:
  method: handshake
  depth: 2
lossless: true
ordered: true
applicability:
  expr: AON_WAKE_EN == 1
END_LLD_CDC_META -->

同步器级间无组合逻辑，ASYNC_REG属性与CDC约束同时交付；payload由源寄存器保持到匹配应答，接收方在token通过两级后读取。主暖复位不影响token/payload；RDC分析核对POR状态向main状态传播在main复位期间被屏蔽。
