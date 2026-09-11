`ifndef WATCHDOG_ENV_DEC__SV
`define WATCHDOG_ENV_DEC__SV
typedef enum {WDT_EDGE,PCLK_EDGE} watchdog_observation_kind;
typedef enum {CTRL_POR,CTRL_PRESET,CTRL_WARM,CTRL_SLEEP,CTRL_DEBUG,CTRL_AUTH,CTRL_RECOVERY,
              CTRL_CLOCKS,CTRL_HW_EVENT,CTRL_WAIT} watchdog_control_kind;
`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_wdt)
`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)
`endif
