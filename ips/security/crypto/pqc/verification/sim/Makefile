# All UVM invocations use the evidence runner and verification.list.
.DEFAULT_GOAL := run
IP_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
WORKFLOW_ROOT ?= $(abspath $(IP_ROOT)/../../../../../..)
PYTHON := uv run --project $(WORKFLOW_ROOT) --locked --offline --no-sync python
RUNNER := $(IP_ROOT)/verification/sim/run_uvm.py
TEST ?= tc_cmd_smoke
SEED ?= 1
SEEDS ?= 1 17
# Implemented, self-checking cases only; this is not the full G4 test plan.
TESTS ?= tc_cmd_smoke tc_reg_reset_attr tc_apb_protection tc_key_slot_permission tc_intr_independence tc_kem_encaps_main tc_kem_decaps_main tc_kem_keygen_main
.PHONY: run compile regress ut help
run:
	$(PYTHON) $(RUNNER) --tests '$(TEST)' --seeds '$(SEED)'
compile:
	$(PYTHON) $(RUNNER) --tests '$(TEST)' --seeds '$(SEED)' --build-only
regress:
	$(PYTHON) $(RUNNER) --tests '$(TESTS)' --seeds '$(SEEDS)'
ut:
	cd $(IP_ROOT) && bash verification/unit_test/run_ut.sh $(UT_TEST)
help:
	@echo 'make run TEST=tc_kem_decaps_main SEED=1 | make regress SEEDS="1 17" | make ut UT_TEST=ut_pqc_top'
	@echo 'Evidence: build/sim/uvm/run-*/ (unique build, hashes, logs, summary.json, junit.xml).'
	@echo 'Coverage collection and FuseSoC UVM dependency integration remain open.'
