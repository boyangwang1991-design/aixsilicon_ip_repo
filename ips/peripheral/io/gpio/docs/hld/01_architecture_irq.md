# GPIO 架构模块：gpio_irq

<!-- HLD_MODULE_META
id: HLD.MOD.GPIO.IRQ
name: gpio_irq
responsibility: 边沿/电平检测、Pending/方向记录、分组和事件输出
req_ref:
- LRS.FUNC.GPIO.IRQ001.001
- LRS.FUNC.GPIO.IRQ002.001
- LRS.FUNC.GPIO.IRQ002.002
- LRS.FUNC.GPIO.IRQ003.001
- LRS.FUNC.GPIO.IRQ003.002
- LRS.FUNC.GPIO.IRQ004.001
- LRS.FUNC.GPIO.IRQ005.001
- LRS.FUNC.GPIO.IRQ006.001
- LRS.FUNC.GPIO.IRQ007.001
- LRS.FUNC.GPIO.IRQ007.002
- LRS.FUNC.GPIO.IRQ008.001
- LRS.FUNC.GPIO.IRQ008.002
- LRS.FUNC.GPIO.IRQ008.003
- LRS.FUNC.GPIO.IRQ009.001
- LRS.FUNC.GPIO.IRQ009.002
applicability:
  expr: 'true'
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
power_domain: PD_MAIN
interfaces:
- HLD.IF.EXT.GPIO.IRQ
- HLD.IF.INT.GPIO.INPUT_VIEW
- HLD.IF.INT.GPIO.EVENT
END_HLD_MODULE_META -->

## 职责与边界

检测使能与输出使能分别作用于事件产生和 Pending 输出。IRQ_TEST 独立置 Pending；不走输入边沿/FIFO路径。Pending、上升、下降各自置位优先；分组仅路由现有状态，采用平衡 OR 汇总。
