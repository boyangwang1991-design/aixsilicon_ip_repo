# GPIO CDC/RDC 架构

## MAIN_PAD

每脚 SYNC_STAGES 采样，输入available先撤销/稳定后恢复；同步路径不允许运行时旁路。

<!-- HLD_CDC_META
id: HLD.CDC.GPIO.MAIN_PAD
source_domain: PAD_ASYNC
destination_domain: CLK_MAIN
information_type: level
architecture_strategy: synchronizer
description: 每脚 SYNC_STAGES 采样，输入available先撤销/稳定后恢复；同步路径不允许运行时旁路。
transfer_requirement:
  lossless: false
  ordered: true
req_ref:
- LRS.FUNC.GPIO.IN001.001
- LRS.FUNC.GPIO.IN002.001
- LRS.FUNC.GPIO.IN002.002
- LRS.FUNC.GPIO.IN003.001
- LRS.FUNC.GPIO.IN004.001
- LRS.FUNC.GPIO.IN005.001
- LRS.CONS.GPIO.INSTANCEPAD.001
- LRS.CONS.GPIO.INSTANCEDEFAULTS.002
- LRS.CONS.GPIO.INSTANCECLOCK.003
- LRS.CONS.GPIO.INSTANCERESET.004
- LRS.CONS.GPIO.INSTANCEPOWER.005
- LRS.CONS.GPIO.INSTANCEELECTRIC.006
- LRS.CONS.GPIO.INSTANCEBUS.007
- LRS.CONS.GPIO.INSTANCEIRQDMA.008
- LRS.CONS.GPIO.INSTANCESAFETY.009
applicability:
  expr: 'true'
END_HLD_CDC_META -->

## AON_PAD

每脚固定两级同步，AON available由常开源同步提供；主域掉电不改变此输入路径。

<!-- HLD_CDC_META
id: HLD.CDC.GPIO.AON_PAD
source_domain: PAD_AON_ASYNC
destination_domain: CLK_AON
information_type: level
architecture_strategy: synchronizer
description: 每脚固定两级同步，AON available由常开源同步提供；主域掉电不改变此输入路径。
transfer_requirement:
  lossless: false
  ordered: true
req_ref:
- LRS.LP.GPIO.WAK001.001
- LRS.LP.GPIO.WAK001.002
- LRS.LP.GPIO.WAK001.003
applicability:
  expr: AON_WAKE_EN == 1
END_HLD_CDC_META -->

## COMMAND

请求身份及载荷主POR保持，AON确认后才能复用；跨域总线按bundled-data约束，不逐位独立同步。

<!-- HLD_CDC_META
id: HLD.CDC.GPIO.COMMAND
source_domain: CLK_MAIN
destination_domain: CLK_AON
information_type: bus
architecture_strategy: handshake
description: 请求身份及载荷主POR保持，AON确认后才能复用；跨域总线按bundled-data约束，不逐位独立同步。
transfer_requirement:
  lossless: true
  ordered: true
req_ref:
- LRS.LP.GPIO.WAK001.001
- LRS.LP.GPIO.WAK001.002
- LRS.LP.GPIO.WAK001.003
- LRS.LP.GPIO.WAK002.001
- LRS.LP.GPIO.WAK002.002
- LRS.LP.GPIO.WAK003.001
- LRS.LP.GPIO.WAK004.001
- LRS.LP.GPIO.WAK004.002
- LRS.LP.GPIO.WAK005.001
- LRS.LP.GPIO.WAK005.002
- LRS.LP.GPIO.WAK005.003
- LRS.LP.GPIO.WAK006.001
- LRS.LP.GPIO.WAK007.001
- LRS.LP.GPIO.WAK007.002
- LRS.LP.GPIO.WAK007.003
- LRS.LP.GPIO.WAK008.001
- LRS.LP.GPIO.WAK008.002
- LRS.LP.GPIO.WAK009.001
- LRS.LP.GPIO.WAK009.002
- LRS.LP.GPIO.WAK010.001
- LRS.LP.GPIO.WAK010.002
- LRS.LP.GPIO.WAK010A.001
- LRS.LP.GPIO.WAK010A.002
- LRS.LP.GPIO.WAK011.001
- LRS.LP.GPIO.WAK012.001
- LRS.LP.GPIO.WAK012.002
applicability:
  expr: AON_WAKE_EN == 1
