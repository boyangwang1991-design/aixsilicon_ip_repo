# 原子更新与不可逆锁

<!-- FEATURE_META
id: FL.APB_SECURE_DEMUX.UPDATE
name: 原子更新与不可逆锁
description: 原子更新与不可逆锁
priority: must
req_ref:
- LRS.REG.APB_SECURE_DEMUX.UPD.001
- LRS.REG.APB_SECURE_DEMUX.UPD.002
- LRS.REG.APB_SECURE_DEMUX.UPD.003
- LRS.REG.APB_SECURE_DEMUX.UPD.004
- LRS.REG.APB_SECURE_DEMUX.UPD.00501
- LRS.REG.APB_SECURE_DEMUX.UPD.00502
- LRS.REG.APB_SECURE_DEMUX.UPD.00601
- LRS.REG.APB_SECURE_DEMUX.UPD.00602
- LRS.REG.APB_SECURE_DEMUX.UPD.00701
- LRS.REG.APB_SECURE_DEMUX.UPD.00702
- LRS.REG.APB_SECURE_DEMUX.UPD.008
- LRS.REG.APB_SECURE_DEMUX.UPD.00901
- LRS.REG.APB_SECURE_DEMUX.UPD.00902
- LRS.REG.APB_SECURE_DEMUX.UPD.010
- LRS.REG.APB_SECURE_DEMUX.UPD.011
- LRS.REG.APB_SECURE_DEMUX.COMMITSTATUS.007
- LRS.DFX.APB_SECURE_DEMUX.REVOKE.011
design_ref:
- LLD.MOD.APB_SECURE_DEMUX.POLICY
- LLD.MOD.APB_SECURE_DEMUX.DFX
proof_methods:
- simulation
- assertion
END_FEATURE_META -->

## 逐需求验收范围

- `LRS.REG.APB_SECURE_DEMUX.UPD.001`：shadow 可单独读写；正常访问仅使用 active；禁止 shadow 更新直接作用于下游判权。
- `LRS.REG.APB_SECURE_DEMUX.UPD.002`：COMMIT_MASK 指定端口的 CFG_SHADOW 和全部 PERM_SHADOW 在同一完成边沿复制至 active，任何失败全部不提交。
- `LRS.REG.APB_SECURE_DEMUX.UPD.003`：非零合法掩码、无相关锁且无完整性故障时提交成功；即使值未变化也增加 POLICY_VERSION。
- `LRS.REG.APB_SECURE_DEMUX.UPD.004`：提交为本地单周期 ACCESS，不等待“上游 PSEL 降低”；持续背靠背访问也必须正常提交。
- `LRS.REG.APB_SECURE_DEMUX.UPD.00501`：由于仅一个 APB 输入且无后台请求队列，处理 COMMIT 时不得有尚未完成的下游事务。
- `LRS.REG.APB_SECURE_DEMUX.UPD.00502`：实现若引入队列必须维持此串行契约。
- `LRS.REG.APB_SECURE_DEMUX.UPD.00601`：COMMIT 完成边沿之后的 SETUP 使用新版本；此前外设事务已完成，不发生跨版本事务。
- `LRS.REG.APB_SECURE_DEMUX.UPD.00602`：上游桥内部尚未送入本 IP 的排队请求适用到达本 IP 时的策略。
- `LRS.REG.APB_SECURE_DEMUX.UPD.00701`：锁对 shadow 写、active 提交和 SHADOW_RELOAD 均生效；写锁只设锁，不隐式提交。
- `LRS.REG.APB_SECURE_DEMUX.UPD.00702`：软件必须先提交、读回，再设锁。
- `LRS.REG.APB_SECURE_DEMUX.UPD.008`：GLOBAL_LOCK=1 后不得修改任何权限/端口配置或执行 reload/commit；PORT_LOCK 的额外置位仍允许，属于收紧保护。
- `LRS.REG.APB_SECURE_DEMUX.UPD.00901`：锁写 0 无效果，读回保留；只有 preset_ni 解除锁。
- `LRS.REG.APB_SECURE_DEMUX.UPD.00902`：无软件解锁口令或软复位绕过。
- `LRS.REG.APB_SECURE_DEMUX.UPD.010`：策略锁不阻止日志读取清除、中断处理和授权 DFX 诊断；完整性故障锁存只能可信模块复位恢复。
- `LRS.REG.APB_SECURE_DEMUX.UPD.011`：版本仅为诊断关联号，32 bit 自然回绕；不用于授权、不作为跨复位唯一编号。
- `LRS.REG.APB_SECURE_DEMUX.COMMITSTATUS.007`：通过管理与基本 CSR 检查后，提交状态分别记录最近成功或失败；失败原因按掩码、全局锁、端口锁、完整性排序，多个端口选择最低编号；基本检查失败不得改变提交状态。
- `LRS.DFX.APB_SECURE_DEMUX.REVOKE.011`：注入匹配、武装消耗和事务 TEST 标记在 SETUP 结束边沿确定；该边沿硬件授权低时不得触发，已触发拒绝不因随后撤销而改变。授权撤销优先于同周期武装命令并返回 CFG_UNAUTHORIZED。
