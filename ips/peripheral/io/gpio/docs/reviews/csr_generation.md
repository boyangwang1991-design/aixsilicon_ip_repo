# GPIO CSR 生成检查分离评审

本次按用户“请继续，本次运行不需要额外人工审核”的授权执行作者评审。
SystemRDL 结构和原生 PeakRDL CSR 的可综合逻辑不变；改变的是生成器模板中两条
仅仿真 ACK 检查的物理位置。新入口为 `scripts/regenerate_native_csr.py`。

原生 PeakRDL 1.3.1 输出与既有 CSR/module package 已逐字节比对一致。
脚本仅在模板恰好包含预期的两个 external ACK assertion 时生成，模板形状变化即失败。
模板适配发生在渲染前，不手改生成 RTL；`gpio_native_generation.json` 绑定 RDL、脚本、
原模板指纹及所有生成结果。

两条检查生成到 `verification/assertions/gpio_csr_checks.sv`，以 bind 连接每个
gpio_csr 实例。检查保持在 clk 上升沿且 arst_n 释放时执行，表达式保持原样。
FuseSoC 的全部模块 UT fileset 包含该检查器。DUT `rtl/` 不含仿真断言，真实综合
继续只消费原生生成的可综合逻辑。VCS 单测仍验证合法 APB Access 的 native CSR ready/error。

此评审不替代单测、CDC/RDC、Formal 或 UVM 回归。原生模板的仿真断言也不作为
Formal 已完成的证据。
