# GPIO 架构策略：RESET_KEEP

锁、策略和parity安全请求在主暖复位保持；主业务默认恢复；AON只冷复位。

<!-- HLD_POLICY_META
id: HLD.POLICY.GPIO.RESET_KEEP
type: reset
policy: 锁、策略和parity安全请求在主暖复位保持；主业务默认恢复；AON只冷复位。
req_ref:
- LRS.RESET.GPIO.STATE.001
- LRS.RESET.GPIO.STATE.002
- LRS.RESET.GPIO.STATE.003
- LRS.RESET.GPIO.STATE.004
- LRS.RESET.GPIO.STATE.005
- LRS.RESET.GPIO.STATE.006
- LRS.RESET.GPIO.CLOCK.001
applicability:
  expr: 'true'
END_HLD_POLICY_META -->
