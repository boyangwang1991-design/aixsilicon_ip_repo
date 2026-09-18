# 2 · 从软件命令理解外部接口

[上一章](01-architecture-implementation.md) · [手册首页](index.md) · [下一章](03-flows-memory.md)

## 2.1 顶层接口分组

先把总线理解成两条分工不同的通路：APB 传“要做什么”，AXI 传“要处理的数据”。寄存器像控制台上的开关和状态灯，描述符像一张完整任务单。下面列出接口和地址，是为了带你在源码中找到这些对象，不要求先背地址表。

| 接口 | 关键端口/宽度 | 集成责任 |
|---|---|---|
| APB 控制 | `s_apb_*`，32-bit data，当前 10-bit local address，4-bit strobe | 地址译码、合法属性、等待和错误处理 |
| AXI 数据 | `m_ar/r/aw/w/b_*`，40-bit address，参数化 data | 接收 INCR 请求，保持返回顺序与背压语义 |
| 熵 | `entropy_valid/ready`、64-bit data、8-bit tag、health | 保证来源、健康状态与算法域标签一致 |
| 密钥导入 | `km_begin`、handle/algo/pset/usage/bytes、32-bit data 流 | 可信侧提供完整私钥及授权身份 |
| 新密钥托管 | `km_custody_header_*`、data、ACK 身份与成功位 | 可信接收并明确确认事务与长度 |
| 生命周期/故障 | `tamper_in`、`zeroize_req_in`、`km_revoke`、lifecycle | 可信连接，不交普通软件伪造 |
| 中断 | `irq` | 配置 enable、读取/清除 pending，并核对 completion |
| DFT 注入 | `fault_inject_*` | 限定测试生命周期，不在生产开放 |

顶层 AXI 信号是项目扁平化接口，不能因名称带 AXI 就假定实现所有可选特性。burst 边界、尾拍、响应、取消排空和 outstanding 能力均按 [DMA LLD](../lld/03_dma.md) 与实际 RTL 复核。

`valid && ready` 才接受数据；发送方在阻塞时保持数据、last 和身份。高优先级 clear 需要撤销正常副作用。具体优先级不要依赖软件“正常不会同时发生”的假设。

## 2.2 APB 访问属性

当前 [pqc_apb_if.sv](../../rtl/pqc_apb_if.sv) 的受保护访问条件为：

```text
secure_privileged = privileged && PPROT[0] && !PPROT[1]
```

PPROT=3'b001 表示安全特权数据访问；不能把 100 当成该组合。可信 `privileged` 旁带也必须为真。哪些窗口受保护、忙时写入如何拒绝，查 APB RTL 与[寄存器行为](../lld/03_register_behavior_1.md)。非法访问应得到错误响应；读回零和不产生写副作用需按相应用例验证。

## 2.3 寄存器导航表

以下偏移来自 [pqc.rdl](../../regs/pqc.rdl)，是 **APB 寄存器偏移**，不是内存中 128 B 描述符偏移。完整字段由生成的 [pqc_regs.h](../../sw/include/pqc_regs.h) 提供，软件应使用生成定义。

