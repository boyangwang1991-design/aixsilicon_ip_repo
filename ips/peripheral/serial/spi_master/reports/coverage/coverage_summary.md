# 覆盖率评审

<!-- REPORT_META
schema_version: '2.0'
ip_name: spi_master
report_type: coverage
status: pass
eda_profile: commercial-systemverilog
tool: summarize_acceptance.py
tool_version: '1.0'
command: python scripts/summarize_acceptance.py
artifacts:
- path: reports/coverage/raw/dashboard.txt
  sha256: 769e7cca83828d853747e07f01fb9ec5e7f002b280ead264ca05d62c6d726c04
- path: reports/coverage/raw/hierarchy.txt
  sha256: 6673a6302658fb161d5cb0a20348f2c0f14ce8bea73baeb13708aaa634a7be43
- path: reports/coverage/raw/groups.txt
  sha256: 1fea89a5579e74657b3e42a56904f4cd3e6617005af6dc032d18633d56bd4dc1
- path: reports/coverage/raw/asserts.txt
  sha256: eab0b386dffe8092e6eb59515c1f668a74d9e20cb79e6c632c076b796e3625c7
- path: reports/regression/regression_summary.md
  sha256: c14cd7b4c82095308c7576e5a04b4b4bddec5f3e0b0c0bffd8c721185cdbc095
coverage:
  functional:
    achieved: 100
    target: 100
    scope: 96 bins including 72 serial cross bins
  code:
    achieved: 91.62
    target: 90
    metric: line
    scope: default DUT, raw unexcluded; 90 percent target authorized by user; see
      coverage_plan.md
  assertion:
    achieved: 100
    target: 100
    scope: six mandatory IP assertions; all attempted with real successes
coverage_source:
  collector: VCS W-2024.09-SP1 + URG
  collection_command: python scripts/run_verification.py
  merge_command: VCS_USE_MALLOC=1 python scripts/run_coverage.py (same elaboration
    only)
  report: reports/coverage/raw/dashboard.txt
  report_sha256: 769e7cca83828d853747e07f01fb9ec5e7f002b280ead264ca05d62c6d726c04
exclusions: []
waivers: []
dependencies:
- path: reports/regression/regression_summary.md
  sha256: c14cd7b4c82095308c7576e5a04b4b4bddec5f3e0b0c0bffd8c721185cdbc095
END_REPORT_META -->

功能 bins 96/96，模式 × 位宽 × 位序交叉 72/72。六项 IP SVA 均有真实成功，全部断言失败数为 0。

| 默认配置模块 | Line | Branch | Condition | Toggle |
|---|---:|---:|---:|---:|
| spi_master_top | 100% | 96.43% | 85.71% | 30.47% |
| spi_master_engine | 100% | 97.14% | 90.07% | 36.73% |
| spi_master_queues | 100% | 100% | 74.07% | 75.80% |
| generated CSR | 90.17% | 84.82% | 68.75% | 28.08% |

原始默认 DUT 行覆盖 91.62%，最大配置 CSR 行覆盖 95.98%。没有排除生成代码或 UVM 来改写原始报告；表格只是明确指定观察范围。按用户“放宽覆盖率的限制，如实记录，先完成G5”指示，默认 DUT 原始行覆盖门槛由暂定 95% 调整为 90%，实测 91.62% 满足调整后门槛；功能及必需断言仍要求 100%。不宣称原 95% 门槛通过，FSM/branch/condition/toggle 保留原始结果作为已披露残余风险。

FSM 九个可达状态全部触达，自动识别转移 15/20（75%）。未触达 HOLD_TIME/NEW_IDLE/SETUP→IDLE 是复位边；这些状态的复位由独立 engine UT 已逐态检查，但 UT 覆盖库未混入集成覆盖库。SETUP→HOLD_CS/RESOURCE 是 case fall-through 分析带出的边，实际下一状态始终 SHIFT；需工具确认后才可作不可达豁免。

低 toggle 包含指令保留位、计数器高位、固定配置及 CSR 动态状态镜像。并非全部都不可达，例如 32 位等待计数长时间翻转未穷举，故保留空洞，不伪造豁免。CBB FULL/EMPTY 无操作性质前件在 IP 包装器处被拒绝，真实成功为零但无断言失败；库独立验证和本 IP 访问错误检查承担相应责任。UVM RAL 内部两项无 attempt 是当前显式 CSR oracle 架构的结果。

所有四种参数的原始 HTML/text 都保留在各自目录；未将不同 elaboration 的层次强行合并。
