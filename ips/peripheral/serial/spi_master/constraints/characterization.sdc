# Characterization assumptions, NOT a board/Pad signoff specification.
# PCLK 100 MHz; APB input/output budget 2 ns; external MISO return budget 3 ns.
create_clock -name pclk -period 10.0 [get_ports pclk]
set_clock_uncertainty 0.10 [get_clocks pclk]
set_input_delay -max 2.0 -clock pclk [remove_from_collection [all_inputs] [get_ports {pclk preset_n spi_miso_i}]]
set_input_delay -min 0.2 -clock pclk [remove_from_collection [all_inputs] [get_ports {pclk preset_n spi_miso_i}]]
set_input_delay -max 3.0 -clock pclk [get_ports spi_miso_i]
set_input_delay -min 0.2 -clock pclk [get_ports spi_miso_i]
set_output_delay -max 2.0 -clock pclk [all_outputs]
set_output_delay -min 0.2 -clock pclk [all_outputs]
set_load 0.02 [all_outputs]
set_false_path -from [get_ports preset_n]
# Never set a false path on spi_miso_i. The production integrator must replace the
# PCLK-referenced return budget with the selected slave, Pad and board delays.
