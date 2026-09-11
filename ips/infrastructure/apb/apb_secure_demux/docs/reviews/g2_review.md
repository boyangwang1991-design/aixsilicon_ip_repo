# LLD / Register Behavior Freeze 评审包

G1已由用户“approve, complete the rest”批准；授权继续执行剩余工作持续有效。此评审只针对批准之后新形成的微架构/字段行为，不重复请求一般执行授权，也不把本次请求写成G2机器检查已通过。

## 本次具体评审范围

1. FRONTEND/ROUTE共享一份事务状态，direct零额外等待、register一拍额外等待，LOCAL首ACCESS完成；无取消、无posted write。
2. POLICY单写owner，提交/重载先全量检查后同沿更新；完整性全表组合检查、下一边沿锁存FATAL；在途继续完成。
3. CSR采用原生PeakRDL APB4外部字段接口，SETUP采样，ACCESS组合ack；动态授权撤销与最终命令接受分开；COMMIT_STATUS使用独立commit_attempt与诊断优先级。
4. 日志clear→pop→push；FIRST/LAST分别快照；读0与新事件同沿取沿前可见记录。空FIFO的POP写包括写零均返回命令错误，非空写零不弹出，沿用CR-002的空队列错误约束。
5. DFX授权撤销优先清未触发武装；自然拒绝不消耗；完整性注入在SETUP产生TEST完整性事件、后续完成再记录拒绝；真实完整性位置优先于同时的合成位置。
6. 122项字段行为、19个接口与实例CSR生成配置绑定。原生exporter是否满足具体结构参数和零额外CSR等待须用02阶段真实生成/仿真检查确认。

## 可审阅产物

- ../lld/index.md：完整微架构分册，含复位、状态机、位宽、队列竞争、时序、字段行为、映射与生成接口要求。
- ../../reports/quality/lld/design_audit.json：9个HLD模块一对一承接、169需求覆盖、字段必需项与引用/分册检查；不代表语义签核。
- ../../reports/quality/lld/review_identity.json：本次评审输入哈希。
- ../../reports/quality/gate_report.md：实际G2未通过，缺寄存器生成报告及原生CSR来源证据；G3–G5阻塞。

## 两步门禁及残余项

05/02要求先冻结字段行为才正式生成，G2 evaluator又要求原生CSR及register_check证据。先评审冻结本版LLD/字段行为，随后执行02生成、编译与寄存器检查，再判定G2，不能把前一步批准直接写成完整G2 pass。这一流程表达冲突已记录为ASD-SK-018。

此评审不豁免受控APB规范核验、实际集成/工艺输入、VIP资格差异、真实RTL/UVM/形式/综合/覆盖率与发布检查。当前不具备可集成RTL或发布包。
