IP_ROOT := $(abspath ../..)
TEST ?= tc_bus
SEED ?= 1
PARAMETERS ?=
REUSE ?=
.PHONY: run smoke
run:
	@test -n "$(UV_PROJECT)" || (echo "Set UV_PROJECT to the shared workflow root"; exit 1)
	cd $(IP_ROOT) && uv run --locked --no-sync python scripts/run_uvm.py --test $(TEST) --seed $(SEED) $(foreach p,$(PARAMETERS),--parameter $(p)) $(if $(REUSE),--reuse $(REUSE),)
smoke: run
