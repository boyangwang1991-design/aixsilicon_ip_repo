<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: register_check
status: pass
eda_profile: commercial-systemverilog
tool: vlogan
tool_version: W-2024.09-SP1
verification_scope: native_systemverilog_compile_and_provenance
command: vlogan -full64 -sverilog /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/rtl/generated/gpio_reg_desc_pkg.sv
  /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/rtl/generated/gpio_csr_pkg.sv
  /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/rtl/generated/gpio_csr.sv
  /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/rtl/generated/gpio_csr_adapter.sv
artifacts:
- path: regs/gpio.rdl
  sha256: 46bd1bab2da0f44f9bdff6c5bba6f4c7f7a93a9d09d7f6e6849cc3ea40571984
- path: rtl/generated/gpio_csr_pkg.sv
  sha256: 2f03ee84f808170fc92a4ce3ba4ae9c18b96a4a1b7b29b190e9d2e63c0335656
- path: rtl/generated/gpio_csr.sv
  sha256: 20a60ca882f8d77a0022b5098c85d47a27d03be0b180f3cbfa6b75155cd8a749
- path: rtl/generated/gpio_csr_adapter.sv
  sha256: b96118a36f888effa802eaca7aaf8cc610532f9c433592408d10724b08cc0936
- path: rtl/generated/gpio_csr.manifest.yaml
  sha256: e0cb7124194560bbfe175de31e12ee318664edf9dc361503063c67b78271f5bc
- path: reports/registers/csr_passthrough_compile.log
  sha256: a8dd7171c1b1210beb357ddf20eeb7fc8c6bd426c1353af25c01b174b2132958
END_REPORT_META -->
