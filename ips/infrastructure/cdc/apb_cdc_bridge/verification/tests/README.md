# APB CDC Bridge cocotb 测试（可选）

本目录用于 cocotb 可选测试（UVM 为主验证路径，cocotb 为降级补充）。

当前状态：**未启用**（UVM smoke 已覆盖基础读写）。
产物写入 `build/tests/`。

如需启用，参考 `pyproject.toml` 的 `verification` 依赖组（cocotb）。
