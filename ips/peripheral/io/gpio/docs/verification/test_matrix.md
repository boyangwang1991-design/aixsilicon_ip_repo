# GPIO 测试矩阵

共15个唯一用例：14个UVM功能用例及1个工程static检查。域内参数/seed扫描共享oracle，避免重复用例。APB为smoke；完整回归仍执行全部用例。

| TC.GPIO.CONFIG.001 | 配置与裁剪 | UVM |
| TC.GPIO.APB.001 | APB事务与错误 | UVM |
| TC.GPIO.INPUT.001 | 输入有效性 | UVM |
| TC.GPIO.FILTER.001 | 滤波与去抖 | UVM |
| TC.GPIO.OUTPUT.001 | 输出原子更新 | UVM |
| TC.GPIO.IRQ.001 | 中断与方向事件 | UVM |
| TC.GPIO.SECURITY.001 | 锁与访问策略 | UVM |
| TC.GPIO.LOWPOWER.001 | 休眠和安全覆盖 | UVM |
| TC.GPIO.AON.001 | 常开唤醒与命令 | UVM |
| TC.GPIO.CAPTURE.001 | 快照与Strap | UVM |
| TC.GPIO.FIFO.001 | 事件队列与时间戳 | UVM |
| TC.GPIO.DIAG.001 | 物理回读诊断 | UVM |
| TC.GPIO.PARITY.001 | Parity与安全锁存 | UVM |
| TC.GPIO.RESET.001 | 复位矩阵 | UVM |
| TC.GPIO.DELIVERY.001 | 集成与工程签核 | static |
