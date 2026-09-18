# PQC POLY 微架构（恢复中）

### LLD.MOD.PQC.POLY

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.POLY
name: pqc_poly_engine
parent_ref: HLD.MOD.PQC.POLY
hld_ref:
- HLD.MOD.PQC.POLY
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.FUNC.PQC.DSA_SIGN.001
- LRS.PERF.PQC.LATENCY.001
applicability:
  expr: 'true'
rtl_intent:
  separate_module: true
  suggested_name: pqc_poly_engine
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 表示与运算资源

存储 word 为 32 bit，内部普通乘法操作数为 23 bit，乘积为 46 bit；KEM 操作数
只使用低 12 bit。所有输入/输出为规范 residue [0,q)，不隐含 Montgomery 因子。
非法范围在受保护的入口处理，不能通过截高位把错误数值变成正常系数。
NTT forward/inverse 的根表、顺序与归一化必须与该表示一致。

每个 NTT_LANES 实例一份乘法/约减资源；Level 2 为两个独立算术 share 域分别
实例化，禁止时分把同一组数据寄存器交替用于两个 share。公共 twiddle 各域相同；
秘密×秘密的乘法不能按两个同域乘积求和，必须显式调度 CODEC 的受保护模乘路径。

### LLD.DP.PQC.POLY.BFLY

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.POLY.BFLY
module_ref: LLD.MOD.PQC.POLY
width: 32
operators:
- canonical_modular_add
- canonical_modular_sub
- unsigned_23x23_multiply
- constant_shift_add_reduction
representation: COEFF_STD_and_NTT_STD
req_ref:
- LRS.FUNC.PQC.KEM_DATAFLOW.001
- LRS.FUNC.PQC.DSA_SIGN.001
applicability:
  expr: 'true'
END_LLD_DATAPATH_META -->

## DSA 固定约减

q=2^23−8191。对任意 46-bit 非负乘积 x，连续三次执行
F(x)=low23(x)+(high23(x)<<13)−high23(x)。每次保持与 x 模 q 同余。
三次保守上界依次为 68719468544、75481088、8454135，因此第三次结果小于 2q，
最后只需一次条件减 q。中间有效宽度为 36、27、24 bit。

每次 fold 独立寄存，最后规范化独立寄存；不用通用 `%` 或额外的商估计乘法器。
这里的固定约减只作用于单个算术 share 的普通 residue，不是把两个 share 合并约减。
脚本 check_modular_reduction.py 给出整数区间/同余证书；RTL 位宽、符号和流水等价
仍须另行验证，不能把该脚本当成 RTL KAT。

## KEM 固定约减

乘积小于 2^24。取 mu=floor(2^24/3329)=5039，估计商为 floor(x*mu/2^24)，
r=x−商*3329，最后一次条件减 q。因为估计商最多小一，r 在 [0,2q)。
常量乘积使用移位加减：5039=2^12+2^10−2^6−2^4−1；3329=2^11+2^10+2^8+1。
前者使用 37-bit 无符号中间量，后者不使用第二个通用乘法器。不能把 24-bit 算法
无条件用于任意 32-bit x。流水对齐 DSA 的四拍约减，空余拍保持公开调度。

KEM base multiplication 的二项结构保留五次标量乘法的固定顺序，不能替换成
DSA 的单系数 pointwise MAC。累加每步规范化，暂不引入未证明的 lazy range。
逆变换逐阶段的模二分操作为 (a+(a[0]?q:0))/2；其整数范围和根表一起验证。

### LLD.PIPE.PQC.POLY.STAGE

<!-- LLD_PIPELINE_META
id: LLD.PIPE.PQC.POLY.STAGE
module_ref: LLD.MOD.PQC.POLY
stages:
- OPERAND_GATHER
- MULTIPLY
- REDUCE_1
- REDUCE_2
- REDUCE_3
- NORMALIZE
- ADD_SUB
- WRITEBACK
stallable: true
flushable: true
req_ref:
- LRS.PERF.PQC.LATENCY.001
applicability:
  expr: 'true'
