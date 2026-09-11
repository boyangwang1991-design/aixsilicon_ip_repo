# GPIO 寄存器字段行为 2

结构offset/bit/access/reset仅在SystemRDL定义，本册不复制结构表。

## gpio_regs.FAULT_STATUS.sources

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.FAULT_STATUS.SOURCES
register_ref: gpio_regs.FAULT_STATUS.sources
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

## gpio_regs.FAULT_CLEAR.clear

仅清允许sticky源；ACCESS同时释放首槽；新错误占优；不得清parity安全请求/DIAG实时/水位。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.FAULT_CLEAR.CLEAR
register_ref: gpio_regs.FAULT_CLEAR.clear
behavior: command
sw_behavior: write command, read zero
hw_behavior: 仅清允许sticky源；ACCESS同时释放首槽；新错误占优；不得清parity安全请求/DIAG实时/水位
collision: set_wins
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

## gpio_regs.FAULT_IRQ_ENABLE.enable

软件成功提交后保持；硬件事件不改变该配置。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.FAULT_IRQ_ENABLE.ENABLE
register_ref: gpio_regs.FAULT_IRQ_ENABLE.enable
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

## gpio_regs.ACCESS_FIRST.address

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.ACCESS_FIRST.ADDRESS
register_ref: gpio_regs.ACCESS_FIRST.address
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

## gpio_regs.ACCESS_FIRST.pprot

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.ACCESS_FIRST.PPROT
register_ref: gpio_regs.ACCESS_FIRST.pprot
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

## gpio_regs.ACCESS_FIRST.write

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.ACCESS_FIRST.WRITE
register_ref: gpio_regs.ACCESS_FIRST.write
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

## gpio_regs.ACCESS_FIRST.valid

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.ACCESS_FIRST.VALID
register_ref: gpio_regs.ACCESS_FIRST.valid
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

## gpio_regs.SNAPSHOT_CMD.trigger

快照同沿捕获全部Bank并递增SEQ；Strap首次全部有效请求捕获至main复位。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.SNAPSHOT_CMD.TRIGGER
register_ref: gpio_regs.SNAPSHOT_CMD.trigger
behavior: capture
sw_behavior: write command, read zero
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

## gpio_regs.SNAP_SEQ.value

快照同沿捕获全部Bank并递增SEQ；Strap首次全部有效请求捕获至main复位。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.SNAP_SEQ.VALUE
register_ref: gpio_regs.SNAP_SEQ.value
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

## gpio_regs.STRAP_VALID.valid

快照同沿捕获全部Bank并递增SEQ；Strap首次全部有效请求捕获至main复位。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.STRAP_VALID.VALID
register_ref: gpio_regs.STRAP_VALID.valid
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

