# Watchdog PPA 专报

真实28nm库可用，但本轮综合未完成有效映射，尚未建立合格PPA测量点。

## 范围和工艺条件

本报告只记录本轮真实综合尝试及缺口，不声明E1/E2/E3表征完成。
PDK保持PDK_READY：GF CMOS28LP、ARM SC9 HVT，tt_nominal_max_1p00v_25c，
1.00 V、25°C，Design Compiler V-2023.12-SP3。库选择来自model/pdk.yaml，
实际库文件已核对存在及SHA-256；未改为E0，也未换用通用单元估算。

constraints/watchdog.sdc指定pclk 100 MHz、wdt_clk 50 MHz，uncertainty/transition
0.1 ns，APB/WDT I/O max delay分别1/2 ns，输出负载0.01使用库单位。
这些是表征约束，不是额定Fmax。没有SAIF标注，未来成功报告也必须说明默认活动估计。

## 实际尝试

| 尝试 | 结果 | 对结论的影响 |
|---|---|---|
| compile_ultra，20260914T083556079972 | OPT-1603 虚拟内存不足，中止 | 没有可用综合网表和完整指标 |
| 串行compile_ultra，20260914T084927285403 | 再次OPT-1603 | 不能仅归因于并行运行 |
| classic compile，20260914T085940523110 | 进入映射后达到1800秒超时 | 仍没有合格测量点；残留子进程已终止 |

运行入口随后补充了子进程超时清理。上述日志保留为原始尝试，不用后改入口给旧运行补签。
映射过程显示大量size-only单元，限制了优化；其原因须结合安全冗余保留策略分析，
不能为了完成综合而整体移除保护约束。

## 产品配置与缺口

| 配置 | 当前PPA依据 |
|---|---|
| STANDARD | 默认规模综合尝试失败；没有面积、有效时序或功耗数值 |
| SAFETY | 尚无独立合格表征，不能由STANDARD推导 |
| SUPERVISOR | 尚无独立合格表征，不能由小规模外推 |

没有合格点，故不绘制虚构Pareto图，不推荐配置，也不将目标周期换算为测得Fmax。
后续需先闭合功能验证，解决综合资源/约束问题，再按三个产品配置执行真实扫描，
分别绑定源码、参数、库/角、SDC、工具、活动与原始area/timing/power报告。
安全配置另需映射冗余保留与故障响应审查；RTL属性本身不能作为物理独立性证明。

## 复现和追踪

设置UV_PROJECT为workflow根，在IP目录运行：

```bash
uv run --no-sync python scripts/run_rtl_checks.py synth
uv run --no-sync python scripts/run_rtl_checks.py synth --synth-mode classic
```

以上为默认规模检查入口；完整三产品PPA扫描尚未完成。机器结果在build/reports/rtl和
build/rtl，需本地重新生成；GitHub只保留本专题结论。整体门禁及WDT-SYNTH-001处置见
[统一报告](../report.md)。

<!-- IP_REPORT_METADATA
schema_version: '1.0'
report_type: ppa
ip_name: watchdog
status: fail
conclusion: 真实28nm库可用，但本轮综合未完成有效映射，尚未建立合格PPA测量点。
evidence_level: not_established
results: []
evidence:
- path: build/reports/ppa/attempt_context.json
  sha256: 0ade2ae4ffd9e65842814044f3eb61018299eed8d1b56d7f8d85843c2729d107
- path: build/reports/rtl/20260914T083556079972/execution.json
  sha256: 5cd1a41c4861610992d2ba9208393f9bd8f6c825279630bff3a61669683945eb
- path: build/reports/rtl/20260914T084927285403/execution.json
  sha256: 095266f67a04fc5064e02bc4aa2e96ee4e93edcb196ede38bbbd1348f8b98eac
- path: build/reports/rtl/20260914T085940523110/execution.json
  sha256: 17d48c1327aec361e93ac0a2997a87bc3af24df73e3e26cf237a5b1ec1cc2208
END_IP_REPORT_METADATA -->
