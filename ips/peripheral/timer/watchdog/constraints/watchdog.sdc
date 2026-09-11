# Characterization profile: pclk 100 MHz, wdt_clk 50 MHz. Not a silicon Fmax claim.
create_clock -name pclk -period 10 [get_ports pclk]
create_clock -name wdt_clk -period 20 [get_ports wdt_clk]
set_clock_uncertainty 0.1 [all_clocks]
set_clock_transition 0.1 [all_clocks]
set_clock_groups -asynchronous -group pclk -group wdt_clk
set_false_path -from [get_ports {por_n preset_n}]
set apb_inputs [get_ports {PSEL PENABLE PWRITE PADDR* PWDATA* PSTRB* PPROT* access_source_i* cfg_auth_i service_auth_i diag_auth_i}]
set wdt_inputs [get_ports {sleep_req_i debug_req_i debug_auth_i warm_reset_evt_i test_auth_i recovery_done_i* hw_evt_valid hw_evt_channel* hw_evt_client* hw_evt_type* hw_evt_data* hw_evt_source*}]
set_input_delay -max 1.0 -clock pclk $apb_inputs
set_input_delay -min 0.0 -clock pclk $apb_inputs
set_input_delay -max 2.0 -clock wdt_clk $wdt_inputs
set_input_delay -min 0.0 -clock wdt_clk $wdt_inputs
set_input_transition 0.1 [remove_from_collection [all_inputs] [get_ports {pclk wdt_clk por_n preset_n}]]
set apb_outputs [get_ports {PRDATA* PREADY PSLVERR irq_o*}]
set wdt_outputs [remove_from_collection [all_outputs] $apb_outputs]
set_output_delay -max 1.0 -clock pclk $apb_outputs
set_output_delay -min 0.0 -clock pclk $apb_outputs
set_output_delay -max 2.0 -clock wdt_clk $wdt_outputs
set_output_delay -min 0.0 -clock wdt_clk $wdt_outputs
set_load 0.01 [all_outputs]
# Bundled-data propagation and reset crossings require separate CDC/RDC audits.
# Asynchronous clock groups alone are not CDC/RDC signoff evidence.
