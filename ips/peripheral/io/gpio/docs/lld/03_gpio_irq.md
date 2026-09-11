# GPIO 微设计：gpio_irq

<!-- LLD_MODULE_META
id: LLD.MOD.GPIO.IRQ
name: gpio_irq
hld_ref:
- HLD.MOD.GPIO.IRQ
req_ref:
- LRS.FUNC.GPIO.IRQ001.001
- LRS.FUNC.GPIO.IRQ002.001
- LRS.FUNC.GPIO.IRQ002.002
- LRS.FUNC.GPIO.IRQ003.001
- LRS.FUNC.GPIO.IRQ003.002
- LRS.FUNC.GPIO.IRQ004.001
- LRS.FUNC.GPIO.IRQ005.001
- LRS.FUNC.GPIO.IRQ006.001
- LRS.FUNC.GPIO.IRQ007.001
- LRS.FUNC.GPIO.IRQ007.002
- LRS.FUNC.GPIO.IRQ008.001
- LRS.FUNC.GPIO.IRQ008.002
- LRS.FUNC.GPIO.IRQ008.003
- LRS.FUNC.GPIO.IRQ009.001
- LRS.FUNC.GPIO.IRQ009.002
parent_ref:
- HLD.MOD.GPIO.TOP
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: gpio_irq
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
END_LLD_MODULE_META -->

## 周期行为与状态

为每脚保持previous_valid/value和previous_detect状态。有效输入且DETECT从0到1、IRQ_MODE被有效字节写到、输入处理重配或首次valid时只建立基线；电平模式在有效时仍允许置位。
合格上升/下降由沿前IN_DATA与历史比较，MODE选择1/2/3；MODE4/5使用有效高/低电平。无效或DETECT=0时不产生硬件事件。IRQ_ENABLE只影响输出，不影响记录。
IRQ_PENDING_next=(old & ~clear)|selected_event|test。RISING/FALLING独立应用置位优先，TEST只影响主Pending。event_o为合格边沿一拍，不包含level或TEST；用于FIFO的timestamp取产生event_o本沿计数。
分组采用掩码后归约OR，每脚仅一路；改变GROUP只改已有Pending路由。IRQ汇总不引入额外寄存延迟。

<!-- LLD_DATAPATH_META
id: LLD.DP.GPIO.IRQ
module_ref: LLD.MOD.GPIO.IRQ
hld_ref:
- HLD.MOD.GPIO.IRQ
req_ref:
- LRS.FUNC.GPIO.IRQ001.001
- LRS.FUNC.GPIO.IRQ002.001
- LRS.FUNC.GPIO.IRQ002.002
- LRS.FUNC.GPIO.IRQ003.001
- LRS.FUNC.GPIO.IRQ003.002
- LRS.FUNC.GPIO.IRQ004.001
- LRS.FUNC.GPIO.IRQ005.001
- LRS.FUNC.GPIO.IRQ006.001
- LRS.FUNC.GPIO.IRQ007.001
- LRS.FUNC.GPIO.IRQ007.002
- LRS.FUNC.GPIO.IRQ008.001
- LRS.FUNC.GPIO.IRQ008.002
- LRS.FUNC.GPIO.IRQ008.003
- LRS.FUNC.GPIO.IRQ009.001
- LRS.FUNC.GPIO.IRQ009.002
input_width: 32
output_width: 32
latency: 按本册周期行为定义
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

<!-- LLD_RESET_META
id: LLD.RST.GPIO.IRQ
module_ref: LLD.MOD.GPIO.IRQ
reset_domain: RST_MAIN
type: async_assert_sync_release
affected_objects:
- LLD.MOD.GPIO.IRQ
req_ref:
- LRS.FUNC.GPIO.IRQ001.001
- LRS.FUNC.GPIO.IRQ002.001
- LRS.FUNC.GPIO.IRQ002.002
- LRS.FUNC.GPIO.IRQ003.001
- LRS.FUNC.GPIO.IRQ003.002
- LRS.FUNC.GPIO.IRQ004.001
- LRS.FUNC.GPIO.IRQ005.001
- LRS.FUNC.GPIO.IRQ006.001
- LRS.FUNC.GPIO.IRQ007.001
- LRS.FUNC.GPIO.IRQ007.002
- LRS.FUNC.GPIO.IRQ008.001
- LRS.FUNC.GPIO.IRQ008.002
- LRS.FUNC.GPIO.IRQ008.003
- LRS.FUNC.GPIO.IRQ009.001
- LRS.FUNC.GPIO.IRQ009.002
reset_value: 本册及寄存器行为分册所列默认值
release: 本时钟域两拍同步释放
END_LLD_RESET_META -->

## PPA决策

Bank共享采样节拍与分层译码；每脚保留必需状态。参数裁剪使用静态generate，避免关闭功能仍切换。IRQ/readback采用平衡归约；FIFO只单写端口。不同配置分别综合，不从默认配置推断最大配置。
