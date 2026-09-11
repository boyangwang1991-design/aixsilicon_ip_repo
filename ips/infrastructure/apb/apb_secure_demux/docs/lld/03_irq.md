# IRQ 微设计

<!-- LLD_MODULE_META
id: LLD.MOD.APB_SECURE_DEMUX.IRQ
name: irq
hld_ref:
- HLD.MOD.APB_SECURE_DEMUX.IRQ
req_ref:
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.001
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.002
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.003
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.004
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00501
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00502
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00601
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00602
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.007
- LRS.FUNC.APB_SECURE_DEMUX.IRQMAP.010
objects:
- LLD.DP.APB_SECURE_DEMUX.IRQ
rtl_intent:
  separate_module: true
  suggested_name: apb_secure_demux_irq
clock_domains:
- CLK_PCLK
reset_domains:
- RST_PRESET_N
END_LLD_MODULE_META -->

## 粘滞事件与电平输出

raw_next = (raw_q & ~accepted_w1c_mask) | event_bits | persistent_integrity。有效范围之外位始终读零写忽略。event_bits 包括非 CSR 拒绝、CSR失败、地址空洞/多命中、全部完整性候选、仲裁/FIFO丢失、下游错误、首次等待阈值及DFX测试。完整性FATAL作为持续源使其位无法经W1C清除。

INTR_ENABLE 与 ALERT_ENABLE 两份独立掩码，输出分别归约 raw & enable，复位期间强制零。屏蔽不会关掉原始事件、计数、日志或安全拒绝。

INTR_TEST 需管理与当前硬件授权，只把 DFX_TEST 候选置位；不产生真实错误位、日志或拒绝统计。合成日志/测试注入自身仍产生测试位。硬件事件优先于同周期 W1C，清除掩码不清记录/FIFO/计数。复位后 ALERT_ENABLE 恢复合同初值，其余raw/enable清零。
<!-- LLD_DATAPATH_META
id: LLD.DP.APB_SECURE_DEMUX.IRQ
module_ref: LLD.MOD.APB_SECURE_DEMUX.IRQ
operation: 捕获九类粘滞事件，分别通过 IRQ 和 ALERT 使能形成电平输出。清除与新事件竞争时保留事件，FATAL 存续时完整性状态持续置位。
latency: 组合判定；状态仅在 pclk 完成/事件边沿更新
req_ref:
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.001
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.002
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.003
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.004
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00501
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00502
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00601
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.00602
- LRS.FUNC.APB_SECURE_DEMUX.IRQ.007
- LRS.FUNC.APB_SECURE_DEMUX.IRQMAP.010
END_LLD_DATAPATH_META -->
<!-- LLD_IRQ_META
id: LLD.IRQ.APB_SECURE_DEMUX.RAW
source: 全部事件候选以及 persistent FATAL
module_ref: LLD.MOD.APB_SECURE_DEMUX.IRQ
clear: accepted W1C
collision: set_wins
END_LLD_IRQ_META -->
