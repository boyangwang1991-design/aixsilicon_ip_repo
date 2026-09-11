# AIXSILICON Watchdog

Candidate SystemVerilog implementation of [watchdog_contract.md](watchdog_contract.md).
The input draft is preserved. This is not a signed-off or released safety IP.

- [RTL top](rtl/watchdog_top.sv) / [channel core](rtl/watchdog_channel.sv)
- [SystemRDL](regs/watchdog.rdl), generated CSR/JSON/header/IP-XACT/UVM RAL
- [Architecture](docs/hld/architecture.md) / [microarchitecture](docs/lld/implementation.md)
- [Usage](docs/user_guide.md) / [safety notes](docs/safety_manual.md)
- [Verification plan](docs/verification/verification_plan.md) / [results](reports/validation_report.md)
- [Skill improvement observations](docs/skill_improvements.md)

Run `bash verification/unit_test/run_ut.sh` from this directory with the workflow
uv environment and configured commercial EDA licenses. Regenerate registers and
packaging with `bash scripts/regenerate.sh`. Runtime artifacts are under build/.

Functional simulation passing does not close CDC/RDC, functional cross coverage,
physical redundancy, PPA or release gates. Consult the validation report for the
precise scope and outstanding qualification work.
