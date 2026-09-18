# 教学配图与生成记录

这些 PNG 使用 **ChatGPT 原生 `image_gen`** 生成及校正，未使用百炼或外部 CLI/API。生成日期：2026-09-18。基础图提示词见 [prompts.json](prompts.json)，复杂流程与硬件框图的提示词、参考图和修正指令见 [complex-prompts.json](complex-prompts.json)。图片已复制到本项目，Markdown 使用相对路径，不依赖本机工具缓存。

| 文件 | 插入章节 | 教学目的 | 核对重点 |
|---|---|---|---|
| [01-kem-exchange.png](01-kem-exchange.png) | [第 1 章](../../learning/01-pqc-basics.md) | 公开传公钥和密文，双方本地得到秘密 | 公钥 Alice→Bob；密文 Bob→Alice；不传共享秘密 |
| [02-ntt-butterfly.png](02-ntt-butterfly.png) | [第 3 章](../../learning/03-ntt-and-modular.md) | 一次模乘、模加、模减 | q=17 例子中 t=10、u=13、v=10 |
| [03-shared-architecture.png](03-shared-architecture.png) | [第 8 章](../../learning/08-hardware-architecture.md) | 四类计算模块共享工作存储，密钥材料独立 | 无 Key RAM 直达普通系统内存路径 |
| [04-secret-lifecycle.png](04-secret-lifecycle.png) | [第 10 章](../../learning/10-security.md) | 已导入私钥工作副本的授权、内部使用和擦除 | 公开输出示例为签名；KeyGen 专用托管另见正文 |
| [05-kem-decaps-flow.png](05-kem-decaps-flow.png) | [第 5 章](../../learning/05-ml-kem.md)、[硬件流程](../../hardware_tutorial/03-flows-memory.md) | 解密、G、重加密、全长比较、J、选择的串行推进 | 保留原始 c，两份候选都计算，不公开失配位 |
| [06-dsa-sign-flow.png](06-dsa-sign-flow.png) | [第 6 章](../../learning/06-ml-dsa.md)、[硬件流程](../../hardware_tutorial/03-flows-memory.md) | 签名尝试的计算链和拒绝回路 | 重试仅返回采样；签名包含 c_tilde、z、h |
| [07-hardware-blocks.png](07-hardware-blocks.png) | [硬件教学架构](../../hardware_tutorial/01-architecture-implementation.md) | 前端、序列器、共享计算、存储及安全服务分层 | 安全服务扇出省略，具体连接由正文表格解释 |
| [08-encaps-computation.png](08-encaps-computation.png) | [Encaps 完整跟踪](../../hardware_tutorial/06-encaps-walkthrough.md) | 封装计算主线、共享秘密派生分支 | y 做 NTT、消息只加入 v；循环由正文展开 |

第 8 张图的提示词、两次连接失败及最终重试记录见 [supplement-prompts.json](supplement-prompts.json)。最终图已目视核对并插入章节；全套现有八张图。

部分初始生成请求超时，重试后成功。蝶形图初稿连线错误，未纳入交付；最终使用分步公式图。签名初稿自行添加了错误公式，已移除并修正重试路线，精确公式在正文维护；解封装图补齐了跨行推进箭头。七张交付图均经过目视检查。最终图内主要采用英文标签，各章图注给出中文翻译与适用边界。

图片用于建立直觉，不是 RTL 接线图、物理 floorplan 或安全认证结论。修改算法/模块接口后应同时复核图注；精确的位宽、地址、权限与完成条件以正文及来源文档为准。
