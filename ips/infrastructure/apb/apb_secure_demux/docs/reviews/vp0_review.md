# VP0 验证计划评审包

当前G0/G1/G2已通过，LLD/寄存器行为批准原文为“approve and proceed all process”。本次新增验证方案尚未代填技术冻结，已有全流程执行授权持续有效。

## 具体评审对象

1. 16个feature将全部169条需求分组承接；20个testcase含4个smoke入口、定向/随机/边界/故障/寄存器测试及3个静态证据入口。
2. UVM1.2独立RM接收请求、响应、时钟及可信故障描述，不以DUT策略读回作oracle。监控SETUP以证明拒绝无目标副作用，日志/快照/队列/统计逐字段比对。
3. 12条性质覆盖onehot0、无副作用、等待稳定、本地延迟、未授权状态保持、锁单调、原子提交、事件唯一、屏蔽独立、FATAL、DFX无旁路和复位。四项契约必需安全性质需形式或可审计穷尽证明，不以随机仿真替代。
4. 16组强制覆盖义务须全部命中或逐项评审豁免；代码各类覆盖分别报告，未覆盖项逐项分析。没有预先批准的waiver。
5. 8命名配置、75支持点/11负例、非零启动权限夹具；各配置分别构建及保留覆盖库。默认种子1/17/101，扩展随机1001..1010。
6. SYSTEM/PPA/DELIVERY使用真实静态checker和owner材料；受控APB规范、系统路径保护、可信来源及PDK/SDC缺失不得输出PASS。APB VIP以实际候选core预集成，G4/G5 PARTIAL资格仍保留。

## 可核查材料

- ../verification/index.md：六类内容卷、分册和VP0。
- ../../reports/quality/vplan/plan_audit.json：16 feature、20 testcase、12 assertion、16 coverage对象及169需求覆盖，引用与布局无错误。
- ../../reports/quality/vplan/review_identity.json：本次计划和上游输入哈希。
- ../../reports/quality/trace_matrix.md：169条REQ→HLD、9条HLD→LLD、411条REQ→Test/Assertion链接；9个LLD→功能RTL缺口保留待实现。

本次只请求批准上述验证策略/覆盖义务，不代表20个用例已实现或执行。批准后继续功能RTL、Module UT、FuseSoC/EDA、UVM回归、覆盖、PPA与交付；所有后续门禁仍依赖实际检查结果。
