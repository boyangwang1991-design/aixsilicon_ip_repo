# PQC TOP 集成与随机数服务微架构

### LLD.MOD.PQC.TOP

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.TOP
name: pqc_top
parent_ref: HLD.MOD.PQC.TOP
hld_ref:
- HLD.MOD.PQC.TOP
req_ref:
- LRS.CONS.PQC.CORE.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_top
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 集成边界

TOP 负责实例化和连线，不实现密码算法；FE 分配命令，FAULT 独立控制清除，KEYSLOT
与 WORKKEY 分别提供元数据和材料授权。APB、DMA、PIO 不接私钥或单 share 返回口。
本卷细化 `HLD.IF.INT.PQC.RANDOM`；描述的是待实现服务，现有 entropy_ready 赋值
不等同于数据已经被消费。

## 顶层命令身份与子模块边界

TOP 保留命令 epoch 分配及可信上下文扇出；随机服务不自行接收门铃，也不读取 CSR。
FE 接受命令时 TOP 在同一沿锁存新 epoch 与 algorithm/pset，下一拍向执行模块提供
稳定上下文；忙期间上下文不变。clear 优先于接受，禁止同沿发放新身份。冷复位后
从 1 开始，普通 abort/zeroize 不重置 epoch 计数；饱和后禁止新命令直至安全复位。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.TOP.COMMAND_CONTEXT
module_ref: LLD.MOD.PQC.TOP
input_width: 8
output_width: 40
operators: [trusted_context_capture, saturating_epoch_increment, qualified_context_fanout]
representation: public_algorithm_pset_and_command_epoch
req_ref:
- LRS.CONS.PQC.CORE.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

### LLD.MOD.PQC.TOP.RANDOM

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.TOP.RANDOM
name: pqc_random_service
parent_ref: LLD.MOD.PQC.TOP
hld_ref:
- HLD.MOD.PQC.TOP
req_ref:
- LRS.INTF.PQC.ENTROPY.001
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_random_service
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

随机服务独占 cache、收集游标、租约状态和配额；FAULT 拥有全局清除事务，consumer
拥有自身 gadget 寄存器。全局清除汇总全部五个 consumer ack，TOP 不复制 cache
或租约 FSM。五个消费者端口静态连接，grant 与 chunk_valid 均为单热；未经授权的
端口输出置零，不能把完整 cache 无条件广播。所有接口同属 CORE 时钟域。

| 边界 | 方向（相对随机服务） | 接受与保持 |
|---|---|---|
| trusted_context | 输入 | TOP 发布，整个命令保持 |
| lease_req / lease_ready | 输入 / 输出 | FREE 且身份匹配时接受；请求方等待时保持 |
| entropy_valid/data/tag/health | 输入 | 仅 entropy_ready 握手收集 |
| chunk_valid/data/identity | 输出 | 单个 grant 端口，stall 全部保持 |
| release / identity | 输入 | IN_USE 且完整身份匹配时释放 |
| clear_req / clear_epoch | 输入 | 优先屏蔽正常握手；同事务不重复分配 |
| clear_ack / fault | 输出 | ack 绑定清除身份；fault 交 FAULT 锁存 |

## 随机事务身份与配额

TOP 在接受新命令时分配单调递增 command_epoch[31:0]，初值 1；零为无效，达到最大
值后停止新命令并要求安全复位，不静默回绕。每个原语有 primitive_id[31:0]，每个
随机租约有 lease_id[31:0]，同 epoch 内不复用。尝试编号属于内部 token，不经 CSR
输出。purpose 枚举 ALG_SEED、BOOL_MASK、ARITH_MASK、REFRESH、CLEAR；不允许
用相同 token 在两个用途间转换或在 cancel 后回收随机剩余位。

外部 8-bit domain_tag 与锁存的 `{algorithm[3:0],pset[3:0]}` 完整比较，算法与
pset 编码沿用命令定义；不把该标签误作 purpose。purpose、consumer 和 lease_id
由内部可信调度绑定。KAT 注入只在授权测试生命周期通过独立选择入口；生产熵失效
不能切换测试种子。consumer 为 KECCAK、POLY、SAMPLER、CODEC、WORKKEY 五类。

