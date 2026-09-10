# 断言和覆盖率

<!-- ASSERTION_META
id: ASSERT.SPI_MASTER.CS_ONEHOT.001
name: ap_cs_onehot
feature_ref:
- FL.SPI_MASTER.COMMANDS
property: 最多一个 CS 有效
severity: error
verification_method: assertion
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.SPI_MASTER.ZERO_WAIT.001
name: ap_zero_wait
feature_ref:
- FL.SPI_MASTER.APB
property: ACCESS 首周期 ready
severity: error
verification_method: assertion
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.SPI_MASTER.KNOWN_OUTPUTS.001
name: ap_known_outputs
feature_ref:
- FL.SPI_MASTER.RECOVERY
property: 控制输出无 X
severity: error
verification_method: assertion
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.SPI_MASTER.TX_BOUND.001
name: ap_tx_bound
feature_ref:
- FL.SPI_MASTER.FIFO_STALL
property: TX count 不超深度
severity: error
verification_method: assertion
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.SPI_MASTER.RX_BOUND.001
name: ap_rx_bound
feature_ref:
- FL.SPI_MASTER.FIFO_STALL
property: RX count 不超深度
severity: error
verification_method: assertion
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.SPI_MASTER.CMD_BOUND.001
name: ap_cmd_bound
feature_ref:
- FL.SPI_MASTER.COMMANDS
property: CMD count 不超深度
severity: error
verification_method: assertion
END_ASSERTION_META -->

<!-- COVERAGE_META
id: COV.SPI_MASTER.SERIAL_MODE_WIDTH_ORDER.001
name: serial_mode_width_order
type: functional
feature_ref:
- FL.SPI_MASTER.MODES
END_COVERAGE_META -->

<!-- COVERAGE_META
id: COV.SPI_MASTER.COMMAND_OPCODE_KEEP_STALL.001
name: command_opcode_keep_stall
type: functional
feature_ref:
- FL.SPI_MASTER.COMMANDS
END_COVERAGE_META -->

四模式 × 九位宽 × 两位序共 72 个 mandatory bins 应全部触达。代码覆盖率使用 URG 原始结果，空洞逐项评审；不得临时删除逻辑制造百分比。覆盖触达和功能正确性分开报告。

## 本次 G5 覆盖率标准调整

用户明确要求“放宽覆盖率的限制，如实记录，先完成G5”。据此将默认配置 DUT 原始、未排除的行覆盖率目标从暂定 95% 调整为 90%；实际 91.62%。功能覆盖 96/96 和六项必需断言真实成功率仍要求 100%，回归错误必须为零。FSM 转移 75%、branch/condition/toggle 空洞继续完整披露，不因本次放宽声明为不可达或已覆盖。此标准仅用于本次 IP 交付验收；后续更高覆盖率目标独立规划。
