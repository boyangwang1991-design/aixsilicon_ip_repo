# GPIO 寄存器字段行为 9

结构offset/bit/access/reset仅在SystemRDL定义，本册不复制结构表。

## gpio_regs.bank[].INPUT_AVAILABLE.value

所属功能模块提供沿前只读状态；软件写拒绝，裁剪功能写忽略。

<!-- LLD_REG_META
id: LLD.REG.GPIO.BANK.INPUT_AVAILABLE.VALUE
register_ref: gpio_regs.bank[].INPUT_AVAILABLE.value
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

## gpio_regs.pin[].PIN_CFG.filter_en

输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.PIN_CFG.FILTER_EN
register_ref: gpio_regs.pin[].PIN_CFG.filter_en
behavior: configuration
sw_behavior: RW
hw_behavior: 输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写
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

## gpio_regs.pin[].PIN_CFG.debounce_en

输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.PIN_CFG.DEBOUNCE_EN
register_ref: gpio_regs.pin[].PIN_CFG.debounce_en
behavior: configuration
sw_behavior: RW
hw_behavior: 输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写
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

## gpio_regs.pin[].PIN_CFG.in_inv

输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.PIN_CFG.IN_INV
register_ref: gpio_regs.pin[].PIN_CFG.in_inv
behavior: configuration
sw_behavior: RW
hw_behavior: 输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写
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

## gpio_regs.pin[].PIN_CFG.out_od

输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.PIN_CFG.OUT_OD
register_ref: gpio_regs.pin[].PIN_CFG.out_od
behavior: configuration
sw_behavior: RW
hw_behavior: 输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写
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

## gpio_regs.pin[].PIN_CFG.out_inv

输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.PIN_CFG.OUT_INV
register_ref: gpio_regs.pin[].PIN_CFG.out_inv
behavior: configuration
sw_behavior: RW
hw_behavior: 输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写
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

## gpio_regs.pin[].PIN_CFG.irq_mode

输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.PIN_CFG.IRQ_MODE
register_ref: gpio_regs.pin[].PIN_CFG.irq_mode
behavior: configuration
sw_behavior: RW
hw_behavior: 输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写
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

## gpio_regs.pin[].PIN_CFG.irq_group

输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.PIN_CFG.IRQ_GROUP
register_ref: gpio_regs.pin[].PIN_CFG.irq_group
behavior: configuration
sw_behavior: RW
hw_behavior: 输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写
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

## gpio_regs.pin[].PIN_CFG.sleep_mode

输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.PIN_CFG.SLEEP_MODE
register_ref: gpio_regs.pin[].PIN_CFG.sleep_mode
behavior: configuration
sw_behavior: RW
hw_behavior: 输入处理字段变化重建输入历史；IRQ_MODE有效字节写重建IRQ基线；OUT模式修改须OE=0；sleep期间SLEEP_MODE禁写
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

## gpio_regs.pin[].FILTER_CFG.k_minus_one

任何合法写都重建对应处理历史；BankDIV同时重启Bank采样节拍。

<!-- LLD_REG_META
id: LLD.REG.GPIO.PIN.FILTER_CFG.K_MINUS_ONE
register_ref: gpio_regs.pin[].FILTER_CFG.k_minus_one
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

