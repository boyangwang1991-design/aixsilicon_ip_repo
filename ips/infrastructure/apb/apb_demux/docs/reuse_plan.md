# APB Demux 复用规划

> 本文档记录 APB Demux 开发生命周期中各检查点的可复用资产判定
> （CBB / VIP / HWIF），判据唯一来源为各资产仓 `registry.yaml` 的当前字段。

## 1. 判定记录（2026-09-09 读取）

### 1.1 VIP（`aixsilicon_vip_repo/registry.yaml`）

| 资产 | status | profile | 判定 | 接入 |
|------|--------|---------|------|------|
| VIP-004 apb | developing（已实现，`aixsilicon_vip_apb_1.0.0.core` 存在） | FULL_UVM | **可复用**（参考 IP apb_cdc_bridge 同方式使用） | FuseSoC `depend` 或 Makefile 只读引用 `vip/amba/apb/src/*` |

### 1.2 CBB（`aixsilicon_cbb_repo/registry.yaml`）

APB Demux 为轻量互联逻辑（地址译码 + PSEL + 响应 mux），无匹配 CBB 构件；
decoder/mux 为 IP 专用组合逻辑，自研（记录 gap）。

### 1.3 HWIF（`aixsilicon_hwif_repo`）

APB 接口契约由 APB VIP 绑定（`aixsilicon:hwif:apb`），IP 侧以 VIP 的 `apb_if`
为准，不重复定义。

## 2. 复用接入规范

- APB VIP 源码**不复制进 IP 工作区**：`verification/sim/Makefile` 以只读引用
  `$(WORKSPACE)/repos/aixsilicon_vip_repo/vip/amba/apb/src/*`；
- 验证环境 import `apb_pkg::*` / `apb_types_pkg::*`，例化 VIP 的
  `apb_master_agent` / `apb_slave_agent` / `apb_monitor`；
- 不修改 VIP 本体源码。

## 3. 参数映射

| IP 参数 | 说明 |
|---------|------|
| NUM_SLAVES | 下游端口数（RTL 参数化，非 CBB 复用） |
| DATA_WIDTH/ADDR_WIDTH | 位宽参数（RTL 参数化） |

## 4. 变更依赖

- VIP-004 apb 升级：验证环境保持只读引用，无需改动 IP 源码；
- 若 VIP 状态未达门禁，需在验证方案记录 gap 并评估 self-contained 降级。

---

*文档版本: v1.0* | *创建日期: 2026-09-09* | *创建者: IP Development Suite*
