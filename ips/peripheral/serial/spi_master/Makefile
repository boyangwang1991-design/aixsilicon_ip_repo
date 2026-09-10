# Invoke from the IP root. One root uv environment is shared with the workflow.
WORKFLOW_ROOT := $(abspath ../../../../../..)
export UV_PROJECT := $(WORKFLOW_ROOT)
export UV_CACHE_DIR ?= /tmp/spi-master-uv-cache
RUN := uv run --offline --no-sync
CONFIG ?= default
SEED ?= 1
TEST ?= all
.PHONY: registers models pdk dependencies smoke sim regression unit params lint coverage synth driver trace quality signoff evidence acceptance
registers:
	$(RUN) python scripts/generate_registers.py
models:
	$(RUN) python scripts/extract_models.py
pdk:
	$(RUN) python scripts/scan_pdk.py
	$(RUN) python $(WORKFLOW_ROOT)/repos/aixsilicon_skill_repo/skills/ip-development-suite/skills/09-rtl-check/scripts/render_dc_setup.py --pdk model/pdk.yaml --output build/rtl/pdk_setup.tcl
dependencies:
	$(RUN) python scripts/prepare_dependencies.py
smoke: dependencies
	$(RUN) fusesoc --cores-root=. run --target=smoke --build-root=build/fusesoc-smoke aixsilicon:ip:spi_master:1.0.0
sim:
	$(RUN) python scripts/run_verification.py --config $(CONFIG) --test $(TEST) --seed $(SEED)
regression:
	$(RUN) python scripts/run_verification.py --config small
	$(RUN) python scripts/run_verification.py --config default
	$(RUN) python scripts/run_verification.py --config max
	$(RUN) python scripts/run_verification.py --config asymmetric
	$(RUN) python scripts/run_verification.py --test random --seed 17 --no-build
	$(RUN) python scripts/run_verification.py --test random --seed 101 --no-build
	$(RUN) python scripts/run_verification.py --test random --seed 2026 --no-build
unit:
	$(RUN) python scripts/run_unit_tests.py
params:
	$(RUN) python scripts/check_parameters.py
lint:
	bash scripts/spyglass_lint.sh --top spi_master_top --filelist rtl/filelist.f
coverage:
	$(RUN) python scripts/run_coverage.py
synth: dependencies
	$(RUN) python scripts/ppa/run_synthesis.py --config $(CONFIG)
driver:
	mkdir -p build/delivery
	cc -std=c11 -Wall -Wextra -Werror -pedantic -I sw/include sw/src/spi_master.c sw/tests/test_driver.c -o build/delivery/driver-test
	build/delivery/driver-test
trace:
	$(RUN) python $(WORKFLOW_ROOT)/repos/aixsilicon_skill_repo/skills/ip-development-suite/skills/16-trace-manager/scripts/build_trace.py --workspace . --ip-name spi_master --phase closure
quality:
	$(RUN) python $(WORKFLOW_ROOT)/repos/aixsilicon_skill_repo/skills/ip-development-suite/skills/15-regression-quality-review/scripts/evaluate_quality.py --workspace . --ip-name spi_master --output reports/quality/upstream-quality.yaml --gate-report reports/quality/upstream-gate-report.md
	$(RUN) python scripts/evaluate_quality_compat.py --workspace . --ip-name spi_master --output model/quality.yaml --gate-report reports/quality/gate_report.md
signoff: quality
	$(RUN) python scripts/check_gate_status.py
evidence:
	$(RUN) python scripts/archive_evidence.py
acceptance:
	$(RUN) python scripts/check_delivery.py
	$(RUN) python scripts/summarize_acceptance.py
	$(RUN) python scripts/write_quality_evidence.py
