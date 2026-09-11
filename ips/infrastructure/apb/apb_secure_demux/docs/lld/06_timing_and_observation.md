# 周期合同和验证观测交接

| 事务/周期 | 上游响应 | 下游 | 本沿状态动作 |
|---|---|---|---|
| direct合法SETUP | ready/error/data=0 | 唯一SETUP | 捕获目标、请求、版本 |
| direct首ACCESS零等待 | 原样完成 | 同周期ACCESS | 一次完成事件并释放 |
| register合法SETUP | 全零 | 不选 | 捕获上下文 |
| register首ACCESS | ready=0 | SETUP | 转入ACCESS，wait_count不加 |
| register次ACCESS零等待 | 原样完成 | ACCESS | 一次完成事件并释放 |
| 任意模式本地拒绝 | 首ACCESS ready/error=1，data=0 | 从SETUP起不选 | 一次失败事件 |
| CSR成功 | 首ACCESS ready=1/error=0 | 不选 | 一次授权副作用 |
| 下游等待 | ready=0 | 保持完整请求 | wait_count及WAIT_TOTAL加1 |
| 完成后背靠背SETUP | 全零 | 可新目标SETUP | 用新active/版本捕获 |
| 在途发现完整性坏 | 继续原下游协议 | 保持 | FATAL锁存并记录，新SETUP阻断 |

读快照在完成边沿取沿前状态；提交在完成边沿更新，下一SETUP可见。没有精度舍入、时钟门控协议、跨域重试或乱序返回。信号中的零宽索引通过max(1,clog2())避免，不因此减弱完整主体比较。

验证需能观察原始译码向量、自然判权、最终判权、捕获上下文、owner命令接受脉冲、commit_attempt、active/shadow及保护位、FIFO count/ptr、四路候选/选择/丢失、快照、本笔wait_count和武装消费。观察通过verification bind或层次引用实现，不新增功能调试端口，不提供安全旁路。

必须独立证明非法请求从未触发下游SETUP、锁不可绕过、原子提交失败全保持、onehot0；有限仿真不能替代穷尽证明。LLD仅定义观察点与设计义务，实际断言、用例与覆盖在VPLAN owner完成。
<!-- LLD_TIMING_META
id: LLD.TIMING.APB_SECURE_DEMUX.DIRECT
interface_ref: LLD.IF.APB_SECURE_DEMUX.EXT_DOWNSTREAM
scenario: direct允许外设零等待
latency_extra: 0
END_LLD_TIMING_META -->
<!-- LLD_TIMING_META
id: LLD.TIMING.APB_SECURE_DEMUX.REGISTER
interface_ref: LLD.IF.APB_SECURE_DEMUX.EXT_DOWNSTREAM
scenario: register允许外设零等待
latency_extra: 1
END_LLD_TIMING_META -->
<!-- LLD_ORDER_META
id: LLD.ORDER.APB_SECURE_DEMUX.SINGLE
model: single_inflight_in_order_no_posted_write
completion: LOCAL首ACCESS或下游完成，不支持取消
END_LLD_ORDER_META -->
