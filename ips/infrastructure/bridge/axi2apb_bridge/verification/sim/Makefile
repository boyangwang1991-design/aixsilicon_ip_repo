# =============================================================================
# X2P UVM 仿真 Makefile（VCS，VIP axi4 master + apb slave 集成）
# 仓库卫生约定：所有运行产物（simv/csrc/*.daidir/run/fsdb/日志）统一写入
# <ip>/build/sim/，verification/sim/ 只保留本 Makefile 与 README（入口）。
# VIP 源码只读引用自 <workspace>/repos/aixsilicon_vip_repo（FuseSoC depend 语义；
# 不复制、不提交到本 IP 仓库）；edalize 落地的副本位于 build/（gitignore）。
# 用法:
#   make compile      编译（产物 → <ip>/build/sim/）
#   make run TEST=tc_sanity SEED=1 [PLUSARGS=...]
#   make smoke        运行全部 smoke
#   make regression   运行全部 regression（3 个测试组）
#   make clean        清理 build/sim
# 超时专项：tc_timeout 需 +X2P_APB_TIMEOUT=1（见 regression / 手动 run 时附加）
# =============================================================================

# 目录定义（全绝对路径，编译/运行在 SIM_BUILD 内执行，VCS csrc 亦落 build/sim）
IP_ROOT    := $(abspath ../..)
ABS        := $(IP_ROOT)/verification
SIM_BUILD  := $(IP_ROOT)/build/sim
RUN_DIR    := $(SIM_BUILD)/run
SIMV       := $(SIM_BUILD)/simv

VCS        ?= vcs
TEST       ?= tc_sanity
SEED       ?= 1

EXTRA_DEF  ?=
UVM_OPTS   := -ntb_opts uvm-1.2
# apb_if 为复位安全给 requester 侧变量预置初值；真实 APB-master DUT 结构驱动时
# 会触发 ICPSD_INIT。复位期 DUT 输出与初值同为 0（无运行期 X），故降级为警告。
VCS_OPTS   := -sverilog -timescale=1ns/1ps -full64 -notice +vcs+flush+all \
              -debug_access+all -ignore initializer_driver_checks \
              $(UVM_OPTS) $(EXTRA_DEF)

# VIP 仓库（只读引用路径）
VIP_REPO   := $(abspath ../../../repos/aixsilicon_vip_repo)
AXI4_SRC   := $(VIP_REPO)/vip/amba/axi4/src
APB_SRC    := $(VIP_REPO)/vip/amba/apb/src

RTL_LIST   := $(IP_ROOT)/rtl/x2p_pkg.sv \
              $(IP_ROOT)/rtl/x2p_req_mgr.sv \
              $(IP_ROOT)/rtl/x2p_scheduler.sv \
              $(IP_ROOT)/rtl/x2p_transfer_engine.sv \
              $(IP_ROOT)/rtl/x2p_cdc.sv \
              $(IP_ROOT)/rtl/x2p_apb_engine.sv \
              $(IP_ROOT)/rtl/x2p_rsp_mgr.sv \
              $(IP_ROOT)/rtl/x2p_axi_frontend.sv \
              $(IP_ROOT)/rtl/x2p_top.sv

# VIP axi4 / apb（编译顺序：types_pkg → if → pkg）
VIP_LIST   := $(AXI4_SRC)/axi4_types_pkg.sv \
              $(AXI4_SRC)/axi4_if.sv \
              $(AXI4_SRC)/axi4_pkg.sv \
              $(APB_SRC)/apb_types_pkg.sv \
              $(APB_SRC)/apb_if.sv \
              $(APB_SRC)/apb_pkg.sv

VERIF_LIST := $(VIP_LIST) \
              $(ABS)/env/x2p_env.sv \
              $(ABS)/tc/tc_define.sv \
              $(ABS)/tc/tc_base.sv \
              $(ABS)/tc/tc_sanity.sv \
              $(ABS)/tc/tc_burst.sv \
              $(ABS)/tc/tc_timeout.sv \
              $(ABS)/th/harness.sv

INCDIRS    := +incdir+$(AXI4_SRC) \
              +incdir+$(APB_SRC) \
              +incdir+$(ABS)/env \
              +incdir+$(ABS)/tc \
              +incdir+$(ABS)/th

compile:
	@mkdir -p $(SIM_BUILD)
	cd $(SIM_BUILD) && $(VCS) $(VCS_OPTS) $(INCDIRS) $(RTL_LIST) $(VERIF_LIST) \
	  -o simv 2>&1 | tee compile.log

run: compile
	@test -n "$(TEST)" || (echo "Usage: make run TEST=tc_sanity"; exit 1)
	@mkdir -p $(RUN_DIR)/$(TEST)_$(SEED)
	cd $(RUN_DIR)/$(TEST)_$(SEED) && \
	  $(SIMV) +UVM_TESTNAME=$(TEST) +UVM_SEED=$(SEED) $(PLUSARGS) \
	  2>&1 | tee test.log

smoke: compile
	@mkdir -p $(RUN_DIR)
	$(SIMV) +UVM_TESTNAME=tc_sanity +UVM_SEED=1 2>&1 | tee $(RUN_DIR)/smoke.log

regression: compile
	@mkdir -p $(RUN_DIR)
	$(SIMV) +UVM_TESTNAME=tc_sanity  +UVM_SEED=1                     2>&1 | tee $(RUN_DIR)/tc_sanity.log
	$(SIMV) +UVM_TESTNAME=tc_burst   +UVM_SEED=1                     2>&1 | tee $(RUN_DIR)/tc_burst.log
	$(SIMV) +UVM_TESTNAME=tc_timeout +UVM_SEED=1 +X2P_APB_TIMEOUT    2>&1 | tee $(RUN_DIR)/tc_timeout.log

clean:
	rm -rf $(SIM_BUILD)

.PHONY: compile run smoke regression clean
