# 安全 APB Demux

APB4 1→N安全路由IP，目标版本1.0.0。G0/G1/G2已通过；VP0已批准；功能RTL与原生CSR多视图已实现，十个模块UT通过。G3检查进行中，完整UVM、形式与PPA尚未闭环，未发布。

- [完整流程状态](docs/full_process_status.md)
- [LRS](docs/lrs/index.md) / [HLD](docs/hld/index.md) / [LLD](docs/lld/index.md)
- [寄存器生成与检查](regs/README.md) / [G2字段行为批准](docs/reviews/g2_behavior_approval.md)
- [验证方案](docs/verification/index.md) / [VP0评审包](docs/reviews/vp0_review.md)
- [质量门禁](reports/quality/gate_report.md) / [追踪矩阵](reports/quality/trace_matrix.md)

Python使用workflow根uv环境，EDA运行产物位于build。实际集成配置与验证夹具分开受控。
