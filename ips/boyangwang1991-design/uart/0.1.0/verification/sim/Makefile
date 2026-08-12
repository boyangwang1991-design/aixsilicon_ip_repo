# UART Verification Makefile
# 用于编译、运行仿真、回归测试和 Verdi 调试

# 变量定义
SIMULATOR ?= vcs
TEST ?= tc_sanity
SEED ?= random
GUI ?= 0
COV ?= 0

# 目录定义 (IP_ROOT 为 IP 工作区根目录；所有 filelist 相对根目录解析)
SIM_DIR := $(shell pwd)
IP_ROOT := $(SIM_DIR)/../..
VERIFICATION_DIR := $(IP_ROOT)/verification
ENV_DIR := $(VERIFICATION_DIR)/env
TC_DIR := $(VERIFICATION_DIR)/tc
TH_DIR := $(VERIFICATION_DIR)/th

# Filelist (使用根相对 check_uvm.f 以包含 RTL + UVM 环境)
FILELIST := verification/check_uvm.f

# 仿真器选项
ifeq ($(SIMULATOR),vcs)
    # VCS 选项: -ntb_opts uvm-1.2 必须在命令行（不能在 -f 文件内）
    VCS_OPTS := -full64 -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2
    COMPILE_CMD = cd $(IP_ROOT) && vcs $(VCS_OPTS) -f verification/check_uvm.f -l $(SIM_DIR)/compile.log
    RUN_CMD = cd $(IP_ROOT) && ./simv +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=UVM_MEDIUM -l $(SIM_DIR)/run_$(TEST).log
    ifeq ($(GUI),1)
        RUN_CMD += -gui
    endif
    ifeq ($(COV),1)
        COMPILE_CMD += -cm line+cond+tgl+fsm+branch
        RUN_CMD += -cm line+cond+tgl+fsm+branch
    endif
else ifeq ($(SIMULATOR),xcelium)
    COMPILE_CMD = xrun -f $(FILELIST) -64bit -sv -timescale 1ns/1ps \
                  +define+UVM_NO_DEPRECATED +define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR \
                  -l compile.log -uvm
    RUN_CMD = xrun -R +UVM_TESTNAME=$(TEST) +UVM_SET_SEED=$(SEED) \
              -l run.log +UVM_VERBOSITY=UVM_MEDIUM
    ifeq ($(GUI),1)
        RUN_CMD += -gui
    endif
else ifeq ($(SIMULATOR),questa)
    COMPILE_CMD = vlib work && vlog -f $(FILELIST) +incdir+$(ENV_DIR) +incdir+$(TC_DIR)
    RUN_CMD = vsim -c -do "run -all" +UVM_TESTNAME=$(TEST) +UVM_SET_SEED=$(SEED)
endif

# 默认目标
.PHONY: all compile run clean regress verdi

all: compile run

# 编译 (在 verification 目录执行，simv 生成在那里)
compile:
	@echo "[编译] 使用 $(SIMULATOR) 编译..."
	@$(COMPILE_CMD)
	@echo "[编译] 完成"

# 运行单测 (在 verification 目录执行)
run: compile
	@echo "[运行] 测试: $(TEST), Seed: $(SEED)"
	@cd $(VERIFICATION_DIR) && $(RUN_CMD)
	@echo "[运行] 完成，日志: $(SIM_DIR)/run_$(TEST).log"

# 运行回归测试
regress:
	@echo "[回归] 运行所有测试..."
	@for test in tc_sanity tc_basic_reset tc_basic_single_tx tc_basic_continuous_rx; do \
		$(MAKE) run TEST=$$test SEED=$$$$ || exit 1; \
	done
	@echo "[回归] 完成"

# 启动 Verdi 调试
verdi:
	@echo "[Verdi] 启动调试..."
ifeq ($(SIMULATOR),vcs)
	verdi -ssf $(RUN_DIR)/*.vpd -f $(FILELIST) &
else ifeq ($(SIMULATOR),xcelium)
	verdi -ssv -f $(FILELIST) &
endif

# 查看覆盖率
coverage:
	@echo "[覆盖率] 生成覆盖率报告..."
ifeq ($(SIMULATOR),vcs)
	urg -dir $(RUN_DIR)/simv.vdb -report $(RUN_DIR)/coverage_report
else ifeq ($(SIMULATOR),xcelium)
	imc -load $(RUN_DIR)/metrics.db -exec "report_coverage" -out $(RUN_DIR)/coverage_report
endif

# 清理
clean:
	@echo "[清理] 删除编译和运行产物..."
	@rm -f *.log
	@cd $(VERIFICATION_DIR) && rm -rf csrc simv simv.daidir simv.cst *.log *.key *.vcd *.vpd
	@echo "[清理] 完成"
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
