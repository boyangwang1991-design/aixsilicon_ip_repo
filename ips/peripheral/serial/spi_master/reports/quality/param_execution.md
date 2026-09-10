# param_execution

<!-- REPORT_META
schema_version: '2.0'
ip_name: spi_master
report_type: param_execution
status: pass
eda_profile: commercial-systemverilog
tool: write_quality_evidence.py
tool_version: '1.0'
command: python scripts/write_quality_evidence.py
artifacts:
- path: reports/quality/regression-small-1.json
  sha256: bf0687bd933ddb8d97d21c2fa5ce6684637817644e473776252440854639e1a3
- path: reports/quality/regression-default-1.json
  sha256: b9f40f455ed09820b68d3caf1cbee1ab8cd6d305f16e2d1b933cfd1c3b2f55fd
- path: reports/quality/regression-max-1.json
  sha256: 00e9c1e00c606eba4c3273ed916cd041bb04e99f9a151232e011a24c22acd0f8
- path: reports/quality/regression-asymmetric-1.json
  sha256: cb798778eba58233fc1c19fa45643b81e680990221dadf62803a13c8dd3604a9
- path: reports/quality/negative-parameters.json
  sha256: 9d7f23224b6359beb649bd00ddd687e8b3a6201de89d61fddc0aa8596b0a1164
END_REPORT_META -->

Four named mandatory/boundary/risk configurations executed; nine UVM groups each. Eleven deliberately illegal values rejected. Automatically suggested additional pairwise configurations are planning candidates, not falsely marked executed.
