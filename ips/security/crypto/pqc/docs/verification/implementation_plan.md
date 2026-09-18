# PQC UVM 算法验证落地顺序

## 推荐路线

采用 UVM 1.2 + 真实 `pqc_top` + 冻结 KAT，运行时没有 Python/C/DPI 算法。
UVM sequence 提供输入，RTL 执行所有密码计算，monitor 提取实际输出，SystemVerilog
scoreboard 逐字节对比 KAT。离线向量准备可使用工具，但软件测试结果不作为 RTL 证据。
不建议先在 SV 重写整套 ML-KEM/ML-DSA reference model：投入大、同源错误风险高，
应优先把精力用于硬件调度和接口完整性。未来扩大随机输入时再评估独立 oracle 扩展，
不改变本次固定向量运行时无软件算法的基线。

## 阶段与退出条件

| 顺序 | 工作 | 退出条件 |
|---|---|---|
| 1 输入闭合 | 核对84需求、接口/LLD、六类VPLAN、配置/向量来源；做真实委托评审 | G2技术内容及VP0满足；ID/来源hash闭合，不能只靠结构PASS |
| 2 向量资产 | 六参数18操作、确定随机输入、negative vectors、manifest/loader | 每操作至少3组正常向量，长度/来源/hash检查，缺数据失败 |
| 3 真实数据链 | 描述符→payload DMA→SRAM/Key RAM→原语调度→staging→输出→completion | 无关键常量tie-off；UT逐步检查，真实write response决定退休 |
| 4 UVM平台 | APB/RAL、AXI memory、KM/entropy/sideband、独立monitor与scoreboard | 两阶段VCS检查，checker负向fixture能抓错；所有分析连接有效 |
| 5 单链bring-up | 先KEM-512 Encaps/Decaps，再KeyGen/托管，接着DSA-44 Verify/Sign/KeyGen | 每次一条真实链与KAT全部字节相符；任何错误不能仅改expected |
| 6 六参数扩展 | KEM768/1024、DSA65/87；接口/编码/消息/拒绝/取消负向 | 18正常操作及21测试的可达义务真实执行，全部compare counters满足 |
| 7 安全与配置 | Level2完整链、三命名档位、额外边界实例、formal/static | 功能等价、权限/生命周期与组合证明分别闭合，未证明项保留 |
| 8 验收 | smoke/full JUnit→19-PV→覆盖→closure RTM→质量 | 达原覆盖门限、全部需求关联实际证据；G4通过，G5另需交付检查 |

算法逐步bring-up只是调试顺序，不降低最终六参数、KeyGen托管或Level2范围。
UVM平台准备可与不依赖它的向量审查协调进行；正式回归必须使用已核验的实现和构建身份。
不承诺未经实现评估的工期，优先以每阶段退出条件衡量进度。

## 当前必须先处理的工程缺口

2026-09-17集成前检查RTL：`u_dma.xfer_req`、`u_keccak.start/in_valid`、`u_codec.start`
接常量；`u_work_key_ram.read_req`为0；KEM比较/候选秘密输入为0；DSA参考挑战写
使能为0。这些是功能缺失，不能靠UVM stimulus绕过。
当前顶层KM只提供导入/撤销，缺少新私钥托管与完整可信身份；该接口须按HLD/LLD补齐。
现有寄存器checker跳过动态寄存器及key-slot窗口的做法也不能作为新计划验收策略。

LLD仍有完整原语token响应、页面生命周期、秘密A2B/B2A/采样、固定尝试预算等
未完成内容；先闭合它们。已有“后续按推荐决策”的委托无需再索取，但检查没有通过
不能伪造技术冻结。完整系统暂不能宣称可验收。

## 交付与完成定义

交付代码位于RTL、verification与复现脚本；本VPLAN及canonical模型/trace随源码。
原始工具日志、向量展开缓存、manifest、JUnit、VDB、阶段机器报告只留build。
成功必须是实际总线输出正确、负向/安全行为正确且证据齐备；增加测试文件、获得
软件PASS、观察到DONE、UT通过或代码覆盖增加，均不能单独称“完整PQC算法验证通过”。

本轮已增加Encaps调度与真实输入/输出/completion DMA，以及TC.PQC.ENCAPS.MAIN.001；其实际执行状态见reports/report.md。其余完整算法缺口保持开放。
