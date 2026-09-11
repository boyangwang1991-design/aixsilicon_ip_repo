# GPIO 寄存器字段行为 5

结构offset/bit/access/reset仅在SystemRDL定义，本册不复制结构表。

## gpio_regs.AON_STATUS.error

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.AON_STATUS.ERROR
register_ref: gpio_regs.AON_STATUS.error
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

## gpio_regs.AON_STATUS.bank

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.AON_STATUS.BANK
register_ref: gpio_regs.AON_STATUS.bank
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

## gpio_regs.AON_TIMEOUT.cycles

合法范围16..16777215；只控制等待预算，超时不释放BUSY。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.AON_TIMEOUT.CYCLES
register_ref: gpio_regs.AON_TIMEOUT.cycles
behavior: configuration
sw_behavior: RW
hw_behavior: 合法范围16..16777215；只控制等待预算，超时不释放BUSY
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

## gpio_regs.PARITY_INJECT.trigger

secure/privileged且未GLOBAL_LOCK时只翻OUT_DATA parity位；不改数据；安全请求锁存至POR。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.PARITY_INJECT.TRIGGER
register_ref: gpio_regs.PARITY_INJECT.trigger
behavior: command
sw_behavior: write command, read zero
hw_behavior: secure/privileged且未GLOBAL_LOCK时只翻OUT_DATA parity位；不改数据；安全请求锁存至POR
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

## gpio_regs.PARITY_INJECT.bank

secure/privileged且未GLOBAL_LOCK时只翻OUT_DATA parity位；不改数据；安全请求锁存至POR。

<!-- LLD_REG_META
id: LLD.REG.GPIO.GLOBAL.PARITY_INJECT.BANK
register_ref: gpio_regs.PARITY_INJECT.bank
behavior: command
sw_behavior: write command, read zero
hw_behavior: secure/privileged且未GLOBAL_LOCK时只翻OUT_DATA parity位；不改数据；安全请求锁存至POR
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

## gpio_regs.bank[].INPUT_CAP.value

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.INPUT_CAP.VALUE
register_ref: gpio_regs.bank[].INPUT_CAP.value
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

## gpio_regs.bank[].OUTPUT_CAP.value

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.OUTPUT_CAP.VALUE
register_ref: gpio_regs.bank[].OUTPUT_CAP.value
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

## gpio_regs.bank[].IN_SYNC.value

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.IN_SYNC.VALUE
register_ref: gpio_regs.bank[].IN_SYNC.value
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

## gpio_regs.bank[].IN_DATA.value

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.IN_DATA.VALUE
register_ref: gpio_regs.bank[].IN_DATA.value
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

## gpio_regs.bank[].IN_VALID.value

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.IN_VALID.VALUE
register_ref: gpio_regs.bank[].IN_VALID.value
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

