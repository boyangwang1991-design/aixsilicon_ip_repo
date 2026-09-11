# GPIO 架构模块：gpio_security

<!-- HLD_MODULE_META
id: HLD.MOD.GPIO.SECURITY
name: gpio_security
responsibility: POR 复位的锁/访问策略/首故障与权限判定
req_ref:
- LRS.SEC.GPIO.SEC001.001
- LRS.SEC.GPIO.SEC002.001
- LRS.SEC.GPIO.SEC002.002
- LRS.SEC.GPIO.SEC002A.001
- LRS.SEC.GPIO.SEC002A.002
- LRS.SEC.GPIO.SEC002A.003
- LRS.SEC.GPIO.SEC003.001
- LRS.SEC.GPIO.SEC003.002
- LRS.SEC.GPIO.SEC004.001
- LRS.SEC.GPIO.SEC005.001
- LRS.SEC.GPIO.SEC005.002
- LRS.SEC.GPIO.SEC006.001
- LRS.SEC.GPIO.SEC006.002
applicability:
  expr: 'true'
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
- RST_POR_MAIN
power_domain: PD_MAIN
interfaces:
- HLD.IF.INT.GPIO.POLICY
END_HLD_MODULE_META -->

## 职责与边界

锁与 ACCESS_CFG 使用主时钟驱动但仅 POR 复位的状态，主暖复位不清。软件被锁时整笔事务失败，硬件主复位仍可恢复业务默认。首故障槽使用主业务复位；新错误与清槽竞争时新记录获胜。