请求锁存 consumer、epoch、primitive_id、purpose、quota_bits[31:0] 和
chunk_bits[12:0]。chunk 范围为 1..4800，必须不超过剩余额度；转换的 32768 bit
额度可用多个 chunk，不能当作 4 KiB 并行缓存。租约只占一个 600 B cache。
调度按公开微程序预留资源；多个未预留请求按固定 consumer 次序服务，不能根据
秘密拒绝/比较结果改变优先级。转换与秘密采样的完整配额表仍是 G2 未完成项。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.TOP.RANDOM
module_ref: LLD.MOD.PQC.TOP.RANDOM
input_width: 64
output_width: 4800
operators:
- domain_health_check
- monotonic_lease_identity
- quota_checked_chunk_collection
- atomic_consume_and_clear
representation: fresh_randomness_never_reconstructed_secret
req_ref:
- LRS.INTF.PQC.ENTROPY.001
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

## 600 B cache 和握手

cache 实现为 75×64-bit 寄存器，以便一次把 4800 bit 连接到 Keccak χ 的三组
1600-bit mask。其他 consumer 通过 chunk 约定连接所需切片。不是双份 ping-pong
cache；多个消费者不同时持有数据。寄存器全宽同步清除的扇出/功耗是明确代价，
若改 SRAM 则须重算读出和清除周期，不能沿用本预算。

E0 接受租约请求，下一拍起收集熵；每次 `entropy_valid && entropy_ready` 仅推进
一次 write_index 和 collected_bits。ready 条件为 COLLECT、有空间、授权有效、
health 好、无 clear/revoke；valid 时 tag 不匹配立即报 RNG_FAULT 且不接受该 beat。
禁止从未握手的数据口采样。末 beat 超出 chunk_bits 的高位置零并丢弃，后续租约
不能复用。1600-bit 初始 sharing 消耗 26 beat，最后 32 bit 丢弃。

收齐后输出 chunk_valid、完整租约身份、有效位数与 cache；consumer 在同一沿原子
接受全部随机内容。valid && !ready 时 cache、身份、有效位数保持不变，entropy_ready=0。
仅 chunk_fire 扣除额度并置 consumed；同一个 lease/chunk_id 的第二次消费为内部
错误。COLLECT/HOLD/IN_USE 都不允许把 cache 交给另一个 consumer。

<!-- LLD_FSM_META
id: LLD.FSM.PQC.TOP.RANDOM
module_ref: LLD.MOD.PQC.TOP.RANDOM
encoding: onehot
reset_state: CLEAR
states: [CLEAR, FREE, COLLECT, HOLD, IN_USE]
illegal_state_handling: fatal
req_ref:
- LRS.INTF.PQC.ENTROPY.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'true'
transitions:
- {source: CLEAR, destination: FREE, condition: cache_and_consumer_clear_ack_and_no_clear_request}
- {source: FREE, destination: COLLECT, condition: authorized_lease_request_fire}
- {source: COLLECT, destination: HOLD, condition: expected_last_entropy_fire}
- {source: HOLD, destination: IN_USE, condition: matched_consumer_chunk_fire}
- {source: IN_USE, destination: COLLECT, condition: matched_release_and_next_chunk_reserved}
- {source: IN_USE, destination: FREE, condition: matched_release_and_no_next_chunk}
- {source: FREE, destination: CLEAR, condition: clear_revoke_or_health_failure_priority}
- {source: COLLECT, destination: CLEAR, condition: clear_revoke_tag_health_or_timeout_failure_priority}
- {source: HOLD, destination: CLEAR, condition: clear_revoke_health_or_timeout_failure_priority}
- {source: IN_USE, destination: CLEAR, condition: clear_revoke_health_or_timeout_failure_priority}
END_LLD_FSM_META -->

