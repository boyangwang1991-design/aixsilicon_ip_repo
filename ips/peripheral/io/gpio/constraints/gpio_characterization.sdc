# Provisional characterization: not a final SoC timing requirement.
create_clock -name CLK_MAIN -period 10 [get_ports pclk_i]
create_clock -name CLK_AON -period 100 [get_ports aon_clk_i]
set_clock_uncertainty 0.1 [all_clocks]
set_clock_groups -asynchronous -group CLK_MAIN -group CLK_AON
set gpio_main_inputs [remove_from_collection [all_inputs] [get_ports {pclk_i aon_clk_i por_ni main_rst_ni aon_rst_ni gpio_in_i* aon_gpio_in_i* aon_input_available_i*}]]
set_input_delay -clock CLK_MAIN 1 $gpio_main_inputs
set_input_delay -clock CLK_AON 10 [get_ports aon_input_available_i*]
set_output_delay -clock CLK_MAIN 1 [remove_from_collection [all_outputs] [get_ports wake_req_o]]
set_output_delay -clock CLK_AON 10 [get_ports wake_req_o]
set_false_path -from [get_ports {por_ni main_rst_ni aon_rst_ni gpio_in_i* aon_gpio_in_i*}]
set_load 0.01 [all_outputs]
# Mailbox bundle stability is checked separately by CDC and protocol assertions.
# Integrators must replace these illustrative I/O budgets and bind physical bundle skew constraints.
