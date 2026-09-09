# =============================================================================
# APB CDC Bridge UVM 仿真 Makefile（VCS + APB VIP）
# 仓库卫生：所有运行产物（simv/csrc/*.daidir/run/日志）统一写入 <ip>/build/sim/，
# verification/sim/ 只保留本 Makefile 与 README（入口）。
# APB VIP 只读引用自 <workspace>/repos/aixsilicon_vip_repo（不复制、不提交）。
# 用法:
#   make compile
#   make run TEST=tc_sanity SEED=1
#   make smoke         运行 smoke（tc_sanity）
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
# verification/sim -> ../../ 到 ip 根；上溯至 workflow 根：
#   ip根(../..) -> cdc(../../..) -> infra(../../../..) -> ips(../../../../..)
#   -> ip_repo(../../../../../..) -> repos(../../../../../../..) -> workflow(../../../../../../../..)
WORKSPACE := $(abspath ../../../../../../../..)
VIP_REPO  := $(WORKSPACE)/repos/aixsilicon_vip_repo
APB_SRC   := $(VIP_REPO)/vip/amba/apb/src

UVM_OPTS  := -ntb_opts uvm-1.2
VCS_OPTS  := -sverilog -timescale=1ns/1ps -full64 -notice +vcs+flush+all \
             -debug_access+all -ignore initializer_driver_checks $(UVM_OPTS)

RTL_LIST  := $(IP_ROOT)/rtl/apb_cdc_bridge_pkg.sv \
             $(IP_ROOT)/rtl/apb_cdc_sync_chain.sv \
             $(IP_ROOT)/rtl/apb_cdc_handshake.sv \
             $(IP_ROOT)/rtl/apb_cdc_async_fifo.sv \
             $(IP_ROOT)/rtl/apb_cdc_source.sv \
             $(IP_ROOT)/rtl/apb_cdc_dest.sv \
             $(IP_ROOT)/rtl/apb_cdc_bridge_top.sv

# APB VIP（编译顺序：types_pkg -> if -> pkg）
VIP_LIST  := $(APB_SRC)/apb_types_pkg.sv \
             $(APB_SRC)/apb_if.sv \
             $(APB_SRC)/apb_pkg.sv

VERIF_LIST := $(ABS)/env/apb_cdc_bridge_env_pkg.sv \
              $(ABS)/tc/tc_base.sv \
              $(ABS)/tc/tc_sanity.sv \
              $(ABS)/tc/tc_downstream_wait.sv \
              $(ABS)/tc/tc_pslverr.sv \
              $(ABS)/tc/tc_handshake_config.sv \
              $(ABS)/tc/tc_fifo_depth.sv \
              $(ABS)/tc/tc_clock_relation.sv \
              $(ABS)/tc/tc_clock_pause.sv \
              $(ABS)/tc/tc_reset_scenarios.sv \
              $(ABS)/tc/tc_apb4.sv \
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
	$(SIMV) +UVM_TESTNAME=tc_sanity +UVM_SEED=1 2>&1 | tee $(RUN_DIR)/smoke.log

# =============================================================================
# regression: 全 test_matrix（verification.yaml 10 个 TC）
#   - 基础回归（默认 1:2 异步 HANDSHAKE）：sanity/wait/err/handshake/fifo/clk/pause/rst/apb4
#   - clock_relation 时钟矩阵：1:1/1:2/1:4/1:8/2:1/4:1/8:1/near/irrational（plusarg 覆盖）
#   - fifo_depth 用 +CDC_IMPL 覆盖 DUT 参数（compile 时经 pvalue 透传，示例以默认 HANDSHAKE 为准；
#     全 FIFO 深度回归见 regression_fifo）
# =============================================================================
REGRESSION_TESTS := tc_sanity tc_downstream_wait tc_pslverr tc_handshake_config \
                    tc_fifo_depth tc_clock_relation tc_clock_pause tc_reset_scenarios tc_apb4

regression: compile
	@mkdir -p $(RUN_DIR)
	@for t in $(REGRESSION_TESTS); do \
	  echo "===== $$t ====="; \
	  $(SIMV) +UVM_TESTNAME=$$t +UVM_SEED=1 2>&1 | tee $(RUN_DIR)/$$t.log | grep -E "UVM_ERROR|UVM_FATAL|SCOREBOARD PASS|no matching"; \
	done

# 时钟关系矩阵（近 1:1 / 1:4 / 8:1 示例；S/M 周期 ps）
clk_matrix:
	@mkdir -p $(RUN_DIR)
	$(SIMV) +UVM_TESTNAME=tc_clock_relation +UVM_SEED=1 +S_PERIOD_PS=10000 +M_PERIOD_PS=10000 2>&1 | tee $(RUN_DIR)/clk_1to1.log   | grep -E "UVM_ERROR|UVM_FATAL|no matching"
	$(SIMV) +UVM_TESTNAME=tc_clock_relation +UVM_SEED=1 +S_PERIOD_PS=10000 +M_PERIOD_PS=40000 2>&1 | tee $(RUN_DIR)/clk_1to4.log   | grep -E "UVM_ERROR|UVM_FATAL|no matching"
	$(SIMV) +UVM_TESTNAME=tc_clock_relation +UVM_SEED=1 +S_PERIOD_PS=80000 +M_PERIOD_PS=10000 2>&1 | tee $(RUN_DIR)/clk_8to1.log   | grep -E "UVM_ERROR|UVM_FATAL|no matching"
	$(SIMV) +UVM_TESTNAME=tc_clock_relation +UVM_SEED=1 +S_PERIOD_PS=10003 +M_PERIOD_PS=10000 2>&1 | tee $(RUN_DIR)/clk_near.log   | grep -E "UVM_ERROR|UVM_FATAL|no matching"

clean:
	rm -rf $(SIM_BUILD)

.PHONY: compile run smoke regression clk_matrix clean
