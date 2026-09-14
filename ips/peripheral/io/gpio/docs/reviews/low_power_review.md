# GPIO 低功耗专项核对

根据用户“本次运行不需要额外人工审核”及“先完成完整流程”的委托，由执行 Agent 核对数字低功耗合同和实际 VCS 结果，不冒称独立人类评审。

检查主域四种 sleep 模式、保持捕获与正常 OUT 更新、sleep 配置写保护、停主钟保持、safe 抢占、恢复及退出 sleep；以及 AON COMMIT、唤醒、暖复位保持、主域停钟独立运行、pending 清除、timeout 和迟到 ACK 排空。通过状态仅可来自当前构建的 tc_gpio_lowpower 与 tc_gpio_aon 真实日志。

主域掉电物理保持、隔离单元、电平转换、PAD 电气和 SoC UPF 由集成方按合同负责，数字专项不证明这些物理属性。CDC/RDC 许可证缺失独立披露，不以仿真替代 crossing 签核。
