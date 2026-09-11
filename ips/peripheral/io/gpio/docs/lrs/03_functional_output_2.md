# GPIO LRS：输出控制（2）

本册来源为原始 contract 中各条 source_ref；术语与同一源 ID 的上下文共同解释。

### LRS.FUNC.GPIO.OUT006.002

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT006.002
category: FUNC
feature: out006
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-006
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-006 定义的场景下，OUT_DATA 在开漏释放与拉低之间切换属于正常允许操作。

#### Acceptance Criteria

- OUT_DATA 在开漏释放与拉低之间切换属于正常允许操作。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

### LRS.FUNC.GPIO.OUT007.001

<!-- LRS_META
id: LRS.FUNC.GPIO.OUT007.001
category: FUNC
feature: out007
priority: P0
status: active
source_ref:
- gpio_contract.md#GPIO-OUT-007
applicability:
  expr: 'true'
verification_method:
- simulation
END_LRS_META -->

#### Requirement

在 GPIO-OUT-007 定义的场景下，OUT/OE 应在一次 APB 完成边沿更新，数字输出响应不增加隐藏时钟周期。该周期承诺不包含工艺传播、PAD、Pinmux 切换或外部 RC 延迟。

#### Acceptance Criteria

- OUT/OE 在一次 APB 完成边沿更新，数字输出响不增加隐藏时钟周期。该周期承诺不包含工艺传播、PAD、Pinmux 切换或外部 RC 延迟。
- 比较写前/写后 OUT/OE、引脚物理 OUT/OE 与能力/拥有权，覆盖推挽、开漏、反相和错误写。

