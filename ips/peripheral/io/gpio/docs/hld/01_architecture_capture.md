# GPIO 架构模块：gpio_capture

<!-- HLD_MODULE_META
id: HLD.MOD.GPIO.CAPTURE
name: gpio_capture
responsibility: 全 Bank 快照、序号以及一次 Strap 捕获
req_ref:
- LRS.FUNC.GPIO.CAP001.001
- LRS.FUNC.GPIO.CAP001.002
- LRS.FUNC.GPIO.CAP002.001
- LRS.FUNC.GPIO.CAP002.002
- LRS.FUNC.GPIO.CAP003.001
- LRS.FUNC.GPIO.CAP003.002
applicability:
  expr: SNAPSHOT_EN == 1 or STRAP_EN == 1
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
power_domain: PD_MAIN
interfaces:
- HLD.IF.EXT.GPIO.CAPTURE
- HLD.IF.INT.GPIO.CAPTURE
END_HLD_MODULE_META -->

## 职责与边界

快照在同一主边沿捕获所有 Bank 沿前逻辑数据/有效位，SEQ用于多字读取更新检测。Strap 从物理同步视图取值，只在全部有输入能力的脚满足条件后一次捕获；不承担主时钟启动 strap。
