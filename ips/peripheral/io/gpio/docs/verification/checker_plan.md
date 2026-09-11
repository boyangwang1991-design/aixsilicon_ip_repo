# GPIO 检查器与参考模型

APB monitor只发布Access完成事务，PAD monitor按每个域独立时钟发布沿前输入和输出。RM不读取DUT内部状态，不调用DUT函数；以样本时间序列、位集合和软件事件队列表达输入/中断/FIFO/AON规则。Checker在NBA后比较预计当前状态和输出；总线读取则比较沿前快照。

白盒SVA仅检查实现不变量；SEQ/LOST回绕等不可经济等待边界允许用单元测试backdoor设置初值，随后通过正常接口比较结果，并记录注入事件，不能屏蔽功能checker。

<!-- ASSERTION_META
id: ASSERT.GPIO.ERROR_ATOMIC.001
name: ERROR_ATOMIC
feature_ref:
- FL.GPIO.APB
property: 非法APB事务不得更新业务状态，允许错误诊断状态更新
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.GPIO.OE_GUARD.001
name: OE_GUARD
feature_ref:
- FL.GPIO.OUTPUT
property: 所有周期OE不得越过OUTPUT_CAP_MASK和output_owned_i
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.GPIO.OPEN_DRAIN.001
name: OPEN_DRAIN
feature_ref:
- FL.GPIO.OUTPUT
property: 正常开漏模式不会以OE=1主动驱动高
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.GPIO.SET_WINS.001
name: SET_WINS
feature_ref:
- FL.GPIO.IRQ
property: W1C与新事件同拍Pending仍置位
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.GPIO.LOCK_MONOTONIC.001
name: LOCK_MONOTONIC
feature_ref:
- FL.GPIO.SECURITY
property: 无POR时锁位不得由1变0
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.GPIO.PAYLOAD_STABLE.001
name: PAYLOAD_STABLE
feature_ref:
- FL.GPIO.AON
property: 从request发送到匹配ack期间载荷稳定，暖复位不破坏
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.GPIO.CAPACITY.001
name: CAPACITY
feature_ref:
- FL.GPIO.FIFO
property: FIFO占用始终在0..DEPTH，空读HEAD为0
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

<!-- ASSERTION_META
id: ASSERT.GPIO.FIRST_VALID.001
name: FIRST_VALID
feature_ref:
- FL.GPIO.INPUT
property: 首次输入有效或重建基线不会产生边沿event
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

