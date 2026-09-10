<!-- REPORT_META
schema_version: '2.0'
ip_name: axi_mpu
report_type: register_check
status: pass
eda_profile: commercial-systemverilog
tool: vcs
tool_version: 'vcs script version : W-2024.09'
command: vcs -full64 -sverilog -ntb_opts uvm-1.2 /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/rtl/generated/axi_mpu_csr_pkg.sv
  /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/security/firewall/memory_protection_controller/rtl/generated/axi_mpu_csr.sv
  -top axi_mpu_csr -o build/rtl/csr_lint_simv
artifacts:
- path: regs/axi_mpu.rdl
  sha256: f7cac5296e922c4b5ffa87757e5106ab22167c6fe43188bccb5c7c2cbb286dde
- path: rtl/generated/axi_mpu_csr_pkg.sv
  sha256: 160f1c94f02a030d0323b85c895c0f1bd92694e6b571e3367f54eacf223b155f
- path: rtl/generated/axi_mpu_csr.sv
  sha256: cc108732db4d58525a950aa8c3f1dff991843b75f0c5b6b76bcc36cf476c1243
- path: rtl/generated/axi_mpu_csr.manifest.yaml
  sha256: 0f3634544bb03c8c2fb5486783d33377aa2162879fbc3ba238c92c1d3cf0d674
- path: reports/register/csr_lint.log
  sha256: 4d97553728ae2f71ca756b585588731dbcf705c1c4441e4c2329f8ac80187772
END_REPORT_META -->
