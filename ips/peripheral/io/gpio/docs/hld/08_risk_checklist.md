# GPIO 架构风险与 G1

<!-- HLD_GATE_META
gate: G1
status: pass
architecture_freeze: true
approvals:
  basis: 'user approval: approve, complete the rest'
  mode: user_approved_current_HLD
END_HLD_GATE_META -->


| 风险 | 决策/关闭条件 | 当前状态 |
|---|---|---|
| 暖复位打断AON导致重复命令 | POR保持传输槽，LLD及CDC/RDC逐阶段证明恢复 | 架构方案已写，待评审及后续验证 |
| FIFO复用语义差异 | 已实现sync_fifo没有FLUSH且满+POP不接收PUSH，当前不能直接复用 | 已记录语义gap，选择GPIO专用事件队列，已获G1批准 |
| APB HWIF profile | CSR profile禁PPROT，base仅列ADDR_W=32；通过32位验证接口到14位IP地址的显式零扩展适配 | 禁止声称已有原生14位profile |
| 寄存器生成访问延迟 | 生成配置/适配需保持PREADY=1且读沿前状态 | LLD/02入口检查义务 |
| 输入重配置语义 | PIN_CFG有效字节覆盖与字段值变化需逐行为区分 | 在LLD周期表冻结并由测试覆盖 |
| 目标库/时钟/PAD假设缺失 | 产品逻辑预算先确定，实例物理值由集成方提供 | 阻止PPA/物理签核，不虚构数值 |
| 工具与依赖成熟度 | Formal未定位，APB VIP developing，GPIO VIP planned | 阻止相关正式验证签核，不能标为已验证依赖 |

用户已批准当前HLD并要求完成剩余流程；后续技术审批按该授权在校验后记录，不伪造独立评审。
