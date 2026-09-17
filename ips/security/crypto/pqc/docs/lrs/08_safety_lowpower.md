# PQC LRS：功能安全与低功耗适用性声明

## 功能安全 / Functional Safety

**N/A — 本 IP 为网络安全（Sec）类密码加速器，不承载 ISO 26262 功能安全目标。**
故障检测、完整性保护、故障注入与安全收尾需求已按安全（SEC/RESET）类别分配并记录于
[`07_security_ct.md`](07_security_ct.md)、[`07_security_key.md`](07_security_key.md) 与
[`06_clock_reset.md`](06_clock_reset.md)。若后续 SoC 集成将本 IP 纳入功能安全范围，
需在 owner 阶段补充 Safety Concept 与安全机制需求后再重开 G0。

## 低功耗 / Low Power

**N/A — 本 IP 不实现独立的低功耗模式、retention 或唤醒通道。**
时钟门控仅作为公开调度状态下的实现手段，其安全约束已记录为
`LRS.SEC.PQC.CT.002`（禁止秘密相关门控）。power-down 前的安全收尾要求已记录为
`LRS.RESET.PQC.POWERDOWN.001`。密钥保持域的 retention 策略由 key manager 与
生命周期控制器决定，不在本 IP 内定义低功耗需求。