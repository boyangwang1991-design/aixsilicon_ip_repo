IP_ROOT := $(abspath ../..)
TESTS ?= apb
SEEDS ?= 1
N_GPIO ?= 32
PARITY ?= 0
.PHONY: run build regression
run:
	cd $(IP_ROOT) && uv run --locked --no-sync python scripts/run_uvm.py --tests $(TESTS) --seeds $(SEEDS) --width $(N_GPIO) --parity $(PARITY) $(EXTRA)
build:
	$(MAKE) run EXTRA="--build-only"
regression:
	$(MAKE) run TESTS="config apb input filter output irq security lowpower aon capture fifo diag parity reset" SEEDS="1 17 101"

.PHONY: run-existing
TIMEOUT ?= 1200
run-existing:
	cd $(IP_ROOT) && uv run --locked --no-sync python verification/sim/run_existing.py --build $(BUILD) --tests $(TESTS) --seeds $(SEEDS) --timeout $(TIMEOUT)
