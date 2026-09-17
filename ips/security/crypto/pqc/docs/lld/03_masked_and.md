# 两 share 布尔 AND 微架构

这是由公开算法独立描述的本地 helper，供 Keccak、CODEC 和 SAMPLER 实例化。
不移植 HPC3 参考仓的 VHDL：其代码许可限制非商业用途，参考副本仅在忽略的 build
目录中用于来源审查，不进入交付/生产依赖。算法依据为论文 Algorithm 2/3，实际
RTL 与网表必须重新验证，不能继承论文或参考工程的安全结果。

<!-- LLD_MODULE_META
id: LLD.MOD.PQC.KECCAK.MASK_AND
name: pqc_masked_and
parent_ref: LLD.MOD.PQC.KECCAK
hld_ref:
- HLD.MOD.PQC.KECCAK
- HLD.MOD.PQC.CODEC
- HLD.MOD.PQC.SAMPLER
req_ref:
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'SCA_LEVEL == 2'
rtl_intent:
  separate_module: true
  suggested_name: pqc_masked_and
clock_domains:
- HLD.DOM.CLK.PQC.CORE
reset_domains:
- HLD.DOM.RST.PQC.MAIN
END_LLD_MODULE_META -->

## 位方程与寄存器边界

对每个 bit，以 a0 XOR a1=a、b0 XOR b1=b 表示输入。三个独立 fresh bit 记为
r、s、m，跨 bit、调用和命令均不复用。第一拍同时寄存以下量：

```
A0=a0             A1=a1
B0=b1 XOR r       B1=b0 XOR r
U0=(a0 AND r) XOR s
U1=(a1 AND r) XOR s
D0=a0 AND b0      D1=a1 AND b1
M=m
```

第二拍寄存 c0=D0 XOR (A0 AND B0) XOR U0 XOR M，
c1=D1 XOR (A1 AND B1) XOR U1 XOR M。逐 bit 重构为 a AND b。
这些第一拍寄存器不能被重定时跨过非线性结点，第二拍输出刷新不能删除。
XOR/NOT 等线性操作不通过此 helper，NOT 只翻转一个 share。

<!-- LLD_DATAPATH_META
id: LLD.DP.PQC.MASK_AND.TWO_SHARE
module_ref: LLD.MOD.PQC.KECCAK.MASK_AND
width: WIDTH
operators:
- registered_cross_term_isolation
- independent_output_refresh
representation: boolean_two_share
req_ref:
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'SCA_LEVEL == 2'
END_LLD_DATAPATH_META -->

## 接口与停顿

参数 WIDTH 对所有数据/share/mask 向量同宽，随机输入是三个 WIDTH-bit 向量。
输入包含 token 和 valid；只有全部数据、随机 token 与结果容量就绪时才原子接受。
一条流水最多两个 token，两个数据级和 token valid 使用同一公开 clock-enable。
末级 valid 且下游 not ready 时冻结全流水；禁止前级消耗新的随机数。

不以 share 值产生 clock-enable；bubble 只清 valid，数据寄存器保持，避免人为
插入相关零值转换。新输入只更新完整第一拍寄存器组，不允许按域分别 enable。
zeroize 优先于 enable：组合屏蔽输入 ready/输出 valid，下一沿清两级数据/token
和 valid。ack 在清除后的下一拍给出；reset 同样使所有 valid 失效。
zeroize 后下一调用必须重新取得三个 fresh 向量，不能重放上一调用的随机缓存。

<!-- LLD_PIPELINE_META
id: LLD.PIPE.PQC.MASK_AND.HPC3PLUS
module_ref: LLD.MOD.PQC.KECCAK.MASK_AND
stages:
- CROSS_TERM_ISOLATION
- OUTPUT_REFRESH
stallable: true
flushable: true
req_ref:
- LRS.CFG.PQC.SCA_LEVEL.001
- LRS.SEC.PQC.ZEROIZE.001
applicability:
  expr: 'SCA_LEVEL == 2'
END_LLD_PIPELINE_META -->

接收沿记作 E0，E0 后第一级有效，E1 后第二级输出有效；两个寄存器边界均保留。
调用方按两次 enable 更新调度，不把“E1 可见”误写成无寄存器组合路径。
数据/token 的停顿延迟一致，输入输出可以在连续时钟承载不同请求，但 fresh mask
必须每次接受重新分配。helper 自身不拥有算法密钥、私钥地址或长期随机种子。

<!-- RTL_MAP_META
id: RTL.PQC.MASK_AND
rtl_file: rtl/pqc_masked_and.sv
rtl_module: pqc_masked_and
implements:
- LLD.MOD.PQC.KECCAK.MASK_AND
- LLD.DP.PQC.MASK_AND.TWO_SHARE
- LLD.PIPE.PQC.MASK_AND.HPC3PLUS
generated: false
generator_ref: null
END_RTL_MAP_META -->

## 证明与实现边界

局部数学检查枚举全部 secret/input-mask/fresh-mask 组合，并检查单次执行的单 probe
glitch cone 分布；包含一个故意错误的交叉项作为负向控制。该检查只覆盖所建模的
单 bit 电路，不证明任意反馈/停顿/综合重定时/物理泄漏。G3/G4 仍须核对真实 RTL
和网表的结点、寄存器、跨域连接，以及迭代 transition 的组合假设。

位向量实例每 bit 使用独立随机数；把一个随机 bit 广播给 WIDTH 个 bit 不符合预算
与安全假设。Keccak 的 WIDTH=1600 调用每轮消耗 4800 bit，随机输入不足时整轮等待。

依据：[Low-Latency Hardware Private Circuits](https://eprint.iacr.org/2022/507)。
