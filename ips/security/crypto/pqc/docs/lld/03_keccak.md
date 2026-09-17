# PQC KECCAK 微架构（恢复中）

### LLD.MOD.PQC.KECCAK

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.KECCAK
name: pqc_keccak
parent_ref: HLD.MOD.PQC.KECCAK
hld_ref:
- HLD.MOD.PQC.KECCAK
req_ref:
- LRS.FUNC.PQC.KEM_KEYGEN.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_keccak
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 状态与接口

两个 context 各保存 1600-bit 状态、mode、rate、吸收/输出位置、phase、epoch 和
primitive token。Level 2 每个 context 保存两个物理隔离的 1600-bit Boolean share；
禁止共享组合 XOR 重建状态。两个 context 总状态数据为 400 B（Level 0/1）或
800 B（Level 2），控制/ECC 另计。一次只执行一个置换，不复制 24 轮流水。

输入、输出均为 valid/ready，Level 2 每个 share 各 64 bit，keep[7:0] 是连续低位
有效字节掩码。只有 valid && ready 更新位置；输出反压保持数据、keep、last、token。
无秘密的 mode、长度、上下文编号与 epoch 在命令握手时锁存，运行中不读取可写 CSR。
不允许在置换中切换 context；等待输入或完整块输出边界可切换，必须保存位置与 phase。
context 不能被另一 owner 使用，直到清除确认；迟到响应按 epoch 丢弃。

## 吸收、域分离和挤出

字节按 little-endian lane 映射：字节 n 位于 state[8*n +: 8]。
SHA3-256、SHA3-512、SHAKE128、SHAKE256 的 rate 分别为 136、72、168、136 B；
SHA3 suffix=0x06，SHAKE suffix=0x1f。所有 mode 的 rate 都是 8 的整数倍。
每 beat 必须在块边界截断；禁止将超出 rate 的字节静默丢弃。输入侧维护最多一个
64-bit 残留寄存器，只有其旧字节全部消费后才覆盖。

末块在 message_length % rate 处 XOR suffix，在 rate-1 处 XOR 0x80；两个位置
相同则两者都 XOR，不能覆盖。长度为 rate 整倍数时，先置换完整消息块，随后对新块
添加 suffix/0x80 并再次置换。空消息也执行一块 padding。增量 absorb 未收到 final
时不得提前 padding。Level 2 的公开 padding 常量仅 XOR 到 share 0。

挤出只读取 rate 区域。短输出尾拍 keep 精确限制有效字节，两 share 的无效字节均置零；
只有尾拍握手才能报告完成。SHA3 输出分别固定 32/64 B；SHAKE 使用锁存的输出长度。
挤出恰在块边界结束时不做无用的下一次置换；继续请求才触发下一置换。

## 轮调度与随机数

Level 0/1 在一个使能拍组合执行 1 或 2 轮。双轮模式第二轮使用 round+1 的 RC，
round_counter 每次增加 r，完成条件是实际第 23 轮提交，禁止提前 done。
Level 2 保留配置 r=1/2，但都采用下列固定单轮调度，不串接两个 masked χ。

| 阶段 | 使能周期 | 更新内容 |
|---|---|---|
| RAND | 75 | 收集 4800 bit；64 bit/拍，只接受当前 epoch/purpose 的 token |
| LINEAR | 1 | 两 share 分别 theta/rho/pi，结果寄存；NOT 仅作用于一个 share |
| CHI_A | 1 | 1600 个 bit gadget 并行第一寄存级，消费 r/s/m 三组各 1600 bit |
| CHI_B | 1 | gadget 第二寄存级，产生两个 masked AND share |
| COMMIT | 1 | XOR 原线性状态，RC 仅注入 share 0，更新两个状态 share |

每轮 79 拍、每置换 1896 拍为无外部随机背压预算。75 拍 cache 采集不与本轮计算
重叠；600 B cache 为 TOP 随机服务的独占租约，不能另藏一份 600 B Keccak cache。
读 cache 只连接对应 bit gadget 的专属三位，消费后标记不可重用；释放前清除。
状态初始化使用额外 1600-bit fresh mask 使 (M,M) 表示零，64-bit 通道需 26 拍，
末 token 仅 32 bit 有效，其余位丢弃且不得再使用。两个 context 分别独立初始化。

