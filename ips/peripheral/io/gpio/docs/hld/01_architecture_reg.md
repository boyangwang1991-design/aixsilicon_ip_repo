# GPIO 架构模块：gpio_regfile

<!-- HLD_MODULE_META
id: HLD.MOD.GPIO.REG
name: gpio_regfile
responsibility: 软件配置与状态视图、寄存器生成边界、业务写原子分发
req_ref:
- LRS.REG.GPIO.MAP.001
- LRS.REG.GPIO.IDENTITY.002
- LRS.REG.GPIO.FAULT.003
- LRS.REG.GPIO.FIRST.004
- LRS.REG.GPIO.LOST.005
- LRS.REG.GPIO.AONRESULT.006
- LRS.REG.GPIO.DEFAULT.007
applicability:
  expr: 'true'
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
power_domain: PD_MAIN
interfaces:
- HLD.IF.INT.GPIO.CSR
- HLD.IF.INT.GPIO.OUT_CONFIG
END_HLD_MODULE_META -->

## 职责与边界

按全局、Bank、逐引脚、AON staging/readback 分组。结构来自后续 SystemRDL，访问包装与特殊 HW 行为来自 LLD。禁止 CSR 生成物绕过 APB 整笔检查。状态唯一 owner 在功能模块，CSR 提供一致只读或清除/测试接口。
