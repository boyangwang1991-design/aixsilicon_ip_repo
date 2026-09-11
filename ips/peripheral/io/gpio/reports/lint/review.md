# GPIO lint 分类记录

原始未豁免结果：build/rtl/lint_fix1/，SpyGlass X-2025.06，0错误、4067告警。
首次 parity 关闭时产生的隐式锁存已通过静态 generate 分支修复，未豁免锁存规则。

| 规则 | 数量 | 分类及理由 |
|---|---:|---|
| W240 | 3271 | 生成 CSR/adapter 最大结构中的未用总线字段；共享 status 的未消费字段及 parity 关闭时的接口保留。按文件限定 |
| W415a | 775 | 同一过程先设默认值、再赋具体字段或 OR 累积，不是多个过程驱动。按现有模块限定 |
| STARC05-2.2.3.3 | 12 | 默认复位后覆盖参数值及事件置位优先于清除的 NBA 顺序；capture/mailbox UT 已检查相应竞争 |
| W528 | 7 | PeakRDL 可选访问检查恒定标志、顶层共享结构保留字段和原生 CSR ready/error；业务 APB wrapper 负责错误策略，读路径 UT 须检查原生 ready |
| STARC05-2.11.3.1 | 1 | mailbox 一段式 FSM 符合 LLD；独立时钟 UT 覆盖恢复与超时 |
| STARC05-1.3.1.3 | 1 | 已同步 main reset 作为 POR transport 的 accept 限制，防止暖复位期间接受新事务。此处仅编码风格豁免，CDC/RDC 仍须独立检查 |

限定规则写于 constraints/lint_waivers.tcl。原始告警报告保留，不以豁免后的零告警替代
CDC/RDC、综合、功能验证。新增不同文件或规则的告警仍会出现。
