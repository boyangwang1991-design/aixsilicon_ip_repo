# IP characterization point; not a board/SoC timing signoff constraint.
create_clock -name pclk -period 10.0 [get_ports pclk]
set_clock_uncertainty 0.2 [get_clocks pclk]
set_input_delay -clock pclk 2.0 [remove_from_collection [all_inputs] [get_ports {pclk preset_ni}]]
set_output_delay -clock pclk 2.0 [all_outputs]
set_input_transition 0.1 [remove_from_collection [all_inputs] [get_ports pclk]]
set_load 0.01 [all_outputs]
# Reset deassertion is synchronous by the integration contract; RDC proof remains separate.
set_false_path -from [get_ports preset_ni]
