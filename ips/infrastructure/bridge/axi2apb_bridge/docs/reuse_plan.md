# X2P 复用规划（CBB / VIP / HWIF）

> 本文档记录 X2P IP 研发过程中的可复用资产判定证据与结论。
> 判据唯一来源：各仓 `registry.yaml`（实时读取，不写死清单）。

## 判定时间与读取对象

- 时间：2026-09-03
- 读取文件：
  - `repos/aixsilicon_cbb_repo/registry.yaml`
  - `repos/aixsilicon_vip_repo/registry.yaml`

## 1. CBB 判定（`aixsilicon_cbb_repo/registry.yaml`）

| CBB | status | 结论 |
|---|---|---|
| `round_robin_arbiter` v0.1.0 | implemented | 可复用；但 X2P 调度语义（R/W 双输入、BEAT/TRANSACTION 双粒度、AXI Beat 内 sub-transfer 原子性、三策略可裁剪）超出该 arbiter 参数化范围 → 记录 gap，IP 内自研 `x2p_scheduler` |
| `fixed_priority_arbiter` v0.1.0 | implemented | 调度需要 R/W 两路 + beat 原子单元，语义不匹配 → 不直接复用 |
| 其余 P2 及以下 arbiter/fifo | implemented / 未发布 | X2P 请求队列与 APB engine 所需的"带满标志 + 原子出队"队列未找到等价 CBB 条目 → 自研 |
| `outstanding_tracker` | 查阅 registry 无 status=implemented 条目 | 不可复用 → X2P 内自研 outstanding 跟踪 |

**结论**：X2P 调度器和请求队列属于 IP 专用逻辑（负向清单：IP 专用逻辑不属于
CBB），在 IP 内自研，不复制/分叉已发布资产。若后续抽象出通用
"beat-atomic R/W scheduler"，可回填 CBB 仓。

## 2. VIP 判定（`aixsilicon_vip_repo/registry.yaml`）

| VIP | status / maturity | 结论 |
|---|---|---|
| `axi4` | developing / M0 / NOT_RUN | 非 planned，可评估接入；但 M0 未达发布门禁，不能单独支撑 G4 |
| `apb` | developing / M0 / NOT_RUN | 同上 |
| `axi4_lite` | planned | 未交付，不可复用 |

**结论**：G4 验证依赖必须 self-contained。UVM 验证环境在 IP 工作区内自建
AXI/APB BFM+Monitor+Checker（协议语义按 AMBA 规范实现），不依赖 VIP 仓库
的 developing 资产。记录为依赖缺口（dependency gap）并回填到 VIP 仓排期。

## 3. HWIF 判定（`aixsilicon_hwif_repo`）

AXI4 / AXI4-Lite / APB4 为行业标准协议，X2P 以标准端口信号建模（不引用
HWIF 定制契约）。X2P 不新增自定义协议接口，无 HWIF 依赖。

## 4. 接入点登记

| 阶段 | 接入/自研 | 说明 |
|---|---|---|
| 03-HLD | 自研 | 调度器、请求队列、APB engine 全部自研 |
| 05-LLD | 自研 | 各模块定案 |
| 06-verification-plan | 自研 | 验证环境 self-contained，VIP gap 记录 |
| 08-FuseSoC | 无外部依赖 | fusesoc.core 仅含 IP 自身 RTL |