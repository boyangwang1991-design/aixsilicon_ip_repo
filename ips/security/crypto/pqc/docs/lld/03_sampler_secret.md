# PQC 秘密采样：固定候选与公开扫描（draft）

本册属于 `LLD.MOD.PQC.SAMPLER`，补充 `03_sampler.md`；不是额外 RTL 子模块。
Level 0/1 仍使用相同公开循环边界，Level 2 将秘密计数、条件和中间值全部保持两 share。
Verify 中的公开 challenge 可沿同一路径运行，不增加 secret/public 两套算法实现。

## 预算与概率模型

候选预算按一次多项式调用定义，不能为每个输出分别取固定候选然后丢弃其余有效值。

| mode | 固定候选数 | 输入字节数 | 成功条件 |
|---|---:|---:|---|
| ExpandS eta=2 | 512 nibble | 256 | 至少 256 个有效 nibble |
| ExpandS eta=4 | 1024 nibble | 512 | 至少 256 个有效 nibble |
| SampleInBall | 256 byte | 8 B signs + 256 B candidates | 完成 tau 次交换 |

仅假设 XOF 候选为独立均匀量时，ExpandS 的接受概率分别为 15/16 和 9/16，预算
不足概率为 `sum(j=0..255, C(N,j)*p^j*(1-p)^(N-j))`。SampleInBall 在未完成时
每字节接受率至少 `(257-tau)/256`；用该最小概率的 Binomial(256,p) 左尾 `<tau`
作保守上界。脚本用大整数分子/分母精确比较二次幂，不使用浮点下溢来宣称零概率。
当前证书给出每次调用上界：eta2 <2^-544、eta4 <2^-304；tau=39/49/60 分别
<2^-457、<2^-342、<2^-243。数值只在下述概率假设内成立。

这是随机模型下的每次调用概率，不能保证任意 seed 均完成，也不是对 SHAKE 独立性的
证明；合成命令/设备生命周期总调用次数需另作 union bound。预算耗尽时固定边界统一
失败并清除，不输出部分多项式、不改 seed 重试、不降为有偏取模；该路径遵循 HLD
已允许的预算失败语义。成功时须与标准前缀完全一致，失败不能算算法正确结果。

## ExpandS：压紧前 256 个有效样本

scratch 使用已有 conversion_scratch 中一页（每 share 一份），初始化 256 个零值
sharing；结果页仍为 FILLING。accepted_count 使用 9-bit masked 计数并饱和于 256。
公开 candidate_index 顺序取全部 N 个 nibble，不以 accepted_count 控制 FETCH。

每个候选计算 take = accepted && count<256，映射得到 canonical residue；随后执行
公开地址 0..255 的完整扫描。每地址读取旧值，计算 select(take && address==count,
candidate,old)，写回同地址，最后按 take 更新 count。拒绝候选也执行相同读写，
但只重写原值；只修改 scratch，不把拒绝候选写入最终 polynomial buffer。
为共用 SampleInBall 调度，保留第一遍 SCAN_READ 的全页读（不保留整页镜像），
第二遍 SCAN_WRITE 做逐地址读/选择/写；不能用秘密 count 直接形成 RAM 地址。

达到 count=256 后其余候选照常消费/扫描，take 恒 false（仍为 protected signal），
不得缩短循环或关闭秘密数据通路时钟。第 N 个候选退休后统一读取 scratch 并提交
256 个结果，随后才检查预算失败；失败页一直保持不可见并擦除。

## SampleInBall：有序条件交换

signs 为最先消费的 64 bit，低位先用；scratch 256 个系数初始化为零。
accepted_count 为 7-bit masked 计数，i=256-tau+count 用 9 bit（完成后可为 256）。
每个公开候选位置取 byte b，计算 take=(count<tau)&&(b<=i)。所有候选都执行：

1. SCAN_READ 遍历 0..255，以 masked equality/select 汇聚旧 c[b]；不以 b 寻址。
2. SCAN_WRITE 再遍历 0..255，逐地址读取 old，计算
   `next = select(take && addr==b, sign, select(take && addr==i, old_c_b, old))`。
   b==i 时 sign 必须优先，符合顺序赋值；拒绝候选重写 old，不改变多项式。
3. count 增加 take；signs 用 masked select 在原值和右移一位之间选择。
   count/signs 更新仅改变秘密数据，不改变公开 FSM、访存地址或周期使能。

满 tau 后其余候选仍执行相同扫描；最终固定提交 256 系数，非零值为 ±1 的 canonical
residue。符号索引不得重构后寻址；拒绝候选不得消耗 sign。当前 RTL `ball[sqz_data]`
与秘密控制的 SP_BALL 停留周期不满足这些要求。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.SAMPLER.SECRET_SCAN
module_ref: LLD.MOD.PQC.SAMPLER
input_width: 8
output_width: 32
operators: [protected_accept_count, public_address_full_scan, protected_stable_compaction, protected_conditional_swap]
representation: two_share_secret_count_index_and_coefficients
req_ref:
- LRS.FUNC.PQC.DSA_KEYGEN.001
- LRS.FUNC.PQC.DSA_SIGN.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

## SRAM 与 gadget 调度代价

整个调用独占同一 scratch 页的写权。每候选第一遍读 256 word，第二遍读 256 word
并写回 256 word，两域地址相同，身份与 allocation_id 每次检查。第一遍只保留
一个汇聚值，第二遍只保留一个 old/next，不引入未计量的整页寄存器镜像。
每次读等待 SRAM 两拍响应；读/算/写完全退休才推进公共 address。gadget 的随机配额
按公开 mode/candidate/address 预留，不能按 take 或是否写新值申请随机数。

不计读延迟、gadget 和停顿，仅按单个 scratch 逻辑请求端口每拍一个请求，
每候选至少 768 个请求周期。SampleInBall 的 256 候选因此至少 196608 周期；
ExpandS eta2/eta4 分别至少 393216/786432 周期，另加初始化、最终复制和 XOF。
这些是严格串行扫描方案的性能下界，不是已满足 HLD 的实际周期数。

这暴露了明显的性能代价：本方案先确立可核查的顺序等价和访存边界，尚不能冻结
完整 Sign 尝试预算。后续须在相同安全合同下评估并行选择网络/分块压紧，或者按
已有委托重新评审性能预算；不能删除扫描或恢复秘密寻址来让数字变小。
完整 equality/select/计数加法/B2A gadget 清单及其组合证明未完成，G2 继续 open。

`scripts/check_sampler_contract.py` 对照直接算法检查顺序和交换，并输出候选不足
的精确概率证书；其中未掩码条件只是数学抽象，不能用于生产 RTL 或充当侧信道证据。
