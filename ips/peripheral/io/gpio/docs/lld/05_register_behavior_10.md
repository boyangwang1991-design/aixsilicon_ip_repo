# GPIO 寄存器字段行为 10

结构offset/bit/access/reset仅在SystemRDL定义，本册不复制结构表。

## gpio_regs.pin[].DEBOUNCE_CFG.d_minus_one

任何合法写都重建对应处理历史；BankDIV同时重启Bank采样节拍。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.DEBOUNCE_CFG.D_MINUS_ONE
register_ref: gpio_regs.pin[].DEBOUNCE_CFG.d_minus_one
behavior: configuration
sw_behavior: RW
hw_behavior: 任何合法写都重建对应处理历史；BankDIV同时重启Bank采样节拍
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

## gpio_regs.pin[].DIAG_CFG.blank

BLANK>=SYNC_STAGES+2；消隐BLANK完整周期后连续M次失配才置Pending。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.DIAG_CFG.BLANK
register_ref: gpio_regs.pin[].DIAG_CFG.blank
behavior: configuration
sw_behavior: RW
hw_behavior: BLANK>=SYNC_STAGES+2；消隐BLANK完整周期后连续M次失配才置Pending
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

## gpio_regs.pin[].DIAG_CFG.m_minus_one

BLANK>=SYNC_STAGES+2；消隐BLANK完整周期后连续M次失配才置Pending。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.DIAG_CFG.M_MINUS_ONE
register_ref: gpio_regs.pin[].DIAG_CFG.m_minus_one
behavior: configuration
sw_behavior: RW
hw_behavior: BLANK>=SYNC_STAGES+2；消隐BLANK完整周期后连续M次失配才置Pending
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

## gpio_regs.aon[].WAKE_ENABLE_STAGE.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_ENABLE_STAGE.VALUE
register_ref: gpio_regs.aon[].WAKE_ENABLE_STAGE.value
behavior: shadow
sw_behavior: RW
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

## gpio_regs.aon[].WAKE_MODE_STAGE0.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_MODE_STAGE0.VALUE
register_ref: gpio_regs.aon[].WAKE_MODE_STAGE0.value
behavior: shadow
sw_behavior: RW
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

## gpio_regs.aon[].WAKE_MODE_STAGE1.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_MODE_STAGE1.VALUE
register_ref: gpio_regs.aon[].WAKE_MODE_STAGE1.value
behavior: shadow
sw_behavior: RW
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

## gpio_regs.aon[].WAKE_MODE_STAGE2.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_MODE_STAGE2.VALUE
register_ref: gpio_regs.aon[].WAKE_MODE_STAGE2.value
behavior: shadow
sw_behavior: RW
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

## gpio_regs.aon[].WAKE_DIV_STAGE.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_DIV_STAGE.VALUE
register_ref: gpio_regs.aon[].WAKE_DIV_STAGE.value
behavior: shadow
sw_behavior: RW
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

## gpio_regs.aon[].WAKE_COUNT_STAGE.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_COUNT_STAGE.VALUE
register_ref: gpio_regs.aon[].WAKE_COUNT_STAGE.value
behavior: shadow
sw_behavior: RW
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

## gpio_regs.aon[].WAKE_MASK_STAGE.value

主域暂存/缓存按main复位清；活动配置/锁/Pending在AON仅冷复位；staging仅BUSY=0可写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.AON.WAKE_MASK_STAGE.VALUE
register_ref: gpio_regs.aon[].WAKE_MASK_STAGE.value
behavior: shadow
sw_behavior: RW
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

