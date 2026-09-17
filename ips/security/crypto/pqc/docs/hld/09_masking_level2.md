# PQC Level 2 掩码架构候选

用户明确要求：“本轮必须同时完成 Level 2 掩码实现与验证”。本配置保持必交，不能以
拒绝 Level 2 参数或仅实现 Level 0/1 关闭问题。本卷是候选架构，不是掩码实现或安全证明。
沿用 LRS 的一阶防护目标；产品配置名 Level 2 不表示二阶掩码，也不表示 NIST 算法等级。

## 表示与安全边界

采用两个 share。字节、Keccak、比较和布尔运算使用 XOR sharing；模 q 的多项式使用
additive sharing，q 分别为 3329、8380417。representation、share domain、事务、
epoch 和 secret 属性参与内部请求授权，不能把两份 share 当成两个无关普通 buffer。

整个敏感链保持掩码：密钥导入/解码、种子、秘密 XOF、采样、NTT、乘加、模约减、
压缩/解压、舍入、范数、hint、KEM 重加密比较和隐式拒绝选择。ML-DSA 的 y、失败
尝试的 z/w/h/c、拒绝累积位也属于保护对象。不能只遮蔽 NTT，然后在 codec 前合并。
只在命令授权的输出边界重构成功结果；私钥托管仍通过专用 Key Manager 通路。
KEM 共享秘密遵循既有输出授权，但不能在选择真实/拒绝密钥前去掩码。

Level 2 的 Key Manager 材料接口使用两条独立 share 数据域和同一个原子握手。
导入及新生成私钥托管均传输 shares；单份材料加片内 splitter 不能保护 splitter
之前的明文输入，因此不作为 Level 2 端到端方案。长度统计针对逻辑密钥字节数，
背压/撤销/错误同时作用于两域；不提供任一 share 的普通总线读回窗口。

## 非线性运算与组合规则

布尔 AND 选择两 share 的 HPC3+ 作为候选基础 gadget，XOR/线性置换逐 share 执行，
公共常数只注入一个 share。HPC3+ 的寄存器边界与新鲜随机数是协议组成部分，不能
把它替换成同周期的四个交叉 AND 再 XOR。Keccak χ 使用这些 gadget，θ/ρ/π 分域，
ι 常数单域注入。初始零状态必须形成随机 sharing，不能把两域都复位为零后直接吸收秘密。

算术 NTT/INTT、公开系数乘法与线性加减在独立 share 域中执行。敏感数据不分时使用
同一个物理乘法器/寄存器保存两个 share；这会引入相邻周期转换泄漏。秘密与秘密的
乘法不得按两个同域乘积代替完整结果：先安全转换到布尔域，以固定宽度的掩码模乘
实现，再安全转换回算术域；LLD 必须计入其开销。尚未批准去分类的候选挑战 c 不能
仅因最终签名包含 c 就提前作为公开操作数处理。

A2B/B2A 以 X2X 的 prime-modulus 路径为候选，必须覆盖两个 q、完整输入范围、
输出规范化与 fresh randomness。不能先相加/XOR 重构，再用随机数重新分拆。
算法版本、参数化/协议修正、组合假设及随机分配见 [执行合同](09_masking_execution.md)。
LLD 必须冻结实际 gadget 清单与每条路径的延迟；不能直接复用参考 RTL 的参数/背压行为。

范数、符号/大小比较、MakeHint、压缩和累积 reject 使用掩码布尔电路。各检查结果
独立锁存并绑定 attempt，最后在统一边界产生一个允许观察的接受/重试决定。
Sign 的固定尝试预算包含所有采样、转换与随机数服务，不暴露内部拒绝原因。

## 随机数供给

以外部安全 TRNG/DRBG 提供的 64-bit valid/ready 通道为根信任输入；不使用 LFSR、
计数器、重复种子或未经分析的片内扩展器代替 fresh randomness。算法随机量与掩码
随机量区分 domain/purpose，并绑定命令与 epoch。已消费随机数不能回退或跨 gadget
复用；停顿保持完整 gadget 状态和随机 token，只有原子接受时才消耗。

随机数缓存按域隔离，不允许通过 APB/DMA/调试读取。health 失败、tag 错误、超时、
撤销和 zeroize 均禁止新操作并清除缓存；不能在熵不足时降级到未掩码路径。
请求顺序依赖公开调度而非掩码结果。外部随机服务等待可单列，但缓存不足、分配、
格式转换和 DUT 内部仲裁必须计入内部周期。固定 Sign 尝试时间以同一外部服务条件比较。

