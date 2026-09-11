# GPIO 微设计：gpio_event_fifo

<!-- LLD_MODULE_META
id: LLD.MOD.GPIO.FIFO
name: gpio_event_fifo
hld_ref:
- HLD.MOD.GPIO.FIFO
req_ref:
- LRS.FUNC.GPIO.EVT001.001
- LRS.FUNC.GPIO.EVT001.002
- LRS.FUNC.GPIO.EVT002.001
- LRS.FUNC.GPIO.EVT003.001
- LRS.FUNC.GPIO.EVT003.002
- LRS.FUNC.GPIO.EVT004.001
- LRS.FUNC.GPIO.EVT004.002
- LRS.FUNC.GPIO.EVT004.003
- LRS.FUNC.GPIO.EVT005.001
- LRS.FUNC.GPIO.EVT005.002
- LRS.FUNC.GPIO.EVT005.003
- LRS.FUNC.GPIO.EVT006.001
- LRS.FUNC.GPIO.EVT006.002
- LRS.FUNC.GPIO.EVT007.001
- LRS.FUNC.GPIO.EVT007.002
- LRS.FUNC.GPIO.EVT007.003
parent_ref:
- HLD.MOD.GPIO.TOP
applicability:
  expr: EVENT_FIFO_DEPTH > 0
rtl_intent:
  separate_module: true
  suggested_name: gpio_event_fifo
clock_domains:
- CLK_MAIN
reset_domains:
- RST_MAIN
END_LLD_MODULE_META -->

## 周期行为与状态

timestamp为64-bit主域逐拍加1计数，main复位0。合格IRQ边沿向量与EVENT_ENABLE相与且FIFO.EN时参与记录；最小pin_id获选，记录由pin/direction/timestamp组成，保留位0。
令E为本拍选中事件数，pop_ok=POP && level!=0。flush优先：level归0，E全计lost。非flush时，若E>0且(level<DEPTH或pop_ok)则push一条，否则无push；lost增加E-push。空队列的POP不消费本拍新写。
环形读写指针按DEPTH回绕，level_next=level+push-pop_ok。HEAD为空0，非空时固定队头；成功POP后换到下一条。LOST32饱和，不回绕；CLEAR_LOST当拍从0累加新丢失，OVERFLOW新丢失优先。
WATERMARK只1..DEPTH；dma_req=DMA_EN && level!=0，fault水位=level>=watermark。TS_LO读沿锁存沿前timestamp高位，TS_HI读取该锁存，不消费FIFO。

<!-- LLD_DATAPATH_META
id: LLD.DP.GPIO.FIFO
module_ref: LLD.MOD.GPIO.FIFO
hld_ref:
- HLD.MOD.GPIO.FIFO
req_ref:
- LRS.FUNC.GPIO.EVT001.001
- LRS.FUNC.GPIO.EVT001.002
- LRS.FUNC.GPIO.EVT002.001
- LRS.FUNC.GPIO.EVT003.001
- LRS.FUNC.GPIO.EVT003.002
- LRS.FUNC.GPIO.EVT004.001
- LRS.FUNC.GPIO.EVT004.002
- LRS.FUNC.GPIO.EVT004.003
- LRS.FUNC.GPIO.EVT005.001
- LRS.FUNC.GPIO.EVT005.002
- LRS.FUNC.GPIO.EVT005.003
- LRS.FUNC.GPIO.EVT006.001
- LRS.FUNC.GPIO.EVT006.002
- LRS.FUNC.GPIO.EVT007.001
- LRS.FUNC.GPIO.EVT007.002
- LRS.FUNC.GPIO.EVT007.003
input_width: 128
output_width: 128
latency: 按本册周期行为定义
applicability:
  expr: EVENT_FIFO_DEPTH > 0
END_LLD_DATAPATH_META -->

<!-- LLD_RESET_META
id: LLD.RST.GPIO.FIFO
module_ref: LLD.MOD.GPIO.FIFO
reset_domain: RST_MAIN
type: async_assert_sync_release
affected_objects:
- LLD.MOD.GPIO.FIFO
req_ref:
- LRS.FUNC.GPIO.EVT001.001
- LRS.FUNC.GPIO.EVT001.002
- LRS.FUNC.GPIO.EVT002.001
- LRS.FUNC.GPIO.EVT003.001
- LRS.FUNC.GPIO.EVT003.002
- LRS.FUNC.GPIO.EVT004.001
- LRS.FUNC.GPIO.EVT004.002
- LRS.FUNC.GPIO.EVT004.003
- LRS.FUNC.GPIO.EVT005.001
- LRS.FUNC.GPIO.EVT005.002
- LRS.FUNC.GPIO.EVT005.003
- LRS.FUNC.GPIO.EVT006.001
- LRS.FUNC.GPIO.EVT006.002
- LRS.FUNC.GPIO.EVT007.001
- LRS.FUNC.GPIO.EVT007.002
- LRS.FUNC.GPIO.EVT007.003
reset_value: 本册及寄存器行为分册所列默认值
release: 本时钟域两拍同步释放
END_LLD_RESET_META -->

## PPA决策

Bank共享采样节拍与分层译码；每脚保留必需状态。参数裁剪使用静态generate，避免关闭功能仍切换。IRQ/readback采用平衡归约；FIFO只单写端口。不同配置分别综合，不从默认配置推断最大配置。
