# UVM 仿真入口

通过本目录 Makefile 执行实际 FuseSoC/VCS 编译和回归。使用统一工作区的 `uv run --locked make -C <本目录> smoke`，同时传入绝对路径 `SUITE_DIR`、`CBB_ROOT`、`VIP_ROOT`。`compile` 仅编译；`run TEST=<计划中的类名> SEED=42` 用于定位；`regress` 从 verification.yaml 读取全量计划，缺少实现必须失败。

输入哈希、外部依赖身份、编译/运行日志与覆盖数据库位于本 IP 的 `build/sim/run/uvm/`。每次调用创建独立批次，执行期间源码漂移使整批失效。当前整体结论及未完成项只见 [统一报告](../../../reports/report.md)。APB VIP 作为候选预集成依赖，不能据此提升其发布资格。
