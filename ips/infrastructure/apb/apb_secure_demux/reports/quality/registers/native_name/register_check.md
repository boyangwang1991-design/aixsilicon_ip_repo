<!-- REPORT_META
schema_version: '2.0'
ip_name: apb_secure_demux
report_type: register_check
status: pass
eda_profile: commercial-systemverilog
tool: vlogan
tool_version: VCS W-2024.09-SP1
command: vlogan -full64 -sverilog /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/rtl/generated/apb_secure_demux_csr_pkg.sv
  /home/eda/workspace/aixsilicon_workflow/repos/aixsilicon_ip_repo/ips/infrastructure/apb/apb_secure_demux/rtl/generated/apb_secure_demux_csr.sv
artifacts:
- path: regs/apb_secure_demux.rdl
  sha256: 321c4a16f3615b56df293e1a25a71f5519e7eac17506a431c6faa30bab7965c4
- path: rtl/generated/apb_secure_demux_csr_pkg.sv
  sha256: 33b9fe0fb282bf7770a9a6caddb9c5a80cf057bb378585662cc8cd74e00823fb
- path: rtl/generated/apb_secure_demux_csr.sv
  sha256: 89ba9f7929e1210375f057e74c7934911ee1f470e8436bf5c9911cebb95b0d7b
- path: rtl/generated/apb_secure_demux_csr.manifest.yaml
  sha256: a92dcfa1627def29906f52d7a7c32d00e8e44df8365cbd33224e3981d1a83d21
- path: reports/quality/registers/native_compile.log
  sha256: 8db7c50fb5ab881b2a7c81fd324174c8b7444fe2f21cb57fc435a603a9478c47
END_REPORT_META -->

# 寄存器生成检查范围

以上REPORT_META由02的publish_csr.py生成，证明原生CSR包/模块经vlogan解析且来源一致。8个命名配置的结构/复位/固定槽位审计、regblock及vlogan检查均通过，典型配置399寄存器覆盖122项逻辑字段行为。另以非均匀非零启动策略夹具检查全部active/shadow字段复位和RAL生成。

VCS在原沙箱无法连接许可证；允许网络访问后elaboration及9笔CSR接口探针通过。该探针使用external状态模型，只验证原生适配器首ACCESS、连续事务、读写属性错误和地址空洞。它不证明权限/锁/事件/中断/DFX功能owner已实现，不能代替IP级UVM或形式验证。证据见registers/probe_success.json、matrix.json、nonzero_reset_structure.json。

CSR及全IP的工艺映射综合、STA属于后续09/20检查，当前无此签核结果；未把vlogan语法检查记成综合通过。G2的行为冻结与原生寄存器生成准入已满足，完整RTL Ready仍需G3。
