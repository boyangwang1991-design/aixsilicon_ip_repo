//==============================================================================
// 文件名: tc_base.sv
// 描述:   基础测试类
//         所有测试用例的父类
// 职责:   1. 创建 unit_test_env
//         2. 提供基础 phase 控制
//==============================================================================

`ifndef TC_BASE__SV
`define TC_BASE__SV

class tc_base extends uvm_test;

    //==========================================================================
    // UVM 组件注册
    //==========================================================================
    
    `uvm_component_utils_begin(tc_base)
    `uvm_component_utils_end
    
    //==========================================================================
    // 环境句柄
    //==========================================================================
    
    unit_test_env env;
    
    //==========================================================================
    // 构造函数
    //==========================================================================
    
    extern function new(string name = "tc_base", uvm_component parent = null);
    
    //==========================================================================
    // 构建阶段
    //==========================================================================
    
    extern virtual function void build_phase(uvm_phase phase);
    
    //==========================================================================
    // 结束构建阶段
    //==========================================================================
    
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    
    //==========================================================================
    // 报告阶段
    //==========================================================================
    
    extern virtual function void report_phase(uvm_phase phase);

endclass

//==========================================================================
// Extern 函数定义
//==========================================================================

/// @brief 构造函数定义
/// @param name   测试名称字符串
/// @param parent 父组件句柄
function tc_base::new(string name = "tc_base", uvm_component parent = null);
    super.new(name, parent);
endfunction

/// @brief 构建阶段定义
/// @param phase 当前阶段句柄
function void tc_base::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    // 创建环境
    env = unit_test_env::type_id::create("env", this);
endfunction

/// @brief 结束构建阶段定义
/// @param phase 当前阶段句柄
function void tc_base::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(), "构建完成", UVM_LOW)
    uvm_top.print_topology();
endfunction

/// @brief 报告阶段定义
/// @param phase 当前阶段句柄
function void tc_base::report_phase(uvm_phase phase);
    super.report_phase(phase);
    
    uvm_report_server svr;
    svr = uvm_report_server::get_server();
    
    `uvm_info(get_type_name(), 
        $sformatf("测试 %s 完成，错误数: %0d", 
                  get_name(), svr.get_severity_count(UVM_ERROR)), 
        UVM_LOW)
endfunction

`endif // TC_BASE_SV
