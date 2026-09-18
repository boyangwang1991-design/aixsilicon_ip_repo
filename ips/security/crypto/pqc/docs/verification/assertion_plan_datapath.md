# PQC 数据通路集成断言

实现入口为 verification/assertions/pqc_datapath_sva.sv，按LLD hook绑定；未实现状态不能作为通过证据。

## ASSERT.PQC.DMA.002

<!-- ASSERTION_META
id: ASSERT.PQC.DMA.002
name: a_axi_hold
feature_ref:
- FL.PQC.DMA
property: AR/AW/W valid且未ready时地址/数据/属性/last保持；取消不撤销已展示请求
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发为对应有效请求/响应或安全事件；违反表示生命周期或隔离失效，立即报错并保留当拍身份。

## ASSERT.PQC.CMD.002

<!-- ASSERTION_META
id: ASSERT.PQC.CMD.002
name: a_result_retirement
feature_ref:
- FL.PQC.CMD
property: 所有payload写B成功、completion各字节已写且B成功之前不得发布成功DONE或IRQ；错误B永不退休为成功
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发为对应有效请求/响应或安全事件；违反表示生命周期或隔离失效，立即报错并保留当拍身份。

## ASSERT.PQC.INTEGRITY.002

<!-- ASSERTION_META
id: ASSERT.PQC.INTEGRITY.002
name: a_primitive_identity
feature_ref:
- FL.PQC.INTEGRITY
property: 只有与当前epoch/primitive/engine/allocation匹配的未决响应可推进；重复/旧epoch响应不写回或完成
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发为对应有效请求/响应或安全事件；违反表示生命周期或隔离失效，立即报错并保留当拍身份。

## ASSERT.PQC.KEY.002

<!-- ASSERTION_META
id: ASSERT.PQC.KEY.002
name: a_cancel_priority
feature_ref:
- FL.PQC.KEY
property: revoke/zeroize/fatal同拍关闭秘密读取/随机消费/结果发布；迟到KM ACK及SRAM响应不恢复有效性
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发为对应有效请求/响应或安全事件；违反表示生命周期或隔离失效，立即报错并保留当拍身份。

## ASSERT.PQC.KEYMANAGER.001

<!-- ASSERTION_META
id: ASSERT.PQC.KEYMANAGER.001
name: a_custody_before_keygen_done
feature_ref:
- FL.PQC.KEYMANAGER.PENDING
property: KeyGen成功必须已有本命令完整专用托管ACK；不得通过普通DMA导出已有私钥
severity: error
verification_method: assertion
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发为对应有效请求/响应或安全事件；违反表示生命周期或隔离失效，立即报错并保留当拍身份。

## ASSERT.PQC.CFG.001

<!-- ASSERTION_META
id: ASSERT.PQC.CFG.001
name: a_masked_secret_boundary
feature_ref:
- FL.PQC.CFG
property: Level2敏感路径及转换保持share与域身份；公共出口不能承载私钥/单share或未经批准中间秘密
severity: error
verification_method: formal
applicability:
  expr: 'true'
END_ASSERTION_META -->

触发为对应有效请求/响应或安全事件；违反表示生命周期或隔离失效，立即报错并保留当拍身份。

Level2还需按每个gadget及连接组合验证随机独立性与glitch假设，形式信息流检查不能代替物理侧信道评估。
