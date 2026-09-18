# PQC 验证方案 VP0 计划门禁

<!-- VPLAN_GATE_META
gate: VP0
status: open
approvals:
  architecture: pending
  rtl: pending
  verification: pending
END_VPLAN_GATE_META -->

## 评审范围

本次将原“软件证明算法、UVM只测控制面”更正为真实RTL完整计算与冻结KAT比较。
六类内容卷按接口/算法/安全分册；同一目录只有一个VPLAN_META与本VP0对象。
需求基线为84条，20个参数化testcase，运行时不依赖Python/C算法。
具体统计以本轮extractor及trace结果为准，执行结论仅见reports/report.md。

## 必须审查的输入

| 范围 | 检查 | 剩余义务 |
|---|---|---|
| 需求/设计引用 | TC→FL→LRS与设计ID、源hash | owning extractor与static trace precheck |
| 正常算法 | 18参数/操作组合、KeyGen托管、字节oracle | 标准向量manifest尚需落地与审查 |
| 负向与安全 | 编码/长度/拒绝、异常/取消、Level2全链 | LLD完整token/页生命周期/gadget/预算尚未技术冻结 |
| 环境 | UVM1.2、APB/AXI/KM/entropy、监视与计数 | VIP为developing；托管接口及平台实现未齐 |
| 参数/覆盖 | 9参数、真实配置ID、原覆盖门限 | 边界实例需19-PC；实际coverage未执行 |
| 证据 | smoke/full JUnit、失败关闭、构建/输入绑定 | 尚未执行本版完整UVM回归 |

已有委托授权见docs/reviews/delegated_design_decisions.md；允许检查后记录委托评审，
无需重新申请相同设计决策。这里保持open是技术输入未闭合，不是缺少重复授权。
计划结构检查成功只说明可抽取和引用关系；不代表G2技术冻结、G3 RTL Ready、
G4 Verification Ready或任何物理侧信道证明通过。
