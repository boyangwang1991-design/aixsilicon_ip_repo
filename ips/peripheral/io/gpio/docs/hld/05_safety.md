# GPIO 安全与诊断架构

## 输出回读

最终OE有效、输入有效、拥有权有效并消隐完成后比较物理值；失配计数到阈值置DIAG_PENDING；由使能决定故障IRQ，不自动safe。

<!-- HLD_SAFETY_META
id: HLD.SAFE.GPIO.READBACK
name: 输出回读
protects:
- HLD.MOD.GPIO.OUTPUT
detection_strategy: 最终OE有效、输入有效、拥有权有效并消隐完成后比较物理值
response_strategy: 失配计数到阈值置DIAG_PENDING；由使能决定故障IRQ，不自动safe
req_ref:
- LRS.SAFE.GPIO.DIAG001.001
- LRS.SAFE.GPIO.DIAG001.002
- LRS.SAFE.GPIO.DIAG002.001
- LRS.SAFE.GPIO.DIAG002.002
- LRS.SAFE.GPIO.DIAG002.003
- LRS.SAFE.GPIO.DIAG002.004
- LRS.SAFE.GPIO.DIAG003.001
- LRS.SAFE.GPIO.DIAG003.002
- LRS.SAFE.GPIO.DIAG004.001
- LRS.SAFE.GPIO.DIAG004.002
applicability:
  expr: DIAG_EN == 1
END_HLD_SAFETY_META -->

## 配置完整性

对受保护存储字每周期校验偶parity；部分写按完整合并字更新校验位；FAULT.PARITY与内部safe请求锁存至POR，暖复位不清。

<!-- HLD_SAFETY_META
id: HLD.SAFE.GPIO.PARITY
name: 配置完整性
protects:
- HLD.MOD.GPIO.REG
- HLD.MOD.GPIO.OUTPUT
- HLD.MOD.GPIO.SECURITY
detection_strategy: 对受保护存储字每周期校验偶parity；部分写按完整合并字更新校验位
response_strategy: FAULT.PARITY与内部safe请求锁存至POR，暖复位不清
req_ref:
- LRS.SAFE.GPIO.DIAG005.001
- LRS.SAFE.GPIO.DIAG005.002
- LRS.SAFE.GPIO.DIAG006.001
applicability:
  expr: CFG_PARITY_EN == 1
END_HLD_SAFETY_META -->

## 证明边界

高阻/开漏释放不比较，外部开短路覆盖取决于PAD、电路与负载；主域无时钟时同步safe不保证响应。parity保持仅跨暖复位；掉电安全由常开控制接管。未完成FMEDA和系统假设评估，不声明ASIL或诊断覆盖率。
