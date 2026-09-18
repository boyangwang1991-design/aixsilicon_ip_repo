# 12 · 实现状态、术语与后续阅读

[上一章](11-labs.md) · [学习首页](../index.md)

## 本教材的来源与适用范围

本教材根据 2026-09-18 工作区中的 `pqc_accel_model` 源码与测试、HLD、LLD、RTL 和统一报告编写。工作区存在其他未提交改动，编写期间报告也有更新；这不是干净发布 tag 或不可变版本快照。最终状态以相应源码及其绑定的执行证据为准。

教程负责解释，不替代正式 LRS/HLD/LLD，也不会把教程文字投影成新的实现要求。教学公式省略的字节编码、域分离、范围检查和安全握手，在真正实现时都不能省略。

## 截至本次复核的能力分层

| 层次 | 已有材料或报告结论 | 仍然不能由此推出 |
|---|---|---|
| 完整 Python 算法 | 封装 kyber-py / dilithium-py；历史报告记载六参数集闭环和 pqcrypto 互操作 | 自研原语已拼成完整算法 |
| Python primitive | 可逆 NTT、模运算、Codec、hashlib 流接口、页权限、描述符 | 全部定宽、周期、完整标准中间排列与 RTL 等价 |
| KEM Encaps/Decaps RTL | 最新统一报告记载串行链及隐式拒绝修复，选定真实 UVM 子集通过 | 全部命令、配置、异常与安全义务已经闭环 |
| DSA 和 KeyGen | 有需求、详细设计与部分 RTL/单测 | 完整 KeyGen/Sign/Verify 硬件已验收 |
| 掩码与随机服务 | 有局部 gadget、模型和单元验证 | 全链路 Level 2 安全实现与组合安全已证明 |
| 门禁/性能 | 存在结构检查与架构预算 | G2 完整技术冻结、G3–G5 签核或实测 PPA |

最新 [reports/report.md](../../reports/report.md) 记载：自检查 UVM 子集 14/14 通过，覆盖两组 seed 的 7 个测试；其中 Decaps 总计 90 条命令，Encaps 12 组 KAT；模块 UT 40 项整体通过，runner 自身故障注入测试 28/28 通过。**这些数字是现有报告的记载，本次文档工作没有重新执行这些 EDA 回归。**

随后代码复核还看到 `pqc_kem_keygen`、`pqc_dsa_verify`、`pqc_key_custody` 新候选及相关顶层连线；最终复核又出现 `pqc_dsa_keygen` 与 `pqc_dsa_sign` 候选。它们说明开发正在推进，不能以尚未更新的报告推断文件不存在，也不能在缺少对应新证据时宣布完整验收。详见[硬件教学手册的实现说明](../hardware_tutorial/01-architecture-implementation.md)。

报告仍明确说明当前不可发布，完整 KEM KeyGen、DSA、Level 2、页授权、epoch/撤销和完整失败退休等未闭环。不要再引用报告早期“Decaps 未驱动”等已被关闭的问题来描述最新候选实现；也不要把修复 Decaps 推广成“整个 PQC 完成”。

## 几个值得边学边核对的差异

| 观察 | 正确读法 |
|---|---|
| Python 模型 README 写 bit-accurate primitive | 逐模块核对，Python 整数和定宽电路仍有差异 |
| README 提到 Barrett | 指定 `modular.py` 没有单独 Barrett API；固定约减设计看 POLY LLD |
| 包枚举有 NTT_MONT | 当前模型/新 POLY LLD 可使用普通 residue；以真实表示合同为准 |
| HLD 写 64-bit rate 流 | 统一报告仍记录 byte RTL 与目标供数带宽的差距 |
| Python key slot 有 secret_key | 它是教学容器，不等同硬件元数据槽和独立材料 RAM |
| 结构检查 G2 pass | LLD 的技术状态和未完成项仍需单独闭合 |
| API 公开 trace 一致 | 不说明真实访问、时间或功耗一致 |
| 已有 ECC/掩码 RTL 文件 | 不说明所有秘密路径都已接入 |

## 术语速查

