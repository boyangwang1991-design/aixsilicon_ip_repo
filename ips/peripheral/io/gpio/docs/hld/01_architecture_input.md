# GPIO 架构模块：gpio_input

<!-- HLD_MODULE_META
id: HLD.MOD.GPIO.INPUT
name: gpio_input
responsibility: 输入同步、有效性、滤波、Bank 节拍去抖和逻辑反相
req_ref:
- LRS.FUNC.GPIO.FLT001.001
- LRS.FUNC.GPIO.FLT001.002
- LRS.FUNC.GPIO.FLT002.001
- LRS.FUNC.GPIO.FLT002.002
- LRS.FUNC.GPIO.FLT002.003
- LRS.FUNC.GPIO.FLT003.001
- LRS.FUNC.GPIO.FLT004.001
- LRS.FUNC.GPIO.FLT004.002
- LRS.FUNC.GPIO.FLT005.001
- LRS.FUNC.GPIO.FLT006.001
- LRS.FUNC.GPIO.FLT007.001
- LRS.FUNC.GPIO.IN001.001
- LRS.FUNC.GPIO.IN002.001
- LRS.FUNC.GPIO.IN002.002
- LRS.FUNC.GPIO.IN003.001
- LRS.FUNC.GPIO.IN004.001
- LRS.FUNC.GPIO.IN005.001
applicability:
  expr: 'true'
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
power_domain: PD_MAIN
interfaces:
- HLD.IF.INT.GPIO.INPUT_VIEW
- HLD.IF.INT.GPIO.CAPTURE
END_HLD_MODULE_META -->

## 职责与边界

每通道处理状态独立，Bank 只共享去抖采样使能。同步、滤波、去抖与反相按合同串联；available/enable/capability 撤销使处理失效并抑制新事件。初值建立与变化检测分开，配置写不能制造输入边沿。
