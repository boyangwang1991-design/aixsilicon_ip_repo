IP_ROOT := $(abspath ../..)
TEST ?= tc_bus
SEED ?= 1
PARAMETERS ?=
REUSE ?=
.PHONY: run smoke regress parameters delivery
run:
	@test -n "$(UV_PROJECT)" || (echo "Set UV_PROJECT to the shared workflow root"; exit 1)
	cd $(IP_ROOT) && uv run --locked --no-sync python scripts/run_uvm.py --test $(TEST) --seed $(SEED) $(foreach p,$(PARAMETERS),--parameter $(p)) $(if $(REUSE),--reuse $(REUSE),)
smoke:
	cd $(IP_ROOT) && uv run --locked --no-sync python scripts/run_regression.py --phase smoke
regress:
	cd $(IP_ROOT) && uv run --locked --no-sync python scripts/run_regression.py --phase regress
parameters:
	cd $(IP_ROOT) && uv run --locked --no-sync python scripts/run_parameter_verification.py
delivery:
	cd $(IP_ROOT) && uv run --locked --no-sync python scripts/check_delivery.py
