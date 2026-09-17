# PQC accelerator - provisional characterization constraints (28nm signoff sweep).
#
# These are characterization budgets used to produce achievable area/timing
# numbers for the current configuration. They are NOT a final SoC timing
# contract: the integrator must replace the clock period, the I/O delays and the
# interconnect load with the values of the real SoC floorplan before signoff.
#
# Clocking model (see model/clock_domains.yaml, HLD.DOM.CLK.PQC.CORE): the core
# is a single-clock IP. CDC between the core and the SoC APB/AXI domains is the
# integrator's responsibility and is not characterized here.

create_clock -name CLK_CORE -period 10 [get_ports clk]
set_clock_uncertainty 0.10 [get_clocks CLK_CORE]
set_clock_transition 0.10 [get_clocks CLK_CORE]

# Asynchronous reset / sideband inputs are released synchronously by the SoC and
# are not timed against the core clock.
set_false_path -from [get_ports {rst_n lifecycle_strap tamper_in zeroize_req_in privileged debug_unlocked}]
set_false_path -from [get_ports {fault_inject_ecc_ue fault_inject_ctrl}]

# Entropy source handshake: behaves as an asynchronous producer.
set_false_path -from [get_ports {entropy_valid entropy_data entropy_health_ok entropy_domain_tag}]
set_false_path -to [get_ports entropy_ready]

# Key Manager sideload channel: trusted, already synchronized at the SoC level.
set_false_path -from [get_ports {km_begin km_handle km_algo km_pset km_usage km_bytes km_valid km_data km_last km_revoke}]
set_false_path -to [get_ports {km_begin_ready km_ready km_done km_error}]

# APB4 control interface.
set pqc_apb_inputs [remove_from_collection [all_inputs] [get_ports {clk rst_n}]]
set_input_delay -clock CLK_CORE 1.0 [get_ports {s_apb_psel s_apb_penable s_apb_pwrite s_apb_pprot s_apb_paddr s_apb_pwdata s_apb_pstrb}]
set_output_delay -clock CLK_CORE 1.0 [get_ports {s_apb_pready s_apb_prdata s_apb_pslverr}]
set_output_delay -clock CLK_CORE 1.0 [get_ports irq]

# AXI4 read/write master channel (DMA to SoC memory).
set_input_delay -clock CLK_CORE 1.0 [get_ports {m_ar_ready m_r_valid m_r_data m_r_resp m_r_last}]
set_input_delay -clock CLK_CORE 1.0 [get_ports {m_aw_ready m_w_ready m_b_valid m_b_resp}]
set_output_delay -clock CLK_CORE 1.0 [get_ports {m_ar_valid m_ar_addr m_ar_len m_ar_prot}]
set_output_delay -clock CLK_CORE 1.0 [get_ports {m_r_ready}]
set_output_delay -clock CLK_CORE 1.0 [get_ports {m_aw_valid m_aw_addr m_aw_len m_aw_prot}]
set_output_delay -clock CLK_CORE 1.0 [get_ports {m_w_valid m_w_data m_w_strb m_w_last}]
set_output_delay -clock CLK_CORE 1.0 [get_ports {m_b_ready}]

# Illustrative output load only; the integrator must bind the real wire load.
set_load 0.05 [all_outputs]