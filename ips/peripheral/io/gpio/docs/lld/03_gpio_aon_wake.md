# GPIO 微设计：gpio_aon_wake

<!-- LLD_MODULE_META
id: LLD.MOD.GPIO.AON
name: gpio_aon_wake
hld_ref:
- HLD.MOD.GPIO.AON
req_ref:
- LRS.LP.GPIO.WAK001.001
- LRS.LP.GPIO.WAK001.002
- LRS.LP.GPIO.WAK001.003
- LRS.LP.GPIO.WAK002.001
- LRS.LP.GPIO.WAK002.002
- LRS.LP.GPIO.WAK003.001
parent_ref:
- HLD.MOD.GPIO.TOP
applicability:
  expr: AON_WAKE_EN == 1
rtl_intent:
  separate_module: true
  suggested_name: gpio_aon_wake
clock_domains:
- CLK_AON
reset_domains:
- RST_AON
END_LLD_MODULE_META -->

## 周期行为与状态

各脚固定2级同步，available失效撤销有效和历史；填充后Bank tick按DIV+1采样，连续COUNT+1同值建立或更新检测值。首次有效/COMMIT后重建基线，仅电平允许立即置位。
COMMIT用稳定payload检查输入能力、启用脚模式0..5、锁定脚enable/mode相同，以及任一锁时DIV/COUNT不变；任一不合法则整Bank保持并返回ERROR。合法时原子更新active并重建该Bank输入资格/历史，但不清Pending。
CLEAR按mask清Pending且当拍事件置位优先；LOCK按mask W1S；SNAPSHOT无副作用。所有成功/失败应答都提供完整活动配置与状态，成功应答统一更新主域读回。
WAKE_PENDING只AON冷复位清；wake_req=|Pending，不受关闭WAKE_ENABLE撤销。AON时钟停止时主软件命令可超时而APB不被占住。

<!-- LLD_DATAPATH_META
id: LLD.DP.GPIO.AON
module_ref: LLD.MOD.GPIO.AON
hld_ref:
- HLD.MOD.GPIO.AON
req_ref:
- LRS.LP.GPIO.WAK001.001
- LRS.LP.GPIO.WAK001.002
- LRS.LP.GPIO.WAK001.003
- LRS.LP.GPIO.WAK002.001
- LRS.LP.GPIO.WAK002.002
- LRS.LP.GPIO.WAK003.001
input_width: 32
output_width: 32
latency: 按本册周期行为定义
applicability:
  expr: AON_WAKE_EN == 1
END_LLD_DATAPATH_META -->

<!-- LLD_RESET_META
id: LLD.RST.GPIO.AON
module_ref: LLD.MOD.GPIO.AON
reset_domain: RST_AON
type: async_assert_sync_release
affected_objects:
- LLD.MOD.GPIO.AON
req_ref:
- LRS.LP.GPIO.WAK001.001
- LRS.LP.GPIO.WAK001.002
- LRS.LP.GPIO.WAK001.003
- LRS.LP.GPIO.WAK002.001
- LRS.LP.GPIO.WAK002.002
- LRS.LP.GPIO.WAK003.001
reset_value: 本册及寄存器行为分册所列默认值
release: 本时钟域两拍同步释放
END_LLD_RESET_META -->

## PPA决策

Bank共享采样节拍与分层译码；每脚保留必需状态。参数裁剪使用静态generate，避免关闭功能仍切换。IRQ/readback采用平衡归约；FIFO只单写端口。不同配置分别综合，不从默认配置推断最大配置。
