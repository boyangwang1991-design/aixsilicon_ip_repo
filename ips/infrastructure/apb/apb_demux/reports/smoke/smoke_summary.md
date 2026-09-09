<!-- REPORT_META
schema_version: "2.0"
ip_name: apb_demux
report_type: smoke
status: pass
tool: vcs
tool_version: "W-2024.09-SP1"
command: "make -C verification/sim smoke"
artifacts:
  - path: build/sim/run/smoke_sanity.log
    sha256: "<generated>"
  - path: build/sim/run/smoke_miss.log
    sha256: "<generated>"
eda_profile: commercial-systemverilog
END_REPORT_META -->

# UVM Smoke 摘要 - APB Demux

## 1. Smoke 结果

| Testcase | tier | 结果 | 说明 |
|----------|------|------|------|
| tc_sanity | smoke | ✅ PASS | 32 up / 32 down matched, mismatch=0 |
| tc_decode_miss | smoke | ✅ PASS | Decode Miss 返回 PSLVERR=1, PRDATA=0 |

## 2. 执行证据

- 编译：VCS 编译通过（APB VIP 只读复用自 aixsilicon_vip_repo）；
- 运行：`+UVM_TESTNAME=tc_sanity/tc_decode_miss +UVM_SEED=1`；
- 结果：0 UVM_ERROR, 0 UVM_FATAL。

## 3. 结论

Smoke **pass**。UVM 环境构建与主路径（读写路由 + Decode Miss）验证就绪。
