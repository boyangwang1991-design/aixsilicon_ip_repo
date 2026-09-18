# PQC 从入门到硬件实现

这套中文教材面向第一次接触后量子密码的读者。目标是让你能解释 ML-KEM 与 ML-DSA 的算法流程，读懂本项目 Python 模型，并沿着“输入字节 → 多项式 → 硬件运算 → 输出字节”追踪一次命令。

**阅读基线：2026-09-18 的工作区文件。** 本教材是学习层，不改变已有需求、接口合同或设计状态。项目正在开发：Python 算法互操作成功、底层模型可逆、某个 RTL 单元测试通过，是三种不同证据。当前完整硬件与安全验证尚未闭环，详见[状态与证据](learning/12-status-and-references.md)。

## 按顺序学习

| 顺序 | 材料 | 学完后能回答的问题 | 建议练习 |
|---|---|---|---|
| 1 | [PQC 是什么](learning/01-pqc-basics.md) | KEM、签名、加密分别解决什么问题？ | 画出两方传递的公开数据 |
| 2 | [必要的数学](learning/02-math.md) | 系数、模数、多项式、向量和噪声是什么？ | 手算一次负循环乘法 |
| 3 | [NTT 与模运算](learning/03-ntt-and-modular.md) | 为什么乘法要变换？KEM 与 DSA 的 NTT 有什么不同？ | 跟踪一组蝶形的输入输出 |
| 4 | [哈希、采样与编码](learning/04-hash-sampling-codec.md) | 随机字节如何变成合法系数与标准编码？ | 计算 12-bit packing 长度 |
| 5 | [ML-KEM 完整流程](learning/05-ml-kem.md) | KeyGen、Encaps、Decaps 如何配合？为什么要重加密？ | 跟踪 ML-KEM-768 的对象大小 |
| 6 | [ML-DSA 完整流程](learning/06-ml-dsa.md) | 挑战、拒绝重试、hint 如何构成签名？ | 解释验证方如何恢复高位信息 |
| 7 | [Python 模型逐模块导读](learning/07-model-guide.md) | 哪些模块实际被完整算法调用？哪些是独立实验模型？ | 找出 API 返回值与依赖库的差别 |
| 8 | [硬件架构与模块地图](learning/08-hardware-architecture.md) | 计算、控制、存储和安全模块分别负责什么？ | 从顶层追踪一条数据通路 |
| 9 | [命令、接口与整体时序](learning/09-command-flow.md) | 描述符如何驱动硬件，结果何时算真正完成？ | 手工解码一个 128 B 描述符 |
| 10 | [安全、密钥与故障处理](learning/10-security.md) | 常数时间、掩码、ECC、清零各防什么？ | 区分密文失配与系统错误 |
| 11 | [动手实验与排错](learning/11-labs.md) | 怎样运行例子、看 trace、定位模型差异？ | 完成底层实验与算法闭环 |
| 12 | [实现状态、术语与参考资料](learning/12-status-and-references.md) | 哪些结论已有证据，下一步该读什么？ | 用证据判断一个“PASS” |

不需要先懂格密码证明。第一遍按 1→2→3→4→5→6 建立算法概念；第二遍按 7→8→9→10 将算法映射到工程；最后完成实验。每章末尾有检查题与简短答案，可用来判断是否适合继续。

## 继续学习硬件实现

读完基础章节后，进入独立的[《PQC 硬件教学手册》](hardware_tutorial/index.md)。五章依次讲架构与 RTL、软件命令与接口、计算流程与存储、安全控制案例、RTL 和验证结果的阅读方法。它以教学为主，不占用后续 skill 生成的标准 `user_manual` 或集成文档。

## 如何使用图和代码

七张 ChatGPT 原生文生图已插入对应章节，重点包含 **KEM 解封装计算流程、DSA 签名拒绝循环和硬件模块框图**，另有用途、蝶形和秘密生命周期辅助图。图内保留常见英文术语，图下注有中文说明；精确协议由正文表格与 Mermaid 图给出。图片的提示词和用途保存在[配图记录](assets/learning/README.md)。示例代码在 [learning_demo.py](examples/learning_demo.py)，实际行为仍以链接到的源码为准。

全书统一约定：`q` 为模数，`n=256` 为多项式系数数目，`hat` 或 `â` 表示 NTT 域，`||` 表示字节拼接；`B` 为字节，`bit` 为位。公式中的乘法若操作数是多项式，就表示环上的乘法。图中的“目标架构”不等于当前 RTL 已经完整连通。

## 已有工程文档入口

| 层次 | 入口 | 用途 |
|---|---|---|
| 原始合同 | [pqc_contract.md](../pqc_contract.md) | 查项目约束及 ABI 原始定义 |
| LRS 需求 | [lrs/index.md](lrs/index.md) | 查必须实现的功能与验收条件 |
| HLD 总体方案 | [hld/index.md](hld/index.md) | 查模块边界、资源共享与安全策略 |
| LLD 详细设计 | [lld/index.md](lld/index.md) | 查状态机、接口、表示和流水 |
| 验证计划 | [verification/index.md](verification/index.md) | 查用例、覆盖与检查器 |
| 实现现状 | [reports/report.md](../reports/report.md) | 查未完成项、证据及发布限制 |
| 指定模型 | [pqc_accel_model/README.md](../pqc_accel_model/README.md) | 查可执行 Python 模型 |

遇到冲突时：密码算法查标准及其勘误；接口与需求查项目合同、LRS 和经决策修订的详细设计；“目前实际做了什么”查当前代码与绑定该代码的验证证据。不要用教学简化公式代替实现规范。