HPC2 只覆盖 glitch 的组合条件，迭代状态更新还涉及 transition，因此本候选选择
HPC3+。仅 Keccak χ，每轮有 1600 个 bit AND，两 share HPC3+ 每 AND 需要三个
fresh bit：每轮 4800 bit，每个置换 115200 bit。64 bit/cycle 的持续输入至少
需要 1800 个供给周期/置换，尚未计入初始化、刷新、采样与转换。预取只改变局部等待，
不能提高连续置换的随机数供给上界。该推导不是当前 RTL 测量，也不是完整预算。

因此原先 24/r 的置换周期不能直接作为 Level 2 验收依据。保留 1/2 轮结构的配置
选择，但受保护路径的实际分阶段调度、随机供给与附加延迟必须独立列出。
用户已批准按安全等级分别验收；候选保守调度为每轮 75 拍随机收集加 4 拍计算，
1896 周期/置换，完整定义见 08_performance.md。算法级转换/采样预算仍需闭环。

## 存储与 PPA 结构预算

LOCAL_SRAM_KIB 仍为逻辑容量。Level 2 为两个 share 配置隔离的数据存储域，每个
逻辑页有两份物理数据页；工作态密钥逻辑容量仍为 8 KiB，物理数据容量为 16 KiB。
ECC、valid/tag 与缓存额外计费。32/64/96 KiB SKU 的本地数据物理容量分别为
64/128/192 KiB，加 Key RAM 后为 80/144/208 KiB，不能沿用非掩码面积估计。

保守镜像所有页，避免在公开/秘密生命周期转换时共享一份残留数据。两域分别提供
bank 端口与数据寄存器；控制/地址可以共享，但调度不依赖 share 值。Tiny 的 28 页
逻辑 Sign 工作集的两页保留空间定为逐系数转换 scratch，分配及阶段搬移见执行合同。
容量/区间检查不替代 LLD 的完整访问与最后消费者证明。

Keccak 状态至少从 1600 增至 3200 bit，还需 gadget 隔离寄存器与随机缓存；NTT
增加第二 share 数据通路，非线性转换路径还要占用逻辑与周期。功耗风险来自更多
翻转和随机流量，门控只依据公开状态。保留物理域隔离和寄存器边界约束，综合不得
把两域跨层优化成未掩码公共逻辑。这里只做结构分析，不引用真实 PPA 数字。

## 交付与验证义务

1. 功能：六个算法参数集与合法硬件配置，Level 2 的 RTL 输出与独立算法参考一致；
   更换掩码随机流不改变算法结果；覆盖拒绝、边界编码、密钥托管和隐式拒绝路径。
2. gadget：验证 HPC3+、A2B/B2A、模乘、比较的重构功能和一阶 probing/组合属性。
   一阶单线统计或检查信号命名不能代替 glitch/transition 下的组合验证。
3. 控制：验证随机 token 不重用、停顿不丢失、域不混用、重试清除旧标记、无提前
   去掩码；熵错误与 zeroize 注入涵盖每个阶段。
4. 实现边界：HPC3+ 文献的 iterated glitch/transition 结论只适用于满足其假设的
   gadget 与组合，不能自动推广到本 IP 的算术域与转换路径。寄存器复用、
   两域多路器、时钟使能及综合后的网表必须另行检查。未通过前 Level 2 不算验收。
5. 泄漏：RTL/网表切换活动只能作为预硅诊断；TVLA、针对性 CPA/EMA 需实际测量
   设备、采集配置与原始 trace。不能把软件统计或 KAT 写成物理泄漏验证通过。

当前只有 VCS 仿真工具路径已确认；尚未取得组合掩码验证工具、完整网表检查、
物理采集设备和 trace 的执行证据。上述缺口保留为本轮验收项，不下调用户范围。

## 设计依据

- [Hardware Private Circuits](https://research.dial.uclouvain.be/entities/publication/3a95c2cf-6e61-4b58-9b5b-2e2a4f027b87)：组合安全框架；不能凭 gadget 名称证明本实现。
- [Low-Latency Hardware Private Circuits](https://eprint.iacr.org/2022/507)：HPC3+ 的 iterated transition/glitch 适用边界。
- [X2X](https://eprint.iacr.org/2024/114)：prime-modulus A2B/B2A 候选依据。
- [ML-DSA y 的侧信道分析](https://eprint.iacr.org/2025/276)：短期采样量仍需保护。
- [OpenTitan KMAC](https://opentitan.org/book/hw/ip/kmac/doc/theory_of_operation.html)：掩码硬件需要额外寄存器、周期和随机供给的工程参考；不移植其吞吐或签核结果。
