# 复用规划：G1 架构评审

本次直接读取当前工作区 CBB/VIP 清单、APB VIP gate_status，以及 HWIF APB4 contract/profile。
读取证据和哈希保存于 reports/quality/g0_approved/*_reuse_read.json；未将旧记忆作为成熟度结论。

| 候选 | 当前状态与匹配情况 | 决策及参数映射 |
|---|---|---|
| aixsilicon:cbb:parity_gen_check:0.1.0 | registry implemented，组合偶校验；DATA_WIDTH 最小为 4 | POLICY 复用。PERM→DATA_WIDTH=8；CFG 补零→DATA_WIDTH=4；PARITY_TYPE=0、PC_IMPL=0。检测位比较/首位置/故障锁存由 IP 负责 |
| aixsilicon:cbb:sync_fifo:0.1.0 | registry implemented；原生深度范围 2～256，接口无清空命令 | 本契约还要求深度1和同周期 clear+push；不直接采用。EVENTS 设计所需队列，不复制 CBB 源码 |
| APB decoder / counters | 匹配清单项为 planned | IP 实现自身译码、事件计数和状态；不得把未交付候选作为门禁证据 |
| APB VIP | registry developing/M1、版本为 '-'；gate_status 声明候选 1.0.0，G0–G3 PASS、G4/G5 PARTIAL、G6 NOT_RUN | 可预备接入，不能作为已发布资格证据。06 阶段核对真实 core/配置能力并记录覆盖缺口；不把版本 '-' 拼成依赖 |
| HWIF APB4 | bus/apb/apb4/contract 存在；基础 profile 为 draft，ADDR_W 仅列 32、DATA_W 列32/64，含可选 wakeup | 本 IP 要求 ADDR_WIDTH 16～32、DATA_WIDTH32、PPROT/PSTRB 必需、无 PWAKEUP，并有 MASTERID 扩展；不能不加说明直接声明整个 profile 兼容 |

## 接入边界

LLD 和 08 阶段重新核对引用版本与实际接口，通过 FuseSoC depend 消费匹配 CBB/VIP，不复制源码。
APB 基础握手可复用，但 MASTERID 的完整位宽、有效性与事务稳定性属于本 IP 扩展，必须单独覆盖。
HWIF profile 差异交给接口 owner 处理或以明确的项目子集绑定描述；此处只记录差异，不擅自修改公共 HWIF。
PC 的实例配置与这些依赖状态相互独立；参数检查通过不能提升资产成熟度。
