# GPIO 架构模块：gpio_aon_wake

<!-- HLD_MODULE_META
id: HLD.MOD.GPIO.AON
name: gpio_aon_wake
responsibility: 独立 AON 输入处理、原子配置、锁/Pending 和唤醒输出
req_ref:
- LRS.LP.GPIO.WAK001.001
- LRS.LP.GPIO.WAK001.002
- LRS.LP.GPIO.WAK001.003
- LRS.LP.GPIO.WAK002.001
- LRS.LP.GPIO.WAK002.002
- LRS.LP.GPIO.WAK003.001
applicability:
  expr: AON_WAKE_EN == 1
clock_domains:
- CLK_AON
reset_domains:
- RST_AON
power_domain: PD_AON
interfaces:
- HLD.IF.EXT.GPIO.AON_PAD
- HLD.IF.INT.GPIO.MAILBOX
END_HLD_MODULE_META -->

## 职责与边界

AON 由独立时钟与冷复位驱动，输入物理值不经过主域配置。每 Bank 一个采样节拍，各通道独立一致样本资格。命令在 AON 检查锁和配置后一次性生效；返回整组活动状态。
