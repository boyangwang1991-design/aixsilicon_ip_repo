# PQC 内部随机数事务

<!-- HLD_INTERFACE_META
id: HLD.IF.INT.PQC.RANDOM
name: random_token_service
scope: internal
protocol: atomic_random_stream
role: producer
owner_module: HLD.MOD.PQC.TOP
clock_domain: HLD.DOM.CLK.PQC.CORE
reset_domain: HLD.DOM.RST.PQC.MAIN
req_ref:
- LRS.INTF.PQC.ENTROPY.001
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'true'
END_HLD_INTERFACE_META -->

TOP 将外部随机服务分配给 KECCAK、POLY、SAMPLER、CODEC 和 WORKKEY。请求包含
命令/epoch、公开原语类别、用途、需要的 bit 数及配额；返回随机 token、实际位数和
完整性状态。算法随机量、掩码、刷新、算术 mask 和清除各有独立用途，不共享 token。

预留和消费分离：只有 consumer 的原子接受才消耗随机内容；背压保持 token 和数据，
不能每拍替换 fresh 输入而让停顿中的 gadget 部分级继续执行。没有额度时不接受
新的原语；有额度不表示已经取得数据，内部缓存/分配等待仍计入周期。

consumer 不提交由秘密检查结果决定的请求长度或仲裁优先级。需要变长算法采样时，
实际调度采用已批准的公开上限和填充。拒绝后的旧 token 不进入下一 attempt。
所有 consumer 以同一 epoch 接受清除；TOP 仅在缓存、分配状态及 consumer 内部
随机寄存器均退休后汇聚 zeroize_done。健康失败和超时不得切换到软件种子或未掩码路径。

这是待实现的内部合同。当前顶层 entropy 端口未消费，不代表此服务已经存在。
