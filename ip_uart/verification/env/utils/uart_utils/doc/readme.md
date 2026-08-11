# XX Interface Agent

## Overview

This directory contains the XX interface agent template for UVM verification.

## Files

| File | Description |
|------|-------------|
| src/uart_dec.sv | Protocol definitions and constants |
| src/uart_interface.sv | Virtual interface definition |
| src/uart_xaction.sv | Transaction class |
| src/uart_driver_cfg.sv | Driver configuration |
| src/uart_driver.sv | Master driver |
| src/uart_slave_driver_cfg.sv | Slave driver configuration |
| src/uart_slave_driver.sv | Slave driver |
| src/uart_monitor_cfg.sv | Monitor configuration |
| src/uart_monitor.sv | Monitor |
| src/uart_monitor_cov.sv | Monitor coverage |
| src/uart_sequencer.sv | Sequencer |
| src/uart_interface_agent_cfg.sv | Agent configuration |
| src/uart_interface_agent.sv | Agent top |
| src/uart_sequence_library.svp | Sequence library |
| src/uart_package.sv | Package file |

## Usage

Replace `xx` with your protocol name (e.g., `apb`, `axi`, `irq`).
