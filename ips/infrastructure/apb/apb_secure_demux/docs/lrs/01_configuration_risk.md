# 非2幂地址容量验证夹具

192 字节端口区检验无须 2 幂大小的范围译码；每个端口仍按完整范围计算末地址。

<!-- PARAM_CASE_META
id: CFG_NONPOWER_PORT_SIZE
layer: risk
values:
  PORT_SIZE:
  - 192
  - 192
  - 192
  - 192
  - 192
  - 192
  - 192
  - 192
verify:
  elab: true
  lint: true
  formal: true
  sim: true
  synth: false
END_PARAM_CASE_META -->

集成地址字段的通用采样仅使用明确的验证地址；项目校验器检查完整 ADDR_WIDTH 边界、重叠及必填性。CSR_BASE 的 inline schema 同样由项目校验器执行。
