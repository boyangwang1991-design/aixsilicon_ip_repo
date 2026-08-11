# XX Interface Agent

## Overview

This directory contains the XX interface agent template for UVM verification.

## Files

| File | Description |
|------|-------------|
| src/tlul_dec.sv | Protocol definitions and constants |
| src/tlul_interface.sv | Virtual interface definition |
| src/tlul_xaction.sv | Transaction class |
| src/tlul_driver_cfg.sv | Driver configuration |
| src/tlul_driver.sv | Master driver |
| src/tlul_slave_driver_cfg.sv | Slave driver configuration |
| src/tlul_slave_driver.sv | Slave driver |
| src/tlul_monitor_cfg.sv | Monitor configuration |
| src/tlul_monitor.sv | Monitor |
| src/tlul_monitor_cov.sv | Monitor coverage |
| src/tlul_sequencer.sv | Sequencer |
| src/tlul_interface_agent_cfg.sv | Agent configuration |
| src/tlul_interface_agent.sv | Agent top |
| src/tlul_sequence_library.svp | Sequence library |
| src/tlul_package.sv | Package file |

## Usage

Replace `xx` with your protocol name (e.g., `apb`, `axi`, `irq`).