END_LLD_PIPELINE_META -->

每个 lane 保存公开地址/token、a/b、zeta、acc 和运算类型；收齐操作数后才进入
乘法流水。一次 batch 最多 LANES 个互不依赖 butterfly，batch 全部写回后才能
复用对应 operand slot。不能继续宣称“每 lane 每周期一组 butterfly”，除非银行
发射/回写调度提供实际证明。状态停顿保持全部数据和标签，输出 backpressure
不得仅停止结果而让 valid/token 继续移位。

## 银行映射与依赖

256 系数页面采用固定可逆映射：bank0=i0^i3^i6，bank1=i1^i4^i7，bank2=i2^i5，
row=i[7:3]。同一页整个生命周期使用同一映射，不随 NTT stage 改变。
每个 power-of-two butterfly 的两个索引只差一个 bit，因此落在不同 bank；
同一 batch 的多 lane 仍可能冲突，按公开 lane 顺序分拍收集，不依赖系数值。

bank 接口每域 8×1R1W。请求接受时锁定 lane/operand/token；响应按该身份写回，
不能用当前仲裁选择解释前一拍的读数据。当前 stage 全部 batch 写回后才能开启
下一 stage；in-place 只复用已经没有当前 stage 读者的位置。

该映射的可逆性和伙伴 bank 不冲突可穷举 256 索引/8 个 bit；多 lane 全阶段的
读写时序、MAC 三输入与两个 share 的端口预算仍要在 SRAM/调度分册完成。

## 映射与当前差距

BF/ADDR/ROM 是本模块内部数据通路/地址/常量逻辑，不作为未声明子模块写入
RTL_MAP。保留 LLD.DP.PQC.POLY.BFLY 和 LLD.PIPE.PQC.POLY.STAGE 作为实现对象。
当前 RTL 仍为单 scalar 通路，DSA 使用常量 `%`；上述流水、实际 lane、双 share
和受保护秘密乘法均未实现，不以参数值或已有原语 UT 宣称达标。


## NTT 稳态端口调度

为实现真实 lane 收益，配置六个 batch slot，每两个周期发射一个 batch；每个 slot
最多 LANES 个蝶形。读地址在发射+0/+1 分两拍发出，各 bank 每拍只取一个请求；
在固定两拍 RAM/ECC 返回延迟后，乘法、四拍约减与加减共六拍，回写占发射+10/+11。
forward 为乘法→约减→加减，inverse 为加减/模二分→乘法→约减，保持同样 slot 寿命。
一个 slot 完成第二拍回写后才可复用；不以某些地址恰好单拍完成提前重用标签。

NTT 当前 stage 的蝶形地址互不重叠，批间读写同拍占用的是不同地址；每个 bank
允许同拍一个读和一个写。DMA/Keccak 不得偷用已经预留的物理端口，若配置其他
访问优先级，必须将额外 stall 计入周期并保持全部 slot 的数据/token 同步。
纠正的 ECC 读结果直接送 pipeline；后台 scrub 写只能使用非预留写端口。

每 stage 128 个蝶形，对 L=1/2/4，调度区间为 2*ceil(128/L)+10 周期；DSA 八级、
KEM 七级。命令接收、阶段外数据准备和完成退休另计；MAC、转换和秘密×秘密路径
不套用本 NTT 表。24 个 stage/lane 组合可由 check_ntt_bank_schedule.py 穷举验证
端口数量与六 slot 上界；该检查仍不能证明 RTL 实际实现了上述发射/回写时间。

## 当前候选实现与目标流水的差距

2026-09-18候选 RTL 已把46-bit `%8380417`替换为上述三次固定折叠和一次规范化，
中间位宽36/27/24，功能周期保持原串行调度。当前折叠仍为组合函数，尚未实现
本文目标的逐级寄存流水及多lane资源；不能据此宣称目标频率或每lane吞吐达标。
KEM当前仍为32-bit输入倒数约减，目标24-bit专用流水也待实现与时序验证。
