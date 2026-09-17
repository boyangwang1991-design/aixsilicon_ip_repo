# PQC 寄存器生成输入的委托评审

用户原文：“后面又需要决策的，按照你推荐的来”。本记录采用 user_delegated，
评审人为执行 Agent，不冒称独立人类评审。范围仅为本次 CSR 生成所需的字段行为与
结构输入；不冻结整个 G2，不表示算法、TOP 集成、寄存器 RTL 或安全验证已通过。

已逐组阅读 HLD 寄存器架构、两册 LLD 字段行为、KEYSLOT 身份约束和完整 SystemRDL，
并运行 systemrdl-compiler elaboration 与选定合同审计（55 个定义、124 个字段、
13 个 W1C 字段；数组按定义计数）。自动审计只覆盖其显式断言，不替代本次语义评审。
外部接口模型与 HLD 均为 APB4，选用 apb4-flat；非法未映射地址需报错。

| 字段组 | 本次检查与生成约束 |
|---|---|
| ID/CAPABILITY | ID 固定版本；能力由综合参数硬件驱动，RO；生成视图不能证明广告功能实现 |
| CTRL/DOORBELL | enable 持续存储且 swwe；其他请求 singlepulse，零写/未选字节不触发；执行模块锁存 |
| STATUS/RESULT/ERROR/COMPLETION | RO、由 owner 驱动；非法高位是间隙；提交顺序仍由 TOP/FE 实现 |
| COMMAND/所有 shadow | 每字段均 swwe；全 32-bit handle、8-bit 地址高位、64-bit 长度；ABI 复位 1、entropy policy 复位 2，其他配置 0 |
| INTR/ALERT | 13 个 W1C 字段，HW set 优先；enable 仅屏蔽 IRQ；test 是脉冲且外层限制生命周期 |
| PERF | next/we、软件清零 swwe、SW/HW 同拍合法 clear 优先；饱和与生产隐藏策略由外层执行 |
| KEY_SLOT | 请求 singlepulse、持久索引/类型；元数据 RO、generation 16 位、domain 8 位、32 项镜像 stride 4；管理不能伪造可信材料 |

评审修正：enable 缺 swwe；KEY_SLOT 四请求缺 singlepulse；COMMAND 的 LLD 复位
文字未保留 ABI=1。均已落入下面指纹绑定的输入。允许据此生成 CSR、Header、RAL、
HTML 和 IP-XACT；生成后必须运行实际 APB UT 验证脉冲、字节写、完整句柄、BUSY
字段保持、W1C 冲突、复位及非法地址。包装层还须接入所有新字段并单独验证。

仍未验收：完整认证元数据生命周期、SELF_TEST 实际 KAT、计数器完整集成、结果/输出
原子发布、完整算法和 Level 2。不得因为此记录或生成编译成功关闭这些实现问题。

## 本次批准输入指纹

| 输入 | SHA256 |
|---|---|
| docs/reviews/delegated_design_decisions.md | `aef7594ec1b898922fc5052ace7ba4ec49aa50cfcde6c7ab33ee2792265f5e04` |
| docs/hld/07_register_arch.md | `a58f6cbcc35ff9380828e873c90bef4227a3532cff9fe1da08f06b654b757dcc` |
| docs/lld/03_register_behavior_1.md | `ac91016503456459a98e973c6cb30e180cefb5d96e7e65ed7b126f2476b95af3` |
| docs/lld/03_register_behavior_2.md | `0f262dcebcfb0bc32912f220d39c98c2e7601ef5191269be282d200753c7497d` |
| docs/lld/03_keyslot.md | `9cfcadb449157e63897485eed8e2af43eb39e81d18029be682335491209c554f` |
| model/external_interface.yaml | `68e7a46f1a8a824a0f4bcb559d2573150d51928d4d55fd5ce445f336d51e23b9` |
| model/micro_design.yaml | `acaf9467d592be32cf4112f3217a06403f9661a639e85e2ce7fdd47fc060b39d` |
| regs/pqc.rdl | `4002b5e8b44bd3deaa98a40a3bad747603a4c67fa68ccee9c466c532db0871e7` |
