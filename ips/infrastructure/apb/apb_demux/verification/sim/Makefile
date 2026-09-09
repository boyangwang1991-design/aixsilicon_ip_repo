# =============================================================================
# APB Demux UVM 仿真 Makefile（VCS + APB VIP 复用）
# 仓库卫生：所有运行产物统一写入 <ip>/build/sim/；verification/sim/ 只保留入口。
# APB VIP 只读引用自 <workspace>/repos/aixsilicon_vip_repo（不复制、不提交）。
# 用法:
#   make compile
#   make run TEST=tc_sanity SEED=1
#   make smoke         运行 smoke（tc_sanity + tc_decode_miss）
#   make clean
# =============================================================================

IP_ROOT   := $(abspath ../..)
ABS       := $(IP_ROOT)/verification
SIM_BUILD := $(IP_ROOT)/build/sim
RUN_DIR   := $(SIM_BUILD)/run
SIMV      := $(SIM_BUILD)/simv

VCS       ?= vcs
TEST      ?= tc_sanity
SEED      ?= 1

# 工作区 VIP 仓库（只读引用路径）
WORKSPACE := $(abspath ../../../../../../../..)
VIP_REPO  := $(WORKSPACE)/repos/aixsilicon_vip_repo
APB_SRC   := $(VIP_REPO)/vip/amba/apb/src

UVM_OPTS  := -ntb_opts uvm-1.2
VCS_OPTS  := -sverilog -timescale=1ns/1ps -full64 -notice +vcs+flush+all \
             -debug_access+all -ignore initializer_driver_checks $(UVM_OPTS)

RTL_LIST  := $(IP_ROOT)/rtl/apb_demux_top.sv

# APB VIP（编译顺序：types_pkg -> if -> pkg）
VIP_LIST  := $(APB_SRC)/apb_types_pkg.sv \
             $(APB_SRC)/apb_if.sv \
             $(APB_SRC)/apb_pkg.sv

VERIF_LIST := $(ABS)/env/apb_demux_env_pkg.sv \
              $(ABS)/tc/tc_base.sv \
              $(ABS)/tc/tc_sanity.sv \
              $(ABS)/tc/tc_address_decode.sv \
              $(ABS)/tc/tc_psel_onehot.sv \
              $(ABS)/tc/tc_wait_states.sv \
              $(ABS)/tc/tc_pslverr.sv \
              $(ABS)/tc/tc_decode_miss.sv \
              $(ABS)/tc/tc_remap.sv \
              $(ABS)/tc/tc_timeout.sv \
              $(ABS)/tc/tc_output_register.sv \
              $(ABS)/tc/tc_reset.sv \
              $(ABS)/tc/tc_num_slaves_sweep.sv \
              $(ABS)/tc/tc_apb4.sv \
              $(ABS)/tc/tc_assertions.sv \
              $(ABS)/th/tb_top.sv

INCDIRS   := +incdir+$(APB_SRC) \
             +incdir+$(ABS)/env \
             +incdir+$(ABS)/tc \
             +incdir+$(ABS)/th

compile:
	@mkdir -p $(SIM_BUILD)
	cd $(SIM_BUILD) && $(VCS) $(VCS_OPTS) $(INCDIRS) $(RTL_LIST) $(VIP_LIST) $(VERIF_LIST) -o simv 2>&1 | tee compile.log

run: compile
	@test -n "$(TEST)" || (echo "Usage: make run TEST=tc_sanity"; exit 1)
	@mkdir -p $(RUN_DIR)/$(TEST)_$(SEED)
	cd $(RUN_DIR)/$(TEST)_$(SEED) && \
	  $(SIMV) +UVM_TESTNAME=$(TEST) +UVM_SEED=$(SEED) 2>&1 | tee test.log

smoke: compile
	@mkdir -p $(RUN_DIR)
	$(SIMV) +UVM_TESTNAME=tc_sanity +UVM_SEED=1 2>&1 | tee $(RUN_DIR)/smoke_sanity.log | grep -E "UVM_ERROR|UVM_FATAL|SCOREBOARD PASS|no matching"
	$(SIMV) +UVM_TESTNAME=tc_decode_miss +UVM_SEED=1 2>&1 | tee $(RUN_DIR)/smoke_miss.log | grep -E "UVM_ERROR|UVM_FATAL|SCOREBOARD PASS|no matching"

# =============================================================================
# regression: 全 test_matrix（verification.yaml 13 个 TC）
# =============================================================================
REGRESSION_TESTS := tc_sanity tc_address_decode tc_psel_onehot tc_wait_states \
                    tc_pslverr tc_decode_miss tc_remap tc_timeout tc_output_register \
                    tc_reset tc_num_slaves_sweep tc_apb4 tc_assertions

regression: compile
	@mkdir -p $(RUN_DIR)
	@for t in $(REGRESSION_TESTS); do \
	  echo "===== $$t ====="; \
	  $(SIMV) +UVM_TESTNAME=$$t +UVM_SEED=1 2>&1 | tee $(RUN_DIR)/$$t.log | grep -E "UVM_ERROR|UVM_FATAL|SCOREBOARD PASS|no matching"; \
	done

clean:
	rm -rf $(SIM_BUILD)

.PHONY: compile run smoke regression clean
