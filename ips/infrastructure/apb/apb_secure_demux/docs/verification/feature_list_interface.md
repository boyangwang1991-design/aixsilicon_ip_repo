# 接口稳定性与隔离

<!-- FEATURE_META
id: FL.APB_SECURE_DEMUX.INTERFACE
name: 接口稳定性与隔离
description: 接口稳定性与隔离
priority: must
req_ref:
- LRS.INTF.APB_SECURE_DEMUX.IF.001
- LRS.INTF.APB_SECURE_DEMUX.IF.002
- LRS.INTF.APB_SECURE_DEMUX.IF.003
- LRS.INTF.APB_SECURE_DEMUX.IF.00401
- LRS.INTF.APB_SECURE_DEMUX.IF.00402
- LRS.INTF.APB_SECURE_DEMUX.SIGNALS.003
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

## 逐需求验收范围

- `LRS.INTF.APB_SECURE_DEMUX.IF.001`：请求和 MASTERID 在 SETUP 到事务完成期间必须稳定；该项作为输入协议假设并通过断言检查。
- `LRS.INTF.APB_SECURE_DEMUX.IF.002`：m_master_id_valid_o 仅在对应 m_psel 为 1 时有效；未选端口该信号固定为 0。
- `LRS.INTF.APB_SECURE_DEMUX.IF.003`：APB3 下游可以通过外部适配连接；本 IP 的输入不能无说明地丢弃 PPROT 和 MASTERID。
- `LRS.INTF.APB_SECURE_DEMUX.IF.00401`：DFX_EN=0 或 dfx_authorized_i=0 时，DFX 观测输出全部为 0。
- `LRS.INTF.APB_SECURE_DEMUX.IF.00402`：irq_o/security_alert_o 不受 DFX 授权控制。
- `LRS.INTF.APB_SECURE_DEMUX.SIGNALS.003`：IP 应提供本分册接口表中列出的全部方向和位宽，数据宽度固定 32 bit，输出身份按端口与请求绑定；不得新增 AXI 或 APB5 接口作为必需依赖。
