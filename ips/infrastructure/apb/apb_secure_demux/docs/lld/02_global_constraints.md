# 全局时序、复位与 PPA 约束

pclk 为唯一功能时钟。preset_ni 异步有效，同步释放由可信集成层提供。本 IP 不私自添加第二级复位同步器来改变首个合法 SETUP 的接收时机。复位期间所有外部响应、选择、身份有效、irq/alert 与 DFX 输出组合门控为零，存储在异步复位分支清除/恢复参数。

策略 active/shadow 同时恢复 RESET_PORT_CFG/RESET_PERM；偶校验按恢复值计算；锁编码恢复合法解锁 01。时间戳、序列、版本、日志与快照、计数、提交状态和注入状态清零。ALERT_ENABLE 恢复契约值，INTR_ENABLE 为零。无 soft reset。存储单写 owner，避免同周期多 always_ff 写同一字段。

内部 CDC 为 NA：所有状态及握手均在 pclk；MASTERID/PPROT、dfx_authorized_i 和 preset_ni 释放的可信同步是系统输入约束。RDC 风险在系统复位配合：复位可中断在途 APB，不能承诺先前下游写撤销。

地址采用至少 ADDR_WIDTH+1 的无符号扩展，配置检查使用更宽整数避免 BASE+SIZE 溢出。CSR_SIZE 扩展后计算；非法范围、重叠、掩码空、主体超域及数组长度错误在构建前拒绝。可综合逻辑中先判域再索引。计数器使用额外一位计算饱和；时间戳、版本与事件序列按各自宽度自然回绕。

STA 的四类端点必须约束：上游地址/身份/属性→下游选择，全部策略完整性→新 SETUP 选择，下游响应→上游响应，策略更新/事件归约→寄存器。REGISTER_MODE 只寄存请求，不切断响应路径。不得以多周期或 false path 隐藏 direct 准入路径。

面积控制：PERM 仅存八位，CFG 仅存两位；日志存储 depth×256 位；关闭 DFX 时不生成端口计数和注入状态，但全局日志时间戳保留。完整性归约按端口分层，组合延迟可能较长，但不允许增加故障检测拍数。综合应报告典型/最大、direct/register 四个点；无实际 PDK、corner、SDC 输入前不填写 MHz、面积或功耗。
<!-- LLD_RESET_META
id: LLD.RESET.APB_SECURE_DEMUX.FUNCTIONAL
module_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
- LLD.MOD.APB_SECURE_DEMUX.DECODE
- LLD.MOD.APB_SECURE_DEMUX.ACCESS
- LLD.MOD.APB_SECURE_DEMUX.ROUTE
- LLD.MOD.APB_SECURE_DEMUX.CSR
- LLD.MOD.APB_SECURE_DEMUX.POLICY
- LLD.MOD.APB_SECURE_DEMUX.EVENTS
- LLD.MOD.APB_SECURE_DEMUX.IRQ
- LLD.MOD.APB_SECURE_DEMUX.DFX
reset_domain: RST_PRESET_N
type: async_assert_sync_release
polarity: active_low
release_owner: trusted integration
reset_values: RESET policies; locks=01; ALERT_ENABLE=0x9b; all other mutable state=0
END_LLD_RESET_META -->
<!-- LLD_PPA_META
id: LLD.PPA.APB_SECURE_DEMUX.CRITICAL_PATHS
decision: 层次化并行完整性归约；保持 SETUP 组合准入；不加 pipeline
tradeoff: 完整性归约扇出与组合面积换取即时阻断
constraints: 实际 PDK/corner/SDC 未提供；禁止虚构签核
END_LLD_PPA_META -->