未列条件自环。release 要求 epoch/lease/chunk/consumer 全匹配，并保证消费者不再
读取 cache；释放沿清全 cache、collected_bits 和 valid。下一个 COLLECT 从下一沿
收集，不存在旧数据读新数据写混用。Keccak 在 LINEAR 沿消费 mask，CHI_A/CHI_B
使用寄存结果，COMMIT 沿释放并清 cache；随后的 RAND 可直接开始，单轮 75+4 拍
预算不增加独立的 75 拍清除。首个租约分配计入命令启动开销。

## 撤销、故障与全局清除

clear/revoke/health_failure 组合屏蔽 entropy_ready、chunk_valid 和所有普通结果
发布；下一沿清 cache 全部 4800 bit、身份、游标和配额，广播 clear_epoch 给消费者。
ack 在本地已清且所有涉及的 gadget/转换寄存器以相同 clear_epoch 应答后产生；
迟到 ACK 不抵消新的清除。clear 期间持续高电平只维持一个事务，不重复分配 epoch。
健康失败锁存到 FAULT，即便随后 health 恢复也不继续旧 primitive。

timeout 计数只从公开调度和等待状态产生，阈值来自冻结的系统等待预算；超时返回
RNG_FAULT 并清除，不复用旧随机数，不把内部 cache 争用排除出算法周期。
FAULT 自己的超时只能报告清除未完成，不能强制伪造 cache/consumer ack。
全局复位的同步释放、旁带 CDC 与生命周期原子采样见 `04_reset_cdc_error.md`。

## 随机服务 RTL 端口细化

请求入口为可信调度器已仲裁的单路 `req_valid/req_ready`，consumer 编号 0..4
按 KECCAK、POLY、SAMPLER、CODEC、WORKKEY 排列。固定优先级仲裁属于调度器，
服务不接受五路请求的组合混选。`req_wait_limit[31:0]` 必须非零，在接受租约时
锁存；COLLECT、HOLD、IN_USE 连续无进展达到该阈值即报错。只有熵握手、chunk
握手或 IN_USE 中身份合法的 release 才重置等待计数，其他状态的 release 无效。
未就绪时请求保持；FREE 的非法请求握手后进入故障清除，不静默等待有效请求。

`chunk_data[4:0][4799:0]` 只在 HOLD/IN_USE 向当前 owner 开放，其余端口恒零；
`chunk_valid[4:0]` 仅在 HOLD 单热有效，IN_USE 不重复消费。
epoch/primitive/lease/index 为公共身份输出，仅在有效租约内解释。
`release_valid` 是 IN_USE 的单拍事件，没有背压；身份包含 primitive，必须全部
匹配。剩余额度非零时 `next_chunk_bits` 必须在 1..min(4800,remaining) 内；
余额为零忽略 next_chunk_bits 并释放租约。末拍多余随机位丢弃。

全局清除输入由 FAULT 同时广播给五类消费者和服务；服务不另行分配 clear epoch。
`consumer_clear_done[4:0]` 与五个 32-bit epoch 必须全部匹配，未使用消费者也须
应答。冷复位的清除身份为零，正常 clear 事务由 FAULT 提供。保持 clear_req
期间改变 epoch 是协议错误。fault 锁存至冷复位；恢复 health 或普通清除不解除
锁定。lease_counter 只在冷复位清零，达到最大值后拒绝新请求，不回绕。

RTL 已在 `rtl/pqc_random_service.sv` 实现配额、cache、身份；TOP 仍待连接
上下文、consumer 和 FAULT。映射见下；保留 600 B
唯一存储归属。设计模型将检查 token 不重复、背压稳定及撤销优先，不能证明随机源
统计质量、masked 运算组合安全、CDC 或物理侧信道。

<!-- RTL_MAP_META
id: RTL.PQC.RANDOM
rtl_file: rtl/pqc_random_service.sv
rtl_module: pqc_random_service
implements:
- LLD.MOD.PQC.TOP.RANDOM
- LLD.DP.PQC.TOP.RANDOM
- LLD.FSM.PQC.TOP.RANDOM
END_RTL_MAP_META -->

独立模块的实现与 UT 不代表顶层集成完成。分模块不增加缓存或流水拍，75+4 拍预算不变；4800-bit 本地连线
应靠近 Keccak，实际布线时序仍待综合/布局验证，不以本分解宣称 PPA 收敛。
