# GPIO 寄存器字段行为 11

结构offset/bit/access/reset仅在SystemRDL定义，本册不复制结构表。

## gpio_regs.aon[].AON_CMD.commands

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.AON_CMD.COMMANDS
register_ref: gpio_regs.aon[].AON_CMD.commands
behavior: command
sw_behavior: write command, read zero
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: commit
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.aon[].WAKE_PENDING_READ.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_PENDING_READ.VALUE
register_ref: gpio_regs.aon[].WAKE_PENDING_READ.value
behavior: status
sw_behavior: RO
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.aon[].WAKE_VALID_READ.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_VALID_READ.VALUE
register_ref: gpio_regs.aon[].WAKE_VALID_READ.value
behavior: status
sw_behavior: RO
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.aon[].WAKE_LOCK_READ.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_LOCK_READ.VALUE
register_ref: gpio_regs.aon[].WAKE_LOCK_READ.value
behavior: status
sw_behavior: RO
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.aon[].WAKE_ENABLE_READ.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_ENABLE_READ.VALUE
register_ref: gpio_regs.aon[].WAKE_ENABLE_READ.value
behavior: status
sw_behavior: RO
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.aon[].WAKE_MODE_READ0.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_MODE_READ0.VALUE
register_ref: gpio_regs.aon[].WAKE_MODE_READ0.value
behavior: status
sw_behavior: RO
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.aon[].WAKE_MODE_READ1.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_MODE_READ1.VALUE
register_ref: gpio_regs.aon[].WAKE_MODE_READ1.value
behavior: status
sw_behavior: RO
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.aon[].WAKE_MODE_READ2.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_MODE_READ2.VALUE
register_ref: gpio_regs.aon[].WAKE_MODE_READ2.value
behavior: status
sw_behavior: RO
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.aon[].WAKE_DIV_READ.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_DIV_READ.VALUE
register_ref: gpio_regs.aon[].WAKE_DIV_READ.value
behavior: status
sw_behavior: RO
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.aon[].WAKE_COUNT_READ.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_COUNT_READ.VALUE
register_ref: gpio_regs.aon[].WAKE_COUNT_READ.value
behavior: status
sw_behavior: RO
hw_behavior: 主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: POR与main复位恢复结构默认；参数相关值按RESET/BOOT/SYNC参数
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

