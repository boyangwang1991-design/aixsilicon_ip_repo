# rtl_check

<!-- REPORT_META
schema_version: '2.0'
ip_name: spi_master
report_type: rtl_check
status: pass
eda_profile: commercial-systemverilog
tool: write_quality_evidence.py
tool_version: '1.0'
command: python scripts/write_quality_evidence.py
artifacts:
- path: build/rtl/lint_spyglass/spyglass-1/spi_master_top/lint/lint_rtl/spyglass.log
  sha256: 493a182b968d10dfa8f60983bfc0c519b01fda34528eb1c6a821909a2070fdd8
- path: build/sim/default/compile.log
  sha256: fc96a1317a8cb1ecc004a480448a8300705a31f5ea298d342c62361d9df91943
- path: reports/synth/default/synth.log
  sha256: 4e1919416a2070e1c69a9acdc6cd71ea3cd25b769c1b40cba19153e5bba2c842
checks:
  lint:
    status: pass
    exit_code: 0
    tool: spyglass
    tool_version: X-2025.06
    command: bash scripts/spyglass_lint.sh --top spi_master_top --filelist rtl/filelist.f
    log: build/rtl/lint_spyglass/spyglass-1/spi_master_top/lint/lint_rtl/spyglass.log
    log_sha256: 493a182b968d10dfa8f60983bfc0c519b01fda34528eb1c6a821909a2070fdd8
  elab:
    status: pass
    exit_code: 0
    tool: vcs
    tool_version: W-2024.09-SP1
    command: python scripts/run_verification.py --config default
    log: build/sim/default/compile.log
    log_sha256: fc96a1317a8cb1ecc004a480448a8300705a31f5ea298d342c62361d9df91943
  synth:
    status: pass
    exit_code: 0
    tool: dc_shell
    tool_version: V-2023.12-SP3
    command: python scripts/ppa/run_synthesis.py --config default
    log: reports/synth/default/synth.log
    log_sha256: 4e1919416a2070e1c69a9acdc6cd71ea3cd25b769c1b40cba19153e5bba2c842
END_REPORT_META -->

Lint warnings are reviewed in static-review.md, not waived. Formal availability is reported separately; SVA runs are simulation, not a proof.
