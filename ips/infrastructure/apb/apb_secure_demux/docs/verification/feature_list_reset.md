# 复位状态及恢复

<!-- FEATURE_META
id: FL.APB_SECURE_DEMUX.RESET
name: 复位状态及恢复
description: 复位状态及恢复
priority: must
req_ref:
- LRS.RESET.APB_SECURE_DEMUX.RST.001
- LRS.RESET.APB_SECURE_DEMUX.RST.00201
- LRS.RESET.APB_SECURE_DEMUX.RST.00202
- LRS.RESET.APB_SECURE_DEMUX.RST.003
- LRS.RESET.APB_SECURE_DEMUX.RST.004
- LRS.RESET.APB_SECURE_DEMUX.RST.005
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.FRONTEND
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

## 逐需求验收范围

- `LRS.RESET.APB_SECURE_DEMUX.RST.001`：preset_ni 有效时全部 m_psel/m_penable/m_master_id_valid=0，上游 PREADY=0、PSLVERR=0、PRDATA=0，irq/alert 和 DFX 观测为零。
- `LRS.RESET.APB_SECURE_DEMUX.RST.00201`：复位释放必须同步；释放后接收合法的新 SETUP，不将无先行 SETUP 的 ACCESS 视为新事务。
- `LRS.RESET.APB_SECURE_DEMUX.RST.00202`：输入违规只要求断言报告并保持下游不选中，不承诺正常 APB 完成。
- `LRS.RESET.APB_SECURE_DEMUX.RST.003`：复位清除锁、FATAL、日志/快照/FIFO、计数、时间戳、版本、提交状态、注入武装；策略恢复 RESET 参数，INTR_ENABLE=0，ALERT_ENABLE=0x9B。
- `LRS.RESET.APB_SECURE_DEMUX.RST.004`：复位中断在途事务属于系统复位行为，系统须协调上游、桥、下游的隔离与恢复；本 IP 不保证复位前写是否已发生。
- `LRS.RESET.APB_SECURE_DEMUX.RST.005`：不存在软件 soft reset；功能门控只允许在无进行中事务且系统保证配置/状态保持时由外部实现，禁止在等待期间停止必要的响应时钟。
