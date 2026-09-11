# GPIO 架构模块：gpio_apb_if

<!-- HLD_MODULE_META
id: HLD.MOD.GPIO.APB
name: gpio_apb_if
responsibility: APB 传输识别、地址/权限/锁/能力/字段预检查与整笔提交
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
- LRS.REG.GPIO.BUS006.001
- LRS.REG.GPIO.BUS006.002
applicability:
  expr: 'true'
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
power_domain: PD_MAIN
interfaces:
- HLD.IF.EXT.GPIO.APB
- HLD.IF.INT.GPIO.CSR
- HLD.IF.INT.GPIO.POLICY
END_HLD_MODULE_META -->

## 职责与边界

在发出任何业务写使能前，合并地址、访问属性、PSTRB、锁、能力及字段合法性判定。仅合法 Access 完成才发提交；错误只允许更新访问诊断。局部 CSR 和 AON 命令均零等待，AON 状态由轮询获取。
