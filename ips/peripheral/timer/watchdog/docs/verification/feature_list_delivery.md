# 软件集成与实现签核：验证意图

<!-- FEATURE_META
id: FL.WATCHDOG.DELIVERY
name: 软件集成与实现签核
description: 软件集成与实现签核的可执行正确性证明
priority: must
req_ref:
- LRS.DFX.WATCHDOG.TST.005
- LRS.CONS.WATCHDOG.NFR.001
- LRS.CONS.WATCHDOG.NFR.005
- LRS.CONS.WATCHDOG.NFR.006
- LRS.CONS.WATCHDOG.VER.006
- LRS.CONS.WATCHDOG.DELIVERY.001
- LRS.CONS.WATCHDOG.SOFTWARE.001
design_ref:
- LLD.MOD.WATCHDOG.INTEGRATION
applicability:
  expr: 'true'
proof_methods:
- static
- simulation
END_FEATURE_META -->

编译并执行C驱动mock总线错误/序号/互斥测试；比对RDL派生视图；SpyGlass lint/CDC/RDC；28nm三档DC/PPA和冗余网表检查；逐项交付链接检查。

独立判据：软件超时不盲重发且只接收匹配DONE_SEQ；派生一致；静态零未处置错误/锁存/环；真实库映射及时序报告；安全说明列明未覆盖项且无无据认证。

风险与边界：三个产品档×交付视图；所有静态/软件子检查必须分别有命令与原始结果。

### LRS.DFX.WATCHDOG.TST.005

交付安全说明应列出故障模型、检测路径、最大检测延迟、未覆盖故障、时钟/电源/复位共因、周期测试建议及系统假设。不得在没有分析和验证证据时标注 ASIL 达成或固定诊断覆盖百分比。

验收：安全说明逐项覆盖故障模型、检测路径/延迟、盲区、共因和周期测试，不虚构 ASIL 或诊断比例。

### LRS.CONS.WATCHDOG.NFR.001

IP 应兼容声明的同步时钟及复位集成方式，可综合且不得产生非预期锁存或未声明的新时钟；具体时钟使能和复位电路由 HLD/LLD 定义。

验收：综合/静态检查无非预期锁存和组合生成时钟；时钟/复位使用范围可审查。

### LRS.CONS.WATCHDOG.NFR.005

PPA 无通用工艺无关数值门限。交付应报告 STANDARD单通道、SAFETY单通道、SUPERVISOR代表配置的面积/时序/功耗条件，包含工艺、库、时钟、活动假设及冗余开销；不虚构频率或门数达标。

验收：三个产品配置分别有真实库/工艺/时钟/活动假设及面积时序功耗原报告；无资料则不得签核。

### LRS.CONS.WATCHDOG.NFR.006

RTL、寄存器头文件、驱动常量、验证RAL和能力元数据必须使用同一配置定义生成/核对，防止模式、位宽与寄存器地图不一致。无需强制使用某一种RTL生成语言。

验收：RTL/CSR 头/驱动/RAL/能力对同一参数定义检查一致，不允许地址、宽度或模式漂移。

### LRS.CONS.WATCHDOG.VER.006

对每种配置档必须建立需求→feature→test/checker/assertion→coverage追踪。功能覆盖需包含边界和关键交叉，不能仅用代码覆盖率替代。安全机制另外提供故障注入结果和未覆盖项说明。

验收：每个配置适用需求有 feature/test/checker/assertion/coverage 追踪；单列故障注入与未覆盖项。

### LRS.CONS.WATCHDOG.DELIVERY.001

应交付规范 LRS、HLD、LLD、SystemRDL 及派生视图、参数化 RTL、软件驱动、完整验证环境/RAL/参考模型/断言/覆盖率、约束、安全说明、用户及集成手册、验证报告和 FuseSoC 入口。交付追踪必须区分计划、实现、实测、冻结和发布状态。

验收：全流程交付映射表中每项均有真实文件、内容与对应证据；不使用目录存在或短摘要替代。

### LRS.CONS.WATCHDOG.SOFTWARE.001

驱动应按原契约 §17 实现初始化、服务、故障读取和恢复协作：命令逐笔核对序号/结果、服务超时不盲目重发、选择器和邮箱互斥、锁与解锁额度对应。喂狗应基于真实任务健康条件。

验收：可执行示例覆盖服务成功、过早、超时、局部恢复、最终升级和暖复位留痕。；中断清除不刷新或撤销活动故障，重启先读首次诊断。
