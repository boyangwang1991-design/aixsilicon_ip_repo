# PQC 验证 Agent 规划

## Agent 复用判定

| 需要的协议 | 候选 VIP | 判定 |
|---|---|---|
| APB4 | `aixsilicon:vip:apb` （若 registry 中非 planned） | 按 registry 实际状态决定复用或本地临时实现 |
| AXI4 master | `aixsilicon:vip:axi4` （若 registry 中非 planned） | 同上 |
| valid/ready 流 | 无需完整 VIP，使用本地 `pqc_utils` 简单驱动 | 本地实现 |

判定原则（`references/reuse-plan.md`）：只有 `registry.yaml` 中 `status` 非 planned 的
VIP 才允许通过 FuseSoC `depend` 引用；`planned`/`developing` 状态时允许 IP 内
temporary self-contained 占位并记录 gap，回填后改回 depend。

**结论**：以读取到的 registry 为准，本 IP 的验证环境在 `verification/env/utils/`
下提供自包含的 APB4 与 AXI4 简化 driver/monitor；若后续 registry 中对应 VIP 达到
可复用状态，则改为 `depend` 引用并移除本地副本。

## Agent 组成

| Agent | 职责 | 位置 |
|---|---|---|
| `pqc_apb_agent` | APB4 读写、字节使能、错误响应 | `verification/env/utils/apb_utils/` |
| `pqc_axi_agent` | AXI4 读/写通道、4 KiB 边界监测与反压 | `verification/env/utils/axi_utils/` |
| `pqc_entropy_agent` | 熵 valid/ready、health 与 domain tag 注入 | `verification/env/utils/entropy_utils/` |
| `pqc_sideband_agent` | lifecycle/tamper/zeroize 电平注入 | `verification/env/utils/sideband_utils/` |

## 复用约束

- 禁止把 VIP 源码复制进 `verification/` 并提交到 IP 仓；
- 若使用 `depend`，在 IP 根 `.core` 的对应 fileset 声明
  `depend: [aixsilicon:vip:<name>:<version>]`，由 edalize 从资产仓拉取；
- 复用记录维护在 [`docs/reuse_plan.md`](../reuse_plan.md)。