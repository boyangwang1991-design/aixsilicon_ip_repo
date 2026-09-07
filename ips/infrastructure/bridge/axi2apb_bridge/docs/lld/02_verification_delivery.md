# LLD 验证与交付 - X2P

> 本文档是 LLD 文档的一部分，[主索引](index.md)。

---

## 5. 验证要点

| 验证点 | 说明 | 关联 LLD |
|---|---|---|
| AXI 通道捕获 | AW/W/AR 捕获正确 | LLD.MOD.X2P.FE |
| AW/W 配对 | 三种时序均正确 | LLD.MOD.X2P.QB |
| 队列背压 | 满时不溢出 | LLD.MOD.X2P.QB |
| 仲裁策略/粒度 | 三种策略+两粒度 | LLD.MOD.X2P.SCH |
| Burst 地址 | INCR/FIXED/WRAP/4KB | LLD.MOD.X2P.TE |
| Width/Narrow | 拆解/组装/STRB | LLD.MOD.X2P.TE |
| CDC | async FIFO 无丢事务 | LLD.MOD.X2P.CDC |
| APB FSM | SETUP/ACCESS/WAIT/TIMEOUT | LLD.MOD.X2P.APB |
| Read Assembly | 完整 beat 才 RVALID | LLD.MOD.X2P.RSP |
| Error 聚合 | SLVERR 聚合正确 | LLD.MOD.X2P.RSP |

## 6. RTL TODO 列表（RTL 实现输入）

| 优先级 | RTL 文件 | 模块/实例 | 设计点 | 内容 | 关联需求/HLD ID |
|---|---|---|---|---|---|
| P0 | rtl/x2p_top.sv | x2p_top | 顶层集成 | 例化 FE/QB/SCH/TE/CDC/APB/RSP | HLD.MOD.L1.X2P.FE |
| P0 | rtl/x2p_pkg.sv | x2p_pkg | 参数/类型包 | 定义 AXI/APB 参数常量与内部事务结构体 | - |
| P0 | rtl/x2p_axi_frontend.sv | x2p_axi_frontend | AXI 通道捕获 | AW/W/AR 捕获 + B/R 握手 | LLD.MOD.X2P.FE |
| P0 | rtl/x2p_req_mgr.sv | x2p_req_mgr | 读写队列+配对 | queue + AW/W pair + backpressure | LLD.MOD.X2P.QB |
| P0 | rtl/x2p_scheduler.sv | x2p_scheduler | 仲裁 | 3 策略 + 2 粒度 + beat 原子 | LLD.MOD.X2P.SCH |
| P0 | rtl/x2p_transfer_engine.sv | x2p_transfer_engine | Burst/Width 引擎 | 地址生成、lane、width、sub-transfer | LLD.MOD.X2P.TE |
| P0 | rtl/x2p_cdc.sv | x2p_cdc | CDC | async FIFO（SYNC generate-out） | LLD.MOD.X2P.CDC |
| P0 | rtl/x2p_apb_engine.sv | x2p_apb_engine | APB FSM | SETUP/ACCESS/WAIT/TIMEOUT | LLD.MOD.X2P.APB |
| P0 | rtl/x2p_rsp_mgr.sv | x2p_rsp_mgr | 响应引擎 | read assembly/error agg/ID restore | LLD.MOD.X2P.RSP |
| P1 | rtl/x2p_regslice.sv | x2p_regslice | 流水 | AXI_INPUT_REG/OUTPUT_REG/APB_OUTPUT_REG | LLD.MOD.X2P.FE/APB |
| P2 | constraints/x2p.sdc | - | 时序约束 | clk_axi/clk_apb/async false path | - |

## 7. 交付与映射

- `rtl/*.sv`：可综合 SystemVerilog RTL。
- `fusesoc/*.core`：FuseSoC 打包。
- `verification/`：UVM 验证环境（06-13）。
- `trace/lld_to_rtl.yaml`：16-trace-manager 生成。

## 8. 附录

- AXI4-Lite 无 ID/burst/WRAP 逻辑（generate-out）。
- SYNC 模式无 CDC datapath（generate-out）。
- 同宽配置无 width split/merge datapath（generate-out）。