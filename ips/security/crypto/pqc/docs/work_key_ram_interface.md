# 工作态私钥 RAM 与 Key Manager sideload

本接口落实 2026-09-16 用户确定的密钥边界：长期密钥所有权、分配、版本和授权由外部 Key Manager 管理；PQC 内保留当前运算使用的安全 Key RAM。普通 AXI DMA 和 APB 不连接私钥材料，默认不存在导出接口。

## 生命周期与容量

`pqc_work_key_ram` 默认容量 8192 bytes，存放一个当前工作私钥，使用独立 SECDED(39,32) 数据阵列；不是 `KEY_SLOT_NUM × 8192` 的长期密钥库。六参数集的完整序列化私钥长度分别为 1632、2400、3168、2560、4032、4896 bytes。当前不接受 seed 格式，也不接受公钥作为私钥导入。

复位后先逐 word 物理清除，再允许导入。完整接收并对整把密钥完成 ECC 扫描后才发布有效性。未完整接收、错误 LAST、错误长度/参数/用途不能成为有效私钥。

一次只允许一个工作密钥。有效密钥不能被新的 begin 覆盖。命令完成、abort、外部撤销、zeroize 和 fatal 路径会撤销有效性并逐 word 擦除。当前代价为固定 2048 个写周期的完整擦除，另有控制周期；计数取决于容量，不查看秘密值。

## 外部接口（同核心时钟域）

| 信号 | 语义 |
|---|---|
| `km_begin / km_begin_ready` | 接受导入头。只在工作 RAM 已清空、frontend idle、未锁定时允许；Key Manager 在握手沿提供头字段 |
| `km_handle[31:0]` | 外部 Key Manager 分配的完整 opaque handle，PQC 不截断；owner/generation 的编码和跨复位生命周期由 Key Manager 维护 |
| `km_algo[3:0] / km_pset[3:0]` | algo=1 KEM / 2 DSA；pset=1..3 KEM、4..6 DSA，必须匹配 |
| `km_usage[7:0]` | 操作用途 bitmask；当前私钥消费命令为 KEM Decaps（bit 2）和 DSA Sign（bit 1） |
| `km_bytes[15:0]` | 完整私钥字节数，必须精确匹配参数集且不超过 RAM 容量 |
| `km_valid / km_ready / km_data[31:0] / km_last` | 连续 little-endian word stream；每次握手一个 word；LAST 必须对应最后 word；背压时保持 data/last/valid |
| `km_done` | 完整导入与 ECC 扫描成功的单拍脉冲；之后可提交引用该 handle 的命令 |
| `km_error` | 导入拒绝/不完整的单拍脉冲；随后执行擦除，重新导入须等 begin_ready |
| `km_revoke` | 高优先级撤销当前工作密钥，并触发 IP 全局安全清零；不撤销外部长期密钥所有权 |

KM 必须位于可信安全域。此专用端口的连接授权由 SoC 集成保证，不能接到普通软件可任意写入的外设桥。KM 的 begin 是独立控制握手，不是普通 DMA descriptor 的别名。暂不包含跨时钟域适配。

## 内部读取接口

算法引擎使用 `check_handle / check_algo / check_pset / check_usage` 做完整匹配，然后以 `read_req / read_word` 读取 word。读取通过同步 RAM 级和 ECC 解码级返回 `read_valid / read_data`；越界或授权不匹配返回 `read_error`。未请求、无权限和撤销后的 data 输出为 0。

单 bit 错误在读路径纠正；不可纠正错误产生 sticky `integrity_error`，阻止再次使用材料，并接到顶层 fatal convergence。fatal 锁定只有复位可解除。工作 RAM 的 `zeroize_done` 纳入全局完成汇聚，不能用超时替代实际擦除完成。

**集成状态：**导入、descriptor handle 匹配、命令结束清理、外部撤销和 fatal 清零已接顶层。当前算法 sequencer 的私钥消费调度尚未实现，因此顶层暂将材料 `read_req` 置 0；材料不会被接到公共总线来绕过该缺口。导入扫描使用实际阵列读路径，但这不代表完整 KeyGen/Sign/Decaps 算法已实现。内部新生成私钥向长期 Key Manager 交付/托管的协议也仍需随完整 KeyGen 调度补齐，当前不提供普通 DMA 私钥导出。
