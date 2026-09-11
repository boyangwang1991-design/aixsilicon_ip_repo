# GPIO 寄存器字段行为 8

结构offset/bit/access/reset仅在SystemRDL定义，本册不复制结构表。

## gpio_regs.bank[].DATA_LOCK.value

接受授权软件写；锁一旦置位不可软件清除。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.DATA_LOCK.VALUE
register_ref: gpio_regs.bank[].DATA_LOCK.value
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

## gpio_regs.bank[].BANK_DEBOUNCE_DIV.value

任何合法写都重建对应处理历史；BankDIV同时重启Bank采样节拍。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.BANK_DEBOUNCE_DIV.VALUE
register_ref: gpio_regs.bank[].BANK_DEBOUNCE_DIV.value
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

## gpio_regs.bank[].EVENT_ENABLE.value

软件成功提交后保持；硬件事件不改变该配置。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.EVENT_ENABLE.VALUE
register_ref: gpio_regs.bank[].EVENT_ENABLE.value
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

## gpio_regs.bank[].SNAP_DATA.value

快照同沿捕获全部Bank并递增SEQ；Strap首次全部有效请求捕获至main复位。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.SNAP_DATA.VALUE
register_ref: gpio_regs.bank[].SNAP_DATA.value
behavior: capture
sw_behavior: RO
hw_behavior: 快照同沿捕获全部Bank并递增SEQ；Strap首次全部有效请求捕获至main复位
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

## gpio_regs.bank[].SNAP_VALID.value

快照同沿捕获全部Bank并递增SEQ；Strap首次全部有效请求捕获至main复位。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.SNAP_VALID.VALUE
register_ref: gpio_regs.bank[].SNAP_VALID.value
behavior: capture
sw_behavior: RO
hw_behavior: 快照同沿捕获全部Bank并递增SEQ；Strap首次全部有效请求捕获至main复位
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

## gpio_regs.bank[].STRAP_DATA.value

快照同沿捕获全部Bank并递增SEQ；Strap首次全部有效请求捕获至main复位。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.STRAP_DATA.VALUE
register_ref: gpio_regs.bank[].STRAP_DATA.value
behavior: capture
sw_behavior: RO
hw_behavior: 快照同沿捕获全部Bank并递增SEQ；Strap首次全部有效请求捕获至main复位
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

## gpio_regs.bank[].DIAG_ENABLE.value

软件成功提交后保持；硬件事件不改变该配置。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.DIAG_ENABLE.VALUE
register_ref: gpio_regs.bank[].DIAG_ENABLE.value
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

## gpio_regs.bank[].DIAG_PENDING.value

逐位硬件置位优先于W1C；测试注入仅作用对应Pending。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.DIAG_PENDING.VALUE
register_ref: gpio_regs.bank[].DIAG_PENDING.value
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

## gpio_regs.bank[].DIAG_TEST.value

成功写仅发出一次命令或原子操作，不保留软件可读值。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.DIAG_TEST.VALUE
register_ref: gpio_regs.bank[].DIAG_TEST.value
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

## gpio_regs.bank[].OUTPUT_OWNED.value

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OUTPUT_OWNED.VALUE
register_ref: gpio_regs.bank[].OUTPUT_OWNED.value
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