END_HLD_CDC_META -->

## RESPONSE

应答载荷稳定至确认；主暖复位恢复排空旧应答后才能READY，超时不撤销命令。

<!-- HLD_CDC_META
id: HLD.CDC.GPIO.RESPONSE
source_domain: CLK_AON
destination_domain: CLK_MAIN
information_type: bus
architecture_strategy: handshake
description: 应答载荷稳定至确认；主暖复位恢复排空旧应答后才能READY，超时不撤销命令。
transfer_requirement:
  lossless: true
  ordered: true
req_ref:
- LRS.LP.GPIO.WAK001.001
- LRS.LP.GPIO.WAK001.002
- LRS.LP.GPIO.WAK001.003
- LRS.LP.GPIO.WAK002.001
- LRS.LP.GPIO.WAK002.002
- LRS.LP.GPIO.WAK003.001
- LRS.LP.GPIO.WAK004.001
- LRS.LP.GPIO.WAK004.002
- LRS.LP.GPIO.WAK005.001
- LRS.LP.GPIO.WAK005.002
- LRS.LP.GPIO.WAK005.003
- LRS.LP.GPIO.WAK006.001
- LRS.LP.GPIO.WAK007.001
- LRS.LP.GPIO.WAK007.002
- LRS.LP.GPIO.WAK007.003
- LRS.LP.GPIO.WAK008.001
- LRS.LP.GPIO.WAK008.002
- LRS.LP.GPIO.WAK009.001
- LRS.LP.GPIO.WAK009.002
- LRS.LP.GPIO.WAK010.001
- LRS.LP.GPIO.WAK010.002
- LRS.LP.GPIO.WAK010A.001
- LRS.LP.GPIO.WAK010A.002
- LRS.LP.GPIO.WAK011.001
- LRS.LP.GPIO.WAK012.001
- LRS.LP.GPIO.WAK012.002
applicability:
  expr: AON_WAKE_EN == 1
END_HLD_CDC_META -->

## POR_TO_MAIN

保持状态驱动主业务逻辑必须在主业务复位有效时抑制写/故障采样；解除复位后按新默认建立校验。

<!-- HLD_CDC_META
id: HLD.CDC.GPIO.POR_TO_MAIN
source_domain: RST_POR_MAIN
destination_domain: RST_MAIN
information_type: level
architecture_strategy: other
description: 保持状态驱动主业务逻辑必须在主业务复位有效时抑制写/故障采样；解除复位后按新默认建立校验。
transfer_requirement:
  lossless: false
  ordered: true
req_ref:
- LRS.RESET.GPIO.STATE.001
- LRS.RESET.GPIO.STATE.002
- LRS.RESET.GPIO.STATE.003
- LRS.RESET.GPIO.STATE.004
- LRS.RESET.GPIO.STATE.005
- LRS.RESET.GPIO.STATE.006
applicability:
  expr: 'true'
END_HLD_CDC_META -->

## WAKE_PMU

wake_req为粘滞电平，PMU负责同步并在入睡边界最终仲裁；跨域事件短脉冲不直接同步。

<!-- HLD_CDC_META
id: HLD.CDC.GPIO.WAKE_PMU
source_domain: CLK_AON
destination_domain: PMU_DOMAIN
information_type: level
architecture_strategy: synchronizer
description: wake_req为粘滞电平，PMU负责同步并在入睡边界最终仲裁；跨域事件短脉冲不直接同步。
transfer_requirement:
  lossless: false
  ordered: true
req_ref:
- LRS.LP.GPIO.WAK012.001
- LRS.LP.GPIO.WAK012.002
applicability:
  expr: AON_WAKE_EN == 1
END_HLD_CDC_META -->

