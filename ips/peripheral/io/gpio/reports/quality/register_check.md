<!-- REPORT_META
schema_version: '2.0'
ip_name: gpio
report_type: register_check
status: pass
eda_profile: commercial-systemverilog
tool: vlogan
tool_version: W-2024.09-SP1
verification_scope: native_systemverilog_compile_and_provenance
command: vlogan -full64 -sverilog -ntb_opts uvm-1.2 /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/rtl/generated/gpio_reg_desc_pkg.sv
  /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/rtl/generated/gpio_csr_pkg.sv
  /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/rtl/generated/gpio_csr.sv
  /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/peripheral/io/gpio/rtl/generated/gpio_csr_adapter.sv
artifacts:
- path: regs/gpio.rdl
  sha256: 46bd1bab2da0f44f9bdff6c5bba6f4c7f7a93a9d09d7f6e6849cc3ea40571984
- path: rtl/generated/gpio_csr_pkg.sv
  sha256: 2f03ee84f808170fc92a4ce3ba4ae9c18b96a4a1b7b29b190e9d2e63c0335656
- path: rtl/generated/gpio_csr.sv
  sha256: 7fbf9fde2865aaa4810108bb5612c656e29995651b94c1bb494e3309799b3bab
- path: rtl/generated/gpio_csr_adapter.sv
  sha256: b96118a36f888effa802eaca7aaf8cc610532f9c433592408d10724b08cc0936
- path: rtl/generated/gpio_csr.manifest.yaml
  sha256: 9139333d4a667d48c213aa74ce2377def134413097b95fdafa691b826b685ecc
- path: build/registers/compile/resume_csr_02.log
  sha256: d21e07f21c43f4e6f8d9c8b25bf46658d41d538ce6dfcc975532426814003eeb
END_REPORT_META -->
