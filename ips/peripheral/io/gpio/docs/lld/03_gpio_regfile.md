# GPIO 微设计：gpio_regfile

<!-- LLD_MODULE_META
id: LLD.MOD.GPIO.REG
name: gpio_regfile
hld_ref:
- HLD.MOD.GPIO.REG
req_ref:
- LRS.REG.GPIO.MAP.001
- LRS.REG.GPIO.IDENTITY.002
- LRS.REG.GPIO.FAULT.003
- LRS.REG.GPIO.FIRST.004
- LRS.REG.GPIO.LOST.005
- LRS.REG.GPIO.AONRESULT.006
- LRS.REG.GPIO.DEFAULT.007
parent_ref:
- HLD.MOD.GPIO.TOP
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: gpio_regfile
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
END_LLD_MODULE_META -->

## 周期行为与状态

普通OUT/配置/IRQ使能等状态使用主复位；只由commit写使能更新。读数据组合为沿前状态。原子别名不存储单独影子：SET/CLR/TOGGLE及MASKED均直接作用同一OUT/OE状态。
全局错误汇总由sticky访问/AON/Strap/parity与FIFO/诊断实时视图组成；FAULT_IRQ_ENABLE逐位控制fault_irq。ACCESS_FIRST仅空槽捕获，FAULT_CLEAR.ACCESS与新错误同拍捕获新记录。
PIN_CFG按有效字节合并；只修改OUT/SLEEP/GROUP不重建输入历史。OUT_OD/OUT_INV字段实际修改前OUT_OE必须0。SLEEP_MODE在sleep期间写入错误。
FIFO及AON可选窗口按编译参数读0写忽略，未定义地址仍错。非法Bank/Pin始终错。FAULT_CLEAR不能清parity安全锁存、诊断实时汇总或水位。

<!-- LLD_DATAPATH_META
id: LLD.DP.GPIO.REG
module_ref: LLD.MOD.GPIO.REG
hld_ref:
- HLD.MOD.GPIO.REG
req_ref:
- LRS.REG.GPIO.MAP.001
- LRS.REG.GPIO.IDENTITY.002
- LRS.REG.GPIO.FAULT.003
- LRS.REG.GPIO.FIRST.004
- LRS.REG.GPIO.LOST.005
- LRS.REG.GPIO.AONRESULT.006
- LRS.REG.GPIO.DEFAULT.007
input_width: 32
output_width: 32
latency: 按本册周期行为定义
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

<!-- LLD_RESET_META
id: LLD.RST.GPIO.REG
module_ref: LLD.MOD.GPIO.REG
reset_domain: RST_MAIN
type: async_assert_sync_release
affected_objects:
- LLD.MOD.GPIO.REG
req_ref:
- LRS.REG.GPIO.MAP.001
- LRS.REG.GPIO.IDENTITY.002
- LRS.REG.GPIO.FAULT.003
- LRS.REG.GPIO.FIRST.004
- LRS.REG.GPIO.LOST.005
- LRS.REG.GPIO.AONRESULT.006
- LRS.REG.GPIO.DEFAULT.007
reset_value: 本册及寄存器行为分册所列默认值
release: 本时钟域两拍同步释放
END_LLD_RESET_META -->

## PPA决策

Bank共享采样节拍与分层译码；每脚保留必需状态。参数裁剪使用静态generate，避免关闭功能仍切换。IRQ/readback采用平衡归约；FIFO只单写端口。不同配置分别综合，不从默认配置推断最大配置。