随机服务不足时停在 RAND，所有已接受 token 保留身份；不允许将 entropy_data 的
未握手值、重复 token 或降级为零的掩码送入计算。health failure 触发故障和清除。
每个状态 share 的 theta/rho/pi 各自实现；χ 只调用 03_masked_and 的寄存隔离 gadget。
不得将该数学模型的单次 probe 检查解释为整轮、迭代、状态切换安全证明。

## 周期边界和 PPA

完整稳态块的合同预算为 ceil(rate/8)+P+2，P 为 24/r 或 1896；初始 sharing、
命令启动和最终清除单列，输出/DMA/随机源的外部背压单列。内部 SRAM 仲裁或 cache
冲突不算外部背压，必须在完整算法调度中预留。该预算不能同时重复计算 absorb 和
squeeze 的重叠能力：纯 absorb 块和纯 squeeze 块各自计量，切换及短块另计。

r=2 的 Level 0/1 将两个完整轮放到同一组合路径，代价是更深的 theta/chi 路径；
Level 2 不因 r=2 复制第二套 gadget。1600-bit 并行 χ 需要 1600 个两级 gadget，
大量寄存器与三位随机路由是明确的面积/功耗代价，不能把它写成未掩码面积翻倍。
数据使能仅由公开 FSM/ready 决定；不按 share 内容门控。

## reset、stall、错误和验证关注点

core_clk 单时钟。异步 reset 置所有 valid/状态控制无效，复位同步释放后进入 CLEAR；
两个 context、线性寄存、gadget 全部寄存级、残留和输出寄存器清除完成前不接受命令。
zeroize/fatal 优先于 context 切换和任意握手，同拍输入不消费，输出 valid 立即屏蔽；
完成必须包含 TOP 随机租约清除应答，不能仅置 state=0 后报告。

重点观察空消息、rate-1/rate/rate+1、增量终止、尾拍反压、跨 context 残留、独立 RC、
输出长度、旧 epoch 响应、每轮随机数唯一性以及 fault 与输出握手冲突。
当前 RTL 仍为旧 byte 接口；这里是待实现微设计，不代表已完成宽接口或 masked RTL。

### LLD.DP.PQC.KECCAK.PERM

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.KECCAK.PERM
module_ref: LLD.MOD.PQC.KECCAK
width: 1600
operators:
- theta
- rho
- pi
- chi
- iota
representation: keccak_state
notes: 双 share 的线性步骤独立执行；Level 0/1 每拍 1/2 轮，Level 2 按 RAND/LINEAR/CHI_A/CHI_B/COMMIT 执行一轮。
req_ref:
- LRS.SEC.PQC.ZEROIZE.001
- LRS.PERF.PQC.OVERLAP.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->


### LLD.PIPE.PQC.KECCAK.BLOCK

<!-- LLD_PIPELINE_META
id: LLD.PIPE.PQC.KECCAK.BLOCK
module_ref: LLD.MOD.PQC.KECCAK
stages:
- S_ABSORB
- S_PAD
- S_PERM
- S_SQUEEZE
latency: Level 0/1 置换 24/r 拍；Level 2 置换 1896 拍，初始 sharing 另计
throughput: rate 接口每 share 64 bit/握手；稳态块周期按安全等级分列
stall_conditions: context 冲突时在 block 边界切换，不抢占
req_ref:
- LRS.PERF.PQC.OVERLAP.001
applicability:
  expr: 'true'
END_LLD_PIPELINE_META -->


## 轮模块实现归属

双 share 的一轮执行已独立为 `pqc_keccak_masked_round`，见
[轮模块合同](03_keccak_masked_round.md)。它实例化已实现的 `pqc_masked_and`，
随机数仍来自 TOP.RANDOM；没有新增 600 B cache。旧 `pqc_keccak` 尚未接入该轮
模块，两个 context 的宽接口、初始化 sharing 与完整租约调度仍需继续实现。
