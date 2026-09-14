# XX Interface Agent

## Overview

This directory contains the XX interface agent template for UVM verification.

## Files

| File | Description |
|------|-------------|
| src/apb_dec.sv | Protocol definitions and constants |
| src/apb_interface.sv | Virtual interface definition |
| src/apb_xaction.sv | Transaction class |
| src/apb_driver_cfg.sv | Driver configuration |
| src/apb_driver.sv | Master driver |
| src/apb_slave_driver_cfg.sv | Slave driver configuration |
| src/apb_slave_driver.sv | Slave driver |
| src/apb_monitor_cfg.sv | Monitor configuration |
| src/apb_monitor.sv | Monitor |
| src/apb_monitor_cov.sv | Monitor coverage |
| src/apb_sequencer.sv | Sequencer |
| src/apb_interface_agent_cfg.sv | Agent configuration |
| src/apb_interface_agent.sv | Agent top |
| src/apb_sequence_library.svp | Sequence library |
| src/apb_package.sv | Package file |

## Usage

Replace `xx` with your protocol name (e.g., `apb`, `axi`, `irq`).
