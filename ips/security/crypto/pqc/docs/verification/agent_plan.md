# PQC UVM Agent 与环境规划

## 复用依据及限制

2026-09-17 读取 VIP 仓 registry：APB(VIP-004)、AXI4(VIP-001) 均为 developing、
M0、qualification=NOT_RUN、version='-'。源目录中的 core 分别声明
`aixsilicon:vip:apb:1.0.0` 与 `aixsilicon:vip:axi4:1.0.0`，不能据此宣称 registry
已经 qualified。现有 IP 使用 APB 源码引用，不能把该临时方式算作发布依赖闭环。

优先复用这些资产，通过 IP 根 FuseSoC depend 解析；如 core 元数据不兼容，仅可在
build 内以只读源引用作临时 metadata 适配，保存源/适配器哈希和实际编译日志。
资产代码不复制、不在 build 内 patch。依赖资格未闭环记为 release gap；允许早期
集成验证使用现有开发版本，但不把其成功当作 VIP 自身资格通过。

## Agent 角色

| Agent | DUT 角色 / 测试角色 | 模式 | 所有权与职责 |
|---|---|---|---|
| APB VIP | slave / master | active + passive monitor | RAL frontdoor、PPROT/PSTRB、错误、wait、实际事务发布 |
| AXI4 VIP | master / slave memory | active + passive monitor | 输入/描述符只读映像、输出观察区、五通道反压/错误 |
| entropy agent | sink / source | active + monitor | 握手供数、health/tag、算法种子与 mask 的可重现节奏 |
| KM agent | 双向安全事务 / responder | active + monitor | 可信头/材料导入、新密钥托管接收/确认、撤销 |
| reset/sideband agent | 安全输入 / driver | active | 冷复位、异步相位变化、tamper/lifecycle/zeroize |
| IRQ/status monitor | 输出 / observer | passive | 真实事件时间戳、轮询与中断一致性 |

`pqc_virtual_sequencer` 协调各 agent；每个 agent 有独立 cfg、item、sequencer、
driver、monitor，monitor 不读取 driver 私有期望队列。IP 特有 agent 位于
`verification/env/` 下；不重新实现已有 APB/AXI VIP 的协议栈。

## AXI 映射与 memory responder

由 HLD 外部接口与实际顶层确定 address/data/strobe 宽度。当前扁平端口没有完整
ID/SIZE/BURST 通道，接入 VIP 时只能按冻结合同补固定值，不能声称测试了 RTL
根本没有暴露的协议功能。数据总线 64/128/256 三配置分别 elaboration。

输入 memory 只在测试开始装载描述符和输入数据；DUT 接受描述符后修改原内存
用于验证 shadow 原子性。输出区、completion 区与 guard 区分别划定，sequence
禁止预填 expected output。memory responder 根据真实 WSTRB 修改实际内存。
AR/R/AW/W/B 每通道延迟独立，可重放同一服务时序；R/B 可注错，永久阻塞用于
检查超时，不把环境不响应归为正常完成。

## KM 与 entropy

KM driver 模拟可信外部主体，普通 APB 软件不能自行认证来源。材料保持到握手，
完整长度/last 后才确认；可注入错误/旧身份/重复 ACK 与 revoke 并发。生产私钥不
经普通 DMA。当前 RTL 缺 KeyGen 托管及完整身份端口，必须先由 HLD/LLD owner
完成交接；不在 testbench 通过 force/write backdoor 提供缺失功能。

entropy driver 仅在 valid/ready 接受后推进输入。KAT seed 的输入必须使用设计
批准的测试生命周期通路；不通过 force 覆盖 seed 寄存器。Level 2 masks 可改变，
算法 seed 保持以检查输出等价。health/tag 失败与清除同拍优先于消费；无授权时
ready 拉高或消费本身即失败。固定 seed 的使用不构成生产熵质量证明。

## TLM 连接与运行管理

APB monitor → RAL predictor/寄存器 checker/coverage；AXI monitor → DMA tracker/
算法和 completion scoreboard；KM monitor → 密钥及算法 scoreboard；entropy、
IRQ、reset/sideband monitor → 身份/清除 checker 和覆盖。expected KAT loader 只接
scoreboard 与 stimulus 输入源，绝不接实际输出 monitor 或 DUT 算法完成信号。

build/connect 阶段检查所有虚接口、agent 配置及 TLM 连接，缺失即 fatal。
reset monitor 给所有 tracker 相同 reset_epoch，旧事务按排空规则处理，不直接
delete 队列掩盖未完成写响应。test objection 只有在命令完成、输出比对与排空均完成
后才 drop；独立 watchdog 防止挂死。最终 report 检查每类必需 monitor 计数非零。
