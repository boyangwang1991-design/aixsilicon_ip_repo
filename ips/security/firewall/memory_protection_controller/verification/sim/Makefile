# AXI MPU - UVM Regression Makefile (entry point)
# 双构建系统：UVM 验证构建走本 Makefile（VCS），运行产物 → ../build/sim/
# 用法：
#   make compile                      # 编译 simv
#   make run TEST=tc_smoke_basic SEED=1
#   make regress                      # 全量 regression_list.yaml

VCS      = vcs
VCS_OPTS = -full64 -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2 -debug_access+all
BUILD    = ../build/sim
LIST     = verification.list

TEST ?= tc_smoke_basic
SEED ?= 1

.PHONY: compile run regress clean

compile:
	@mkdir -p $(BUILD)
	cd .. && $(VCS) $(VCS_OPTS) -f verification/$(LIST) -top harness \
	    -o build/sim/simv -l build/sim/compile.log

run: compile
	@mkdir -p $(BUILD)/run
	cd $(BUILD) && ./simv +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=UVM_LOW \
	    +ntb_random_seed=$(SEED) -l run/$(TEST)_$(SEED).log

regress:
	@mkdir -p $(BUILD)/run
	@for t in $$(uv run python -c "import yaml,sys;d=yaml.safe_load(open('sim/regression_list.yaml'));[print(e['test']) for tier in ('smoke','regression','extended') for e in d.get(tier,[])]"); do \
	    $(MAKE) run TEST=$$t SEED=$(SEED) || exit 1; \
	done

clean:
	rm -rf $(BUILD)
