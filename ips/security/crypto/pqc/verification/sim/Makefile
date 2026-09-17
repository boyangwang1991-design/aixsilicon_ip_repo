# PQC Verification Makefile
# 用于编译、运行仿真、回归测试和 Verdi 调试
#
# Module UT（G3 固定步骤）与 UVM 仿真共用本入口：
#   make ut [TEST=ut_pqc_csr]   -> bash verification/unit_test/run_ut.sh
#   make compile / run / regress / coverage -> UVM 环境（tc/ + th/）
# UT 由同一个根 FuseSoC core 的 fileset 解析编译，不维护第二份源清单。
UT_ARGS = $(if $(TEST),$(TEST),)
ut:
	cd $(IP_ROOT) && bash verification/unit_test/run_ut.sh $(UT_ARGS)
.PHONY: ut

# 变量定义
SIMULATOR ?= vcs
TEST ?= tc_sanity
SEED ?= random
GUI ?= 0
COV ?= 0

# 目录定义：产物统一写入 <ip>/build/sim/（仓库卫生约定），源码目录只存入口
VERIFICATION_DIR := $(abspath ..)
IP_ROOT          := $(abspath ../..)
ENV_DIR          := $(VERIFICATION_DIR)/env
TC_DIR           := $(VERIFICATION_DIR)/tc
TH_DIR           := $(VERIFICATION_DIR)/th
BUILD_ROOT       := $(IP_ROOT)/build
SIM_BUILD        := $(BUILD_ROOT)/sim
RUN_DIR          := $(SIM_BUILD)/run/$(TEST)_$(SEED)

# Filelist (使用 check_uvm.f 以包含 RTL + UVM 环境)
FILELIST := $(VERIFICATION_DIR)/check_uvm.f

# 仿真器选项
# 注意：check_uvm.f 内含相对路径（相对 verification/ 解析），因此编译仍在
# VERIFICATION_DIR 内执行以保证 filelist 正确；可执行文件/日志/波形一律落到
# SIM_BUILD（build/sim），编译后把 VCS 遗留的 csrc/simv.cst 归入 build/sim，
# 确保源码目录零运行中间件（仓库卫生约定）。
ifeq ($(SIMULATOR),vcs)
    # VCS 选项: -ntb_opts uvm-1.2 必须在命令行（不能在 -f 文件内）
    VCS_OPTS := -full64 -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2
    COMPILE_CMD = mkdir -p $(SIM_BUILD) && cd $(VERIFICATION_DIR) && vcs $(VCS_OPTS) -f check_uvm.f -o $(SIM_BUILD)/simv -l $(SIM_BUILD)/compile.log && { mv -f csrc simv.cst $(SIM_BUILD)/ 2>/dev/null || true; }
    RUN_CMD = mkdir -p $(RUN_DIR) && cd $(SIM_BUILD) && ./simv +UVM_TESTNAME=$(TEST) +UVM_SEED=$(SEED) +UVM_VERBOSITY=UVM_MEDIUM -l $(RUN_DIR)/run.log
    ifeq ($(GUI),1)
        RUN_CMD += -gui
    endif
    ifeq ($(COV),1)
        COMPILE_CMD += -cm line+cond+tgl+fsm+branch
        RUN_CMD += -cm line+cond+tgl+fsm+branch
    endif
else ifeq ($(SIMULATOR),xcelium)
    COMPILE_CMD = mkdir -p $(SIM_BUILD) && cd $(SIM_BUILD) && xrun -f $(FILELIST) -64bit -sv -timescale 1ns/1ps +define+UVM_NO_DEPRECATED +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR -l compile.log -uvm
    RUN_CMD = cd $(SIM_BUILD) && xrun -R +UVM_TESTNAME=$(TEST) +UVM_SET_SEED=$(SEED) -l run.log +UVM_VERBOSITY=UVM_MEDIUM
    ifeq ($(GUI),1)
        RUN_CMD += -gui
    endif
else ifeq ($(SIMULATOR),questa)
    COMPILE_CMD = mkdir -p $(SIM_BUILD) && cd $(SIM_BUILD) && vlib work && vlog -f $(FILELIST) +incdir+$(ENV_DIR) +incdir+$(TC_DIR)
    RUN_CMD = cd $(SIM_BUILD) && vsim -c -do "run -all" +UVM_TESTNAME=$(TEST) +UVM_SET_SEED=$(SEED)
endif

# 默认目标
.PHONY: all compile run clean regress verdi coverage help

all: compile run

# 编译（产物 → build/sim/）
compile:
	@mkdir -p $(SIM_BUILD)
	@echo "[编译] 使用 $(SIMULATOR) 编译..."
	@$(COMPILE_CMD)
	@echo "[编译] 完成，产物: $(SIM_BUILD)/simv"

# 运行单测（产物 → build/sim/run/<TEST>_<SEED>/）
run: compile
	@echo "[运行] 测试: $(TEST), Seed: $(SEED)"
	@$(RUN_CMD)
	@echo "[运行] 完成，日志: $(RUN_DIR)/run.log"

# 运行回归测试
regress:
	@echo "[回归] 运行所有测试..."
	@for test in tc_sanity tc_basic_reset tc_basic_single_tx tc_basic_continuous_rx; do $(MAKE) run TEST=$$test SEED=random || exit 1; done
	@echo "[回归] 完成"

# 启动 Verdi 调试（波形在 build/sim/ 下）
verdi:
	@echo "[Verdi] 启动调试..."
ifeq ($(SIMULATOR),vcs)
	verdi -ssf $(SIM_BUILD)/*.vpd -f $(FILELIST) &
else ifeq ($(SIMULATOR),xcelium)
	verdi -ssv -f $(FILELIST) &
endif

# 查看覆盖率（数据库在 build/sim/）
coverage:
	@echo "[覆盖率] 生成覆盖率报告..."
ifeq ($(SIMULATOR),vcs)
	urg -dir $(SIM_BUILD)/simv.vdb -report $(SIM_BUILD)/coverage_report
else ifeq ($(SIMULATOR),xcelium)
	imc -load $(SIM_BUILD)/metrics.db -exec "report_coverage" -out $(SIM_BUILD)/coverage_report
endif

# 清理（只清 build/sim，不动源码目录）
clean:
	@echo "[清理] 删除运行中间件 $(SIM_BUILD) ..."
	@rm -rf $(SIM_BUILD)
	@echo "[清理] 完成"

# 帮助
help:
	@echo "用法:"
	@echo "  make compile          - 编译设计"
	@echo "  make run TEST=<name>  - 运行指定测试"
	@echo "  make regress          - 运行回归测试"
	@echo "  make verdi            - 启动 Verdi 调试"
	@echo "  make coverage         - 生成覆盖率报告"
	@echo "  make clean            - 清理运行文件"
	@echo ""
	@echo "变量:"
	@echo "  SIMULATOR=vcs|xcelium|questa  - 选择仿真器 (默认: vcs)"
	@echo "  TEST=<test_name>              - 测试名称 (默认: tc_sanity)"
	@echo "  SEED=<seed>                   - 随机种子 (默认: random)"
	@echo "  GUI=0|1                       - 是否启动 GUI (默认: 0)"
	@echo "  COV=0|1                       - 是否收集覆盖率 (默认: 0)"
