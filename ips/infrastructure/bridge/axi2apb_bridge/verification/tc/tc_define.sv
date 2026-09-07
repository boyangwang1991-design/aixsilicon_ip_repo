// =============================================================================
// tc_define.sv - X2P 测试选择宏
// 运行: +UVM_TESTNAME=tc_sanity 等
// =============================================================================

`ifndef TC_DEFINE__SV
`define TC_DEFINE__SV

  `define TEST_SANITY  "tc_sanity"
  `define TEST_BURST   "tc_burst"
  `define TEST_TIMEOUT "tc_timeout"

`endif
