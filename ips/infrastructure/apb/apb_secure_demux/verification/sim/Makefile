# Invoke under the workspace's uv run --locked environment.
PYTHON ?= python3
SUITE_DIR ?= $(error SUITE_DIR must point to ip-development-suite)
CBB_ROOT ?= $(error CBB_ROOT must point to aixsilicon_cbb_repo)
VIP_ROOT ?= $(error VIP_ROOT must point to aixsilicon_vip_repo)
SEED ?= 42
TEST ?=
RUNNER := $(abspath ../../scripts/run_uvm.py)
ARGS = --suite "$(SUITE_DIR)" --cbb-root "$(CBB_ROOT)" --vip-root "$(VIP_ROOT)" --seed "$(SEED)"
.PHONY: compile smoke regress run
compile:
	$(PYTHON) "$(RUNNER)" $(ARGS) --mode compile
smoke:
	$(PYTHON) "$(RUNNER)" $(ARGS) --mode smoke
regress:
	$(PYTHON) "$(RUNNER)" $(ARGS) --mode regress
run:
	$(PYTHON) "$(RUNNER)" $(ARGS) --mode smoke $(if $(TEST),--test "$(TEST)",)
