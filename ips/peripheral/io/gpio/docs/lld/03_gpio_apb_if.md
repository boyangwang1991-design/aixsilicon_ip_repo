# GPIO 微设计：gpio_apb_if

<!-- LLD_MODULE_META
id: LLD.MOD.GPIO.APB
name: gpio_apb_if
hld_ref:
- HLD.MOD.GPIO.APB
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
- LRS.REG.GPIO.BUS006.001
- LRS.REG.GPIO.BUS006.002
parent_ref:
- HLD.MOD.GPIO.TOP
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: gpio_apb_if
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
END_LLD_MODULE_META -->

## 周期行为与状态

将PSTRB展开为32-bit bitenable。RDL派生描述符返回命中、组、实例号、字段有效掩码、访问类；另计算地址对齐、实际N_GPIO/N_BANK边界、PPROT、锁、能力与编码错误。所有检查完成后生成commit = PSEL & PENABLE & PREADY & !PSLVERR。
PREADY常1。PRDATA在错误、WO读和裁剪功能时为0，否则取PeakRDL读回。PPROT[2]总是拒绝；ACCESS_CTRL_EN关闭时忽略其余两位，但PARITY_INJECT仍按合同要求secure/privileged。
命令和MASKED类必须full strobe，包括写零；有效命令位为零时为成功无操作，AON多有效命令位为错误。其他RW PSTRB=0不触发变化，但对锁定RW有效字段写仍按覆盖目标检查；位操作mask=0不视为修改。
非法字段检查只覆盖实际写入的字节；合并新字后检查相关字段。不可用能力置1错误，不存在位忽略。锁定混合位写整笔拒绝。

<!-- LLD_DATAPATH_META
id: LLD.DP.GPIO.APB
module_ref: LLD.MOD.GPIO.APB
hld_ref:
- HLD.MOD.GPIO.APB
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
- LRS.REG.GPIO.BUS006.001
- LRS.REG.GPIO.BUS006.002
input_width: 32
output_width: 32
latency: 按本册周期行为定义
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

<!-- LLD_RESET_META
id: LLD.RST.GPIO.APB
module_ref: LLD.MOD.GPIO.APB
reset_domain: RST_MAIN
type: async_assert_sync_release
affected_objects:
- LLD.MOD.GPIO.APB
req_ref:
- LRS.REG.GPIO.BUS001.001
- LRS.REG.GPIO.BUS002.001
- LRS.REG.GPIO.BUS002.002
- LRS.REG.GPIO.BUS003.001
- LRS.REG.GPIO.BUS003.002
- LRS.REG.GPIO.BUS004.001
- LRS.REG.GPIO.BUS005.001
- LRS.REG.GPIO.BUS005.002
- LRS.REG.GPIO.BUS005A.001
- LRS.REG.GPIO.BUS005A.002
- LRS.REG.GPIO.BUS005A.003
- LRS.REG.GPIO.BUS005A.004
- LRS.REG.GPIO.BUS006.001
- LRS.REG.GPIO.BUS006.002
reset_value: 本册及寄存器行为分册所列默认值
release: 本时钟域两拍同步释放
END_LLD_RESET_META -->

## PPA决策

Bank共享采样节拍与分层译码；每脚保留必需状态。参数裁剪使用静态generate，避免关闭功能仍切换。IRQ/readback采用平衡归约；FIFO只单写端口。不同配置分别综合，不从默认配置推断最大配置。
