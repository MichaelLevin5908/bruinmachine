# Bruin Machine

FPGA-based vending machine controller project for UCLA CS M152A Lab 4. The design targets the Basys 3 board and demonstrates a multi-module FSM with debounced inputs, dynamic pricing, change handling, inventory management, 7-segment/LED output, and sound feedback via Pmod AMP2.

## Documentation
- [Project Proposal](docs/PROJECT_PROPOSAL.md)
- [Basys 3 Deployment Guide](docs/BASYS3_DEPLOYMENT.md)
- [Testbench Documentation](docs/testbench.md)

## Quick Start

### Simulation
```bash
cd src
iverilog -g2005-sv -o vending_machine_top_tb.vvp vending_machine_top_tb.v *.v
vvp vending_machine_top_tb.vvp
```

### Hardware Deployment (Vivado 2023.2)
```bash
vivado -mode batch -source create_vivado_project.tcl
vivado vivado_project/vending_machine.xpr
```

See [Basys 3 Deployment Guide](docs/BASYS3_DEPLOYMENT.md) for detailed instructions.
