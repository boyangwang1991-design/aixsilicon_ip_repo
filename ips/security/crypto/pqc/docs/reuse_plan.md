# PQC 复用决策

本次直接读取工作区 CBB/VIP registry 与 VIP gate_status；未假称联网更新了资产仓。
该表是 PQC 当前选型记录，不是全局静态资产目录。LLD/08 接入前须重新检查源版本和依赖闭包。

| 候选资产 | 当前状态 | PQC 用途与决策 |
|---|---|---|
| aixsilicon:cbb:round_robin_arbiter:0.1.0 | implemented | SRAM 的公开请求仲裁应复用；NUM_REQ 映射实际端口数，grant_ack 对应接受请求，禁止把等待响应时的 held request 重新授予 |
| aixsilicon:cbb:sync_fifo:0.1.0 | implemented | 可用于公开预取/响应缓冲；DATA_W 映射 payload+有效字节标记，深度按带宽预算；其无功能 clear，取消须暂停入口并排空，不用于依赖擦除的秘密材料缓存 |
| secded_ecc / memory_ecc_shell / crc_gen_check | planned | 无可依赖的已实现通用资产；保留 IP 当前实现与独立验证，不能宣称复用了已发布 CBB |
| single_bit_synchronizer / reset_synchronizer / async_fifo | planned | 跨域接口在 SoC 边界约束；IP 自有控制同步须由 CDC/RDC 验证，不能冒充已有资产证据 |
| AXI4 VIP | developing，registry M0/NOT_RUN | gate_status G4 NOT_RUN、G5 PARTIAL；可计划接入，不能据此提升 PQC G4 |
| APB VIP | developing，registry M1/PARTIAL_DEVELOPING | gate_status G4/G5 PARTIAL、G6 NOT_RUN；同上 |

### 用户指令：协议 Agent 复用 VIP（2026-09-17）

用户明确要求 **AXI/APB 协议 Agent 复用 `aixsilicon_vip_repo` 的 VIP**，不在 IP 内自研
协议 agent（此前模板实例化出的 `env/utils/apb_utils`、`env/utils/axi_utils` 为
占位自研副本，须废弃并改为 VIP 引用）。据此确定：

| 接口 | 复用 VLNV | PQC 侧例化方式 | 成熟度与证据边界 |
|---|---|---|---|
| APB4 从机（CSR/控制） | `aixsilicon:vip:apb:1.0.0` | `apb_if #(ADDR_WIDTH=10, DATA_WIDTH=32, HAS_PSTRB=1, HAS_PPROT=1)`；agent_mode = Completer（DUT 为 APB slave，VIP 作 Requester 发激励） | gate_status G0–G3 PASS、G4/G5 PARTIAL、G6 NOT_RUN。**可作预备接入，不能单独支撑 PQC G4/G5 门禁**；需在 G4 证据中并列声明该依赖自身的未闭合项 |
| AXI4 主机读/写（DMA 到 SoC 存储） | `aixsilicon:vip:axi4:1.0.0` | `axi4_if` + agent_mode = Slave/Monitor（DUT 为 AXI master，VIP 作被动响应方提供存储模型） | registry M0/NOT_RUN、gate_status G4 NOT_RUN。同为预备接入，门禁边界同上 |

接入纪律（`reuse-plan.md` §1.4 / §4.2）：**只通过 FuseSoC `depend` 引用**，
由 fusesoc/edalize 从 VIP 仓解析到 `build/`；**禁止把 VIP 的 `.sv/.svh` 复制进
`verification/`**，IP 侧只写 `import apb_pkg::*` / 例化 `apb_if`、`apb_agent` 等薄引用。
接口契约以 VIP 所依赖的 `aixsilicon:hwif:apb` / `aixsilicon:hwif:axi4` 为准。

由此产生的待办（未完成前 G4 不能通过）：
1. PQC 根 `.core` 增加 UVM target 的 `depend: [aixsilicon:vip:apb:1.0.0, aixsilicon:vip:axi4:1.0.0]`；
2. `verification/th/harness.sv` 改为例化 VIP `apb_if` / `axi4_if` 并连到 DUT 端口，
   `verification.list` / `check_uvm.f` 删除占位 utils、改为 VIP 包引用；
3. 删除模板生成的 `env/utils/apb_utils`、`env/utils/axi_utils` 占位自研 agent；
4. PQC 自研保留：`pqc_rm`（KEM/DSA 参考模型）、`pqc_checker`、`pqc_fcov`、
   IRQ/密钥/零化等 IP 专用检查（协议无关部分不属于 VIP）。

CBB 的接入必须使用 FuseSoC depend，不能复制或修改共享源码。PQC 根已新增唯一
`aixsilicon_ip_pqc.core`，当前封装已有本地 RTL 和 UT，尚未接入这些候选资产；
它们不是已集成声明。RR 接线与 FIFO 取消/复位语义仍由 LLD 审核。

HWIF 仓本地不存在统一 registry.yaml；现有 contract/interface 可读但尚未建立当前唯一索引
与身份绑定。记录为依赖 gap，不按物理目录反推资产清单、不伪造已完成 HWIF 交接。

## 本次输入指纹

- `repos/aixsilicon_cbb_repo/registry.yaml`：`7d65d918b303fb513bf66f80f9021544db33c2ba442fb1c8a9adde91acbf8b16`
- `repos/aixsilicon_vip_repo/registry.yaml`：`05ce19eac9c290beecbf4096a8d780da7c5da456ea52f55d783eced3bee8915e`
- `repos/aixsilicon_vip_repo/vip/amba/apb/reports/gate_status.md`：`7922bc823e65eb69baad1bdec1e851a538289fa24600ee86525884e54d13b2db`
- `repos/aixsilicon_vip_repo/vip/amba/axi4/reports/gate_status.md`：`dfdc684391a6c69ec1024360a00d53c1abc7f4e65fd9ce742cba9f0234073944`


## Level 2 转换参考审查

参考为 KULeuven-COSIC/X2X 的 MIT 许可版本
`7057a7c34f0b23d4c8969a92a89563185fda04d4`，仅下载到忽略的 build 目录作审查。
其 q 参数传递、固定 13-bit 加法连接、ready_result 保持及 gadget 与本 IP 合同不一致，
不作为已合格的 FuseSoC 生产依赖。采用论文算法，重新实现通用 13/24-bit 单沿转换，
保留来源说明；如实际借用源码，保留 MIT 版权与许可。详情见 HLD 掩码执行合同。
