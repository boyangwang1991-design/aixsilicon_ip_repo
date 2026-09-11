# GPIO 寄存器字段行为 7

结构offset/bit/access/reset仅在SystemRDL定义，本册不复制结构表。

## gpio_regs.bank[].OE_MASKED_LO.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OE_MASKED_LO.VALUE
register_ref: gpio_regs.bank[].OE_MASKED_LO.value
behavior: command
sw_behavior: write command, read zero
hw_behavior: 对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行
collision: reset_wins
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

## gpio_regs.bank[].OE_MASKED_HI.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OE_MASKED_HI.VALUE
register_ref: gpio_regs.bank[].OE_MASKED_HI.value
behavior: command
sw_behavior: write command, read zero
hw_behavior: 对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行
collision: reset_wins
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

## gpio_regs.bank[].IRQ_DETECT_EN.value

软件成功提交后保持；硬件事件不改变该配置。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.IRQ_DETECT_EN.VALUE
register_ref: gpio_regs.bank[].IRQ_DETECT_EN.value
behavior: configuration
sw_behavior: RW
hw_behavior: 软件成功提交后保持；硬件事件不改变该配置
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

## gpio_regs.bank[].IRQ_ENABLE.value

软件成功提交后保持；硬件事件不改变该配置。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.IRQ_ENABLE.VALUE
register_ref: gpio_regs.bank[].IRQ_ENABLE.value
behavior: configuration
sw_behavior: RW
hw_behavior: 软件成功提交后保持；硬件事件不改变该配置
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

## gpio_regs.bank[].IRQ_PENDING.value

逐位硬件置位优先于W1C；测试注入仅作用对应Pending。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.IRQ_PENDING.VALUE
register_ref: gpio_regs.bank[].IRQ_PENDING.value
behavior: w1c
sw_behavior: W1C
hw_behavior: 逐位硬件置位优先于W1C；测试注入仅作用对应Pending
collision: set_wins
update_timing: transaction_boundary
reset_semantics: POR或main复位清零
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.bank[].IRQ_STATUS.value

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.IRQ_STATUS.VALUE
register_ref: gpio_regs.bank[].IRQ_STATUS.value
behavior: status
sw_behavior: RO
hw_behavior: 所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略
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

## gpio_regs.bank[].IRQ_TEST.value

成功写仅发出一次命令或原子操作，不保留软件可读值。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.IRQ_TEST.VALUE
register_ref: gpio_regs.bank[].IRQ_TEST.value
behavior: command
sw_behavior: write command, read zero
hw_behavior: 成功写仅发出一次命令或原子操作，不保留软件可读值
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

## gpio_regs.bank[].RISING_PENDING.value

逐位硬件置位优先于W1C；测试注入仅作用对应Pending。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.RISING_PENDING.VALUE
register_ref: gpio_regs.bank[].RISING_PENDING.value
behavior: w1c
sw_behavior: W1C
hw_behavior: 逐位硬件置位优先于W1C；测试注入仅作用对应Pending
collision: set_wins
update_timing: transaction_boundary
reset_semantics: POR或main复位清零
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.bank[].FALLING_PENDING.value

逐位硬件置位优先于W1C；测试注入仅作用对应Pending。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.FALLING_PENDING.VALUE
register_ref: gpio_regs.bank[].FALLING_PENDING.value
behavior: w1c
sw_behavior: W1C
hw_behavior: 逐位硬件置位优先于W1C；测试注入仅作用对应Pending
collision: set_wins
update_timing: transaction_boundary
reset_semantics: POR或main复位清零
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

## gpio_regs.bank[].CFG_LOCK.value

接受授权软件写；锁一旦置位不可软件清除。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.CFG_LOCK.VALUE
register_ref: gpio_regs.bank[].CFG_LOCK.value
behavior: lock
sw_behavior: W1S
hw_behavior: 接受授权软件写；锁一旦置位不可软件清除
collision: hw_wins
update_timing: transaction_boundary
reset_semantics: 仅POR清锁/恢复BOOT策略；main暖复位保持
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
END_LLD_REG_META -->

