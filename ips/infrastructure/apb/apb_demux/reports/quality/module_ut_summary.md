<!-- REPORT_META
schema_version: '2.0'
ip_name: apb_demux
report_type: module_ut
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: W-2024.09-SP1
command: bash verification/unit_test/run_ut.sh
test_count: 1
artifacts:
- path: reports/ut/ut_compile.log
  sha256: 48ff4d86136a25477a642d26f60818d1b1716098181a665ffe58352dffb5016b
- path: reports/ut/ut_run.log
  sha256: 11e30d42f63570a53dee41acc7625e0a491a62f62f0146f511882583d83168b5
- path: verification/unit_test/ut_apb_demux.sv
  sha256: f78db32b7da3f4076cd6ec1a4d9db805b144317c578c36560540af6d13606101
checks:
  ut_apb_demux:
    status: pass
    compile_log: reports/ut/ut_compile.log
    run_log: reports/ut/ut_run.log
END_REPORT_META -->

# Module UT 摘要 - APB Demux

## 1. 测试范围

| TC | 验证点 | 结果 |
|----|--------|------|
| TC1 | 端口 0 命中 / onehot0 / PREADY 透传 | ✅ PASS |
| TC2 | Decode Miss 无 PSEL + PSLVERR=1 + PREADY=1 | ✅ PASS |
| TC3 | 端口 2 命中 + PSLVERR 透传 | ✅ PASS |
| TC4 | 复位期间无有效事务 | ✅ PASS |

## 2. 执行证据

- 编译：VCS 编译通过；
- 运行：`UT_apb_demux: PASS (errors=0)`。

## 3. 结论

Module UT **pass**（G3 固定步骤）。
