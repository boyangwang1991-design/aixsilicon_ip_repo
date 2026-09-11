# GPIO 寄存器字段行为 6

结构offset/bit/access/reset仅在SystemRDL定义，本册不复制结构表。

## gpio_regs.bank[].IN_ENABLE.value

软件成功提交后保持；硬件事件不改变该配置。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.IN_ENABLE.VALUE
register_ref: gpio_regs.bank[].IN_ENABLE.value
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

## gpio_regs.bank[].OUT_DATA.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OUT_DATA.VALUE
register_ref: gpio_regs.bank[].OUT_DATA.value
behavior: configuration
sw_behavior: RW
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

## gpio_regs.bank[].OUT_SET.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OUT_SET.VALUE
register_ref: gpio_regs.bank[].OUT_SET.value
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

## gpio_regs.bank[].OUT_CLR.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OUT_CLR.VALUE
register_ref: gpio_regs.bank[].OUT_CLR.value
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

## gpio_regs.bank[].OUT_TOGGLE.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OUT_TOGGLE.VALUE
register_ref: gpio_regs.bank[].OUT_TOGGLE.value
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

## gpio_regs.bank[].OUT_MASKED_LO.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OUT_MASKED_LO.VALUE
register_ref: gpio_regs.bank[].OUT_MASKED_LO.value
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

## gpio_regs.bank[].OUT_MASKED_HI.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OUT_MASKED_HI.VALUE
register_ref: gpio_regs.bank[].OUT_MASKED_HI.value
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

## gpio_regs.bank[].OUT_OE.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OUT_OE.VALUE
register_ref: gpio_regs.bank[].OUT_OE.value
behavior: configuration
sw_behavior: RW
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

## gpio_regs.bank[].OE_SET.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OE_SET.VALUE
register_ref: gpio_regs.bank[].OE_SET.value
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

## gpio_regs.bank[].OE_CLR.value

对同一OUT_DATA或OUT_OE存储执行合并/SET/CLR/TOGGLE/半字掩码原子操作；DATA_LOCK与输出能力检查先行。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OE_CLR.VALUE
register_ref: gpio_regs.bank[].OE_CLR.value
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

