//==============================================================================
// 文件名: unit_test_checker.sv
// 描述:   单元测试检查器
//         检查 monitor 采样到的事务是否符合预期
// 职责:   1. 接收 monitor 广播的事务
//         2. 检查基本协议行为
//         3. 统计事务数量
//==============================================================================

`ifndef UNIT_TEST_CHECKER__SV
`define UNIT_TEST_CHECKER__SV

class unit_test_checker extends uvm_component;

    //==========================================================================
    // UVM 组件注册
    //==========================================================================
    
    `uvm_component_utils_begin(unit_test_checker)
    `uvm_component_utils_end
    
    //==========================================================================
    // Analysis Imp (接收事务)
    //==========================================================================
    
    uvm_analysis_imp #(tlul_xaction, unit_test_checker) item_export;
    
    //==========================================================================
    // 统计信息
    //==========================================================================
    
    int unsigned item_count;          // 接收事务计数
    int unsigned error_count;         // 错误计数
    
    //==========================================================================
    // 构造函数
    //==========================================================================
    
    extern function new(string name = "unit_test_checker", uvm_component parent = null);
    
    //==========================================================================
    // 构建阶段
    //==========================================================================
    
    extern virtual function void build_phase(uvm_phase phase);
    
    //==========================================================================
    // 写入函数 (从 analysis port 接收事务)
    //==========================================================================
    
    extern virtual function void write(tlul_xaction tr);
    
    //==========================================================================
    // 事务检查
    //==========================================================================
    
    extern virtual function void check_transaction(tlul_xaction tr);
    
    //==========================================================================
    // 检查阶段
    //==========================================================================
    
    extern virtual function void check_phase(uvm_phase phase);
    
    //==========================================================================
    // 报告阶段
    //==========================================================================
    
    extern virtual function void report_phase(uvm_phase phase);

endclass

//==========================================================================
// Extern 函数定义
//==========================================================================

/// @brief 构造函数定义
/// @param name   检查器名称字符串
/// @param parent 父组件句柄
function unit_test_checker::new(string name = "unit_test_checker", uvm_component parent = null);
    super.new(name, parent);
    item_export = new("item_export", this);
    item_count  = 0;
    error_count = 0;
endfunction

/// @brief 构建阶段定义
/// @param phase 当前阶段句柄
function void unit_test_checker::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

/// @brief 写入函数定义
/// @param tr 接收到的事务
function void unit_test_checker::write(tlul_xaction tr);
    item_count++;
    
    `uvm_info(get_type_name(),
        $sformatf("Checker 接收事务 [%0d]: %s", item_count, tr.convert2string()),
        UVM_MEDIUM
    )
    
    // 基本检查
    check_transaction(tr);
endfunction

/// @brief 事务检查定义
/// @param tr 要检查的事务
function void unit_test_checker::check_transaction(tlul_xaction tr);
    // 检查响应类型
    if (tr.resp == TLUL_RESP_ERROR) begin
        `uvm_warning(get_type_name(), $sformatf("收到错误响应: %s", tr.convert2string()))
        error_count++;
    end
    
    // 可以添加更多协议检查
    // 例如：地址对齐检查、数据有效性检查等
endfunction

/// @brief 检查阶段定义
/// @param phase 当前阶段句柄
function void unit_test_checker::check_phase(uvm_phase phase);
    super.check_phase(phase);
    
    if (item_count == 0) begin
        `uvm_error(get_type_name(), "未采样到任何事务")
    end
endfunction

/// @brief 报告阶段定义
/// @param phase 当前阶段句柄
function void unit_test_checker::report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    `uvm_info(get_type_name(), "========================================", UVM_LOW)
    `uvm_info(get_type_name(), "Checker 统计", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("总事务数:   %0d", item_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("错误数:     %0d", error_count), UVM_LOW)
    `uvm_info(get_type_name(), "========================================", UVM_LOW)
    
    if (error_count > 0) begin
        `uvm_error(get_type_name(), "测试失败")
    end else begin
        `uvm_info(get_type_name(), "测试通过", UVM_LOW)
    end
endfunction

`endif // UNIT_TEST_CHECKER_SV
