# register_check

<!-- REPORT_META
schema_version: '2.0'
ip_name: spi_master
report_type: register_check
status: pass
eda_profile: commercial-systemverilog
tool: write_quality_evidence.py
tool_version: '1.0'
command: python scripts/write_quality_evidence.py
artifacts:
- path: regs/spi_master.rdl
  sha256: 235f55f9968cf8395f2efffe168183ae97ee22d78fa8966206fa50132005a3b8
- path: rtl/generated/spi_master_csr.manifest.yaml
  sha256: eeee92397ff0423adab6c425867e02cf51e8bc10f9d550a58c14293360e03d93
- path: reports/quality/register-generation.json
  sha256: e272ff2b4a4f4593e9b8415a3682648c63977b09920809ccaad3d2cbd25a8e8c
END_REPORT_META -->

Native PeakRDL views regenerated successfully; generated SV identical. W1C correctness checked by tc_spi_irq and completion collision by tc_spi_races.
