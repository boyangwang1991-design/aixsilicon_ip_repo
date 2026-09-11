# Characterization assumptions only: pclk 100 MHz, wdt_clk 50 MHz.
# Override for integration. No actual silicon frequency is claimed.
create_clock -name pclk -period 10 [get_ports pclk]
create_clock -name wdt_clk -period 20 [get_ports wdt_clk]
set_clock_groups -asynchronous -group pclk -group wdt_clk
set_false_path -from [get_ports {por_n preset_n}]
# Integration must constrain bundled mailbox/reply data propagation to less than
# one destination period and audit reconvergence. Clock-groups alone is not CDC signoff.