| 术语 | 中文解释 |
|---|---|
| PQC | 后量子密码 |
| KEM / Encaps / Decaps | 密钥封装机制 / 封装 / 解封装 |
| ML-KEM / ML-DSA | 本项目的格结构密钥封装 / 数字签名算法 |
| ek、dk / pk、sk | 封装钥、解封装钥 / 公钥、私钥 |
| residue / canonical | 模 q 余数 / 满足规定范围和编码 |
| NTT / INTT | 数论变换 / 逆数论变换 |
| butterfly / twiddle | 蝶形基本运算 / 旋转因子常量 |
| base multiplication | KEM 变换域二项式块乘法 |
| MAC | 本文 Poly 中指乘加；密码协议中也可指消息认证码，需看上下文 |
| XOF / SHAKE | 可扩展输出函数 / 基于 Keccak 的一类 XOF |
| CBD | 中心二项分布采样 |
| rejection sampling | 拒绝不符合范围的候选，以得到指定分布 |
| implicit rejection | KEM 对不一致密文派生备用秘密，避免公开失败位 |
| norm / hint | 范数检查 / 高位修正提示 |
| share / masking | 秘密的一份随机化分享 / 在分享上计算的防护 |
| A2B / B2A | 算术分享与布尔分享之间的安全转换 |
| CSR / FE | 控制状态寄存器 / 命令前端 |
| DMA / APB / AXI | 数据搬运引擎 / 控制总线 / 数据总线接口 |
| epoch / token | 命令生命周期身份 / 某个请求的完成归属身份 |
| staging / commit | 暂存候选结果 / 按条件正式发布 |
| zeroize / SECDED | 擦除敏感状态 / 单错纠正双错检测 |
| KAT / oracle | 已知答案测试 / 独立参考实现 |
| PPA / STA / CDC | 功耗性能面积 / 静态时序分析 / 跨时钟域检查 |

## 外部标准：先看入口，再读算法

下列均为官方原始资料。标准页可能发布勘误；正式实现需冻结所采用的标准和勘误版本。本教材核对了标准名称与正式文档入口，没有据此声称完成认证。

1. [FIPS 203 正式入口](https://csrc.nist.gov/pubs/fips/203/final)：ML-KEM；可按概览、辅助算法、NTT、K-PKE、完整 KEM 的顺序读。[标准 PDF](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.203.pdf)。
2. [FIPS 204 正式入口](https://csrc.nist.gov/pubs/fips/204/final)：ML-DSA；先理解签名/验签，再读采样、分解、hint 与编码。[标准 PDF](https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.204.pdf)。

先用本教材读懂每个对象，再对照标准伪代码逐行标注“哈希 / 采样 / 多项式 / 编码 / 控制”。不要先背算法编号；对象在哪个表示域、谁拥有它、何时允许公开，通常比编号更重要。

## 本仓推荐的深入阅读

| 学习目标 | 入口 |
|---|---|
| 逐原语理解模型 | [模型源码地图](07-model-guide.md) |
| 精确模数与流水 | [POLY LLD](../lld/03_poly.md) |
| 采样跨块与秘密地址 | [Sampler 流](../lld/03_sampler.md)、[秘密采样](../lld/03_sampler_secret.md) |
| DSA 拒绝与重放 | [DSA LLD](../lld/03_dsaseq.md)、[容量预算](../hld/08_performance.md) |
| KEM 重加密与选择 | [KEM LLD](../lld/03_kemseq.md)、[Decaps LLD](../lld/03_kemseq_decaps.md) |
| 工作态密钥协议 | [接口](../work_key_ram_interface.md)、[Key Manager 架构](../hld/03_interface_key_manager.md) |
| 掩码与随机量预算 | [Level 2](../hld/09_masking_level2.md)、[执行合同](../hld/09_masking_execution.md) |
| 看一个 PASS 到底覆盖什么 | [统一报告](../../reports/report.md)、[模型历史验证](../../pqc_accel_model/VALIDATION.md) |

## 完成学习后的自测

不看材料，用自己的话解释下面五件事：

1. 为什么 KEM 的网络上传输 c 而不是 K；为什么它仍需要上层身份认证。
2. 为什么 KEM 的 7 层 NTT 不能直接使用 DSA 的逐系数乘法。
3. 为什么采样、压缩和 packing 是不同操作。
4. 为什么共享 engine 的一次 done 必须带正确身份才能推进命令。
5. 为什么模型互操作、RTL 数据正确和侧信道安全是三层独立证据。

能够解释这些问题后，再选择一个具体操作，对照 LLD、RTL 与测试逐阶段追踪，会比直接从顶层几千行连线开始更容易。