| 偏移 | 寄存器/组 | 用途 |
|---|---|---|
| 0x000 | ID_VERSION | IP、ABI、微程序版本 |
| 0x004 / 0x008 | CAPABILITY0 / CAPABILITY1 | 算法、lane、SCA、存储、DMA、槽等配置 |
| 0x010 / 0x014 | CTRL / STATUS | enable/abort/zeroize/self_test 与 idle/busy/done/error/locked |
| 0x018 | COMMAND | 操作、参数集、flags、ABI 字段 |
| 0x020..0x078 | 描述符字段寄存器组 | 输入输出地址、长度、策略、超时、CRC 等 |
| 0x07c / 0x080 | KEY_HANDLE / CONTEXT_LEN | 句柄与 context 长度 |
| 0x084 / 0x088 | RESULT / ERROR_CODE | 算法结果和错误信息 |
| 0x090 / 0x094 / 0x098 | INTR_STATE / ENABLE / TEST | 中断 pending、使能、测试 |
| 0x0a0 / 0x0a4 | ALERT_RECOVERABLE / FATAL | 告警 |
| 0x100..0x110 | PERF_* | 周期、停顿和计数；真实事件接入需查状态 |
| 0x1c0..0x1cc | COMPLETION_* | 命令 ID、状态、输出长度和附加信息 |
| 0x1d0 | DOORBELL | 提交触发 |
| 0x1d4 / 0x1d8 | DESC_ADDR_LO / HI | 内存描述符地址 |
| 0x200..0x20c | KEY_SLOT_CTRL / META / GEN / DOMAIN | 受保护密钥槽管理和元数据 |
| 0x210 起，步长 4 | KEY_SLOT_MIRROR[32] | 只读元数据镜像，不是私钥材料窗口 |

两个紧凑编码需要注意：CAPABILITY0 的 ntt_lanes 字段 0 表示 4 lanes，1/2 表示 1/2；CAPABILITY1 的 dma_data_width 字段 0 表示 256 bit，64/128 表示相应位宽。读到 0 不应解释为没有硬件。

RDL 的 reset 值、顶层硬件赋值和算法真实连通状态是不同层次。尤其 COMMAND.ABI 字段 reset 与内存描述符 ABI 不应混用：构造内存描述符时显式填写 ABI=0x10，再按支持情况提交。

## 2.4 描述符和缓冲区

完整布局见[教材命令章](../learning/09-command-flow.md)。描述符 128 B、little-endian，CRC32 覆盖前 124 B；同一份命令应在接受后形成硬件快照。软件不能在尚未完成抓取时修改它。

固定格式输入要求精确长度，输出 buffer 要有足够容量。Verify 的 SRC1 是 `pk || signature`，消息在 SRC0；私钥操作使用句柄和专用材料导入，不能通过普通 DMA 输入私钥。

软件准备 KEM-768 Encaps 时，可分配 1184 B ek、1088 B ciphertext、32 B secret 输出及完成记录；共享秘密目的区域必须符合系统安全策略。算法 seed 不放在普通 SRC1 中。

## 2.5 跟着一条命令理解先后顺序

1. 读取版本、能力和状态；只运行在当前构建及其证据范围内确认支持的命令。
2. 配置系统级 DMA 可达和保护条件。检查输出容量、地址范围和禁止的重叠。
3. 对私钥操作，先完成可信材料导入，并确保元数据和材料身份一致。
4. 准备输入、context、描述符和 completion 区域；计算 CRC，执行平台需要的 cache 维护和写屏障。
5. 空闲时按合同配置描述符地址，最后触发 DOORBELL。不要通过忙时覆盖字段改变正在执行的命令。
6. 轮询或等待 IRQ；收到通知后读 completion 的 command ID、状态、长度和必要结果，不只看一个 done bit。
7. 执行平台需要的读屏障/cache 失效，成功 completion 后才消费输出；按 W1C 语义清中断。
8. 出错时按错误类别收尾，不能把失败区域内容当成合法密码结果。

用练习方式阅读这些步骤：在纸上写出 CPU、FE、DMA、计算引擎、Key Manager 五列，把每一步放到对应列，再标出必须等待谁。地址窗口、pending 行为、SELF_TEST/ZEROIZE 命令及错误退休仍有待闭环项，详见[实现状态与证据](05-verification-status.md)。

## 2.6 正常完成条件

算法 done 仅表示结果已就绪。成功 completion 应等所有允许输出的 DMA 写响应，KeyGen 还需匹配的专用托管 ACK；completion 自身写响应完成后才发布成功中断。消费者以 command ID 关联请求，避免处理上一条命令的粘滞状态。

多 beat 写入不是硬件自动回滚事务。发生中途故障时，软件可能看到目标 buffer 已有部分字节；没有成功 completion 就不得消费这些字节。
