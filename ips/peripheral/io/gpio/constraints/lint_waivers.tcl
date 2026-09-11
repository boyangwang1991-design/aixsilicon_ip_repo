# Scoped coding-style waivers. Rationale and raw counts: reports/lint/review.md.
# Generated external CSR fields unused by the RDL adapter; business bus policy is in gpio_apb_if.
waive -rule W240 -file {*gpio_csr.sv *gpio_csr_adapter.sv *gpio_regfile.sv *gpio_diag.sv}
# Deliberate default-then-override combinational construction, single procedural driver.
waive -rule W415a -file {*gpio_csr.sv *gpio.sv *gpio_aon_mailbox.sv *gpio_aon_wake.sv *gpio_capture.sv *gpio_output.sv *gpio_regfile.sv}
# Reset defaults and event-set-over-clear priorities in a single clocked process.
waive -rule STARC05-2.2.3.3 -file {*gpio_aon_mailbox.sv *gpio_capture.sv *gpio_regfile.sv}
# One-process FSM is allowed by the microarchitecture coding contract.
waive -rule STARC05-2.11.3.1 -file {*gpio_aon_mailbox.sv}
# Maximum geometry and optional features leave unused status fields and native CSR policy outputs.
waive -rule W528 -file {*gpio_csr.sv *gpio.sv}
# Warm-reset-qualified accept prevents new traffic from entering POR-retained transport.
# This style waiver does NOT waive or close CDC/RDC checks; dedicated targets remain required.
waive -rule STARC05-1.3.1.3 -file {*gpio_aon_mailbox.sv} -msg {*inflight_q_reg.EN*}
