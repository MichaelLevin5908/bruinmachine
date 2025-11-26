# Bruin Machine

FPGA-based vending machine controller project for UCLA CS M152A Lab 4. The design targets the Basys 3 board and demonstrates a multi-module FSM with debounced inputs, dynamic pricing, change handling, inventory management, 7-segment/LED output, and sound feedback via Pmod AMP2.

## Quick Start

### Option 1: Automated Build (Recommended)

The fastest way to build and program the FPGA:

```bash
cd bruinmachine
vivado -mode batch -source build.tcl
```

After the build completes, program the FPGA:

```bash
vivado -mode batch -source program_fpga.tcl
```

### Option 2: GUI Mode

1. Open Vivado 2023.2
2. In the Tcl Console, navigate to the project directory:
   ```tcl
   cd /path/to/bruinmachine
   source create_project.tcl
   ```
3. Use the Vivado GUI to run synthesis, implementation, and generate bitstream
4. Program the FPGA using Hardware Manager

### Option 3: Manual Setup

Follow the detailed step-by-step instructions in the [Implementation Guide](docs/VIVADO_IMPLEMENTATION_GUIDE.md).

## Documentation

### Getting Started
- **[Vivado Implementation Guide](docs/VIVADO_IMPLEMENTATION_GUIDE.md)** - Complete guide for building the project
- **[Troubleshooting Guide](docs/TROUBLESHOOTING.md)** - Solutions to common errors and issues
- [Project Proposal](docs/PROJECT_PROPOSAL.md) - Original project specification

### Build Scripts
- `create_project.tcl` - Automated project creation script
- `build.tcl` - Complete build automation (synthesis → implementation → bitstream)
- `program_fpga.tcl` - FPGA programming script

## Hardware Requirements

- Xilinx Basys 3 FPGA Board (xc7a35tcpg236-1)
- USB cable (Type A to Micro-B)
- Pmod AMP2 Audio Amplifier (optional, for sound feedback)

## Software Requirements

- Xilinx Vivado 2023.2 (or compatible version)
- Vivado Hardware Server (included with Vivado)

## Design Overview

The vending machine controller consists of the following modules:

- **vending_machine_top.v** - Top-level module integrating all components
- **fsm_controller.v** - Main finite state machine controlling operations
- **coin_handler.v** - Processes coin input signals and generates coin pulses
- **inventory.v** - Manages stock levels for each item
- **price_lookup.v** - Returns item prices based on selection and stock
- **change_calc.v** - Calculates change to return
- **display_driver.v** - Formats data for 7-segment display
- **seg7_mux.v** - Multiplexes 4-digit 7-segment display
- **bcd_to_7seg.v** - Converts BCD to 7-segment encoding
- **led_feedback.v** - Controls LED status indicators
- **sound_module.v** - Generates audio feedback tones
- **debounce.v** - Debounces button inputs

## Pin Mapping (Basys 3)

### Inputs
- **Clock**: W5 (100 MHz)
- **Reset**: Switch 3 (W17)
- **Restock**: Switch 2 (W16)
- **Item Select**: Switches 0-1 (V17, V16)
- **Coin Buttons**:
  - Center Button: Insert 1¢ (U18)
  - Down Button: Insert 2¢ (T18)
  - Left Button: Insert 5¢ (W19)
  - Right Button: Purchase (T17)

### Outputs
- **7-Segment Display**: Anodes (U2, U4, V4, W4), Cathodes (W7, W6, U8, V8, U5, V5, U7)
- **LEDs 0-7**: Status indicators (U16, E19, U19, V19, W18, U15, U14, V14)
- **LEDs 12-15**: Stock level (V13, V3, W3, U3)
- **Audio Output**: Pmod JA Pin 1 (J1)
- **Audio Enable**: Pmod JA Pin 3 (J2)

## Usage

### Operating the Vending Machine

1. **Select an item** using switches 0-1:
   - 00 = Chips (5¢)
   - 01 = Soda (10¢)
   - 10 = Candy (7¢)
   - 11 = Water (8¢)

2. **Insert coins** using the buttons:
   - Center: 1¢
   - Down: 2¢
   - Left: 5¢

3. **View credit** on the 7-segment display

4. **Press Purchase** button when you have sufficient credit

5. **Collect change** (displayed on 7-segment, returned automatically)

6. **Restock** items by flipping switch 2 on and off

7. **Reset** the machine by flipping switch 3 on and off

### Status Indicators

- **7-Segment Display**: Shows credit, item price, or change due
- **LEDs 0-7**: Visual feedback for state, errors, and dispensing
- **LEDs 12-15**: Stock level (binary count)
- **Audio** (if Pmod AMP2 connected): Plays tones for different events

## Testing

A comprehensive testbench is included:

```bash
cd bruinmachine
vivado -mode batch -source run_simulation.tcl
```

Or run behavioral simulation from Vivado GUI:
1. Flow Navigator → Simulation → Run Behavioral Simulation
2. View waveforms and console output
3. Verify all FSM states and transitions

## Troubleshooting

Encountering errors? Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md) for solutions to:
- Synthesis errors
- Implementation failures
- Timing violations
- Programming issues
- Common warnings

## Project Structure

```
bruinmachine/
├── src/                          # Verilog source files
│   ├── vending_machine_top.v           # Top-level module
│   ├── fsm_controller.v                # State machine
│   ├── coin_handler.v                  # Coin processing
│   ├── inventory.v                     # Stock management
│   ├── price_lookup.v                  # Pricing logic
│   ├── change_calc.v                   # Change calculation
│   ├── display_driver.v                # Display formatting
│   ├── seg7_mux.v                      # 7-segment multiplexer
│   ├── bcd_to_7seg.v                   # BCD decoder
│   ├── led_feedback.v                  # LED control
│   ├── sound_module.v                  # Audio generation
│   ├── debounce.v                      # Button debouncer
│   └── vending_machine_top_tb.v        # Testbench
├── basys3.xdc                    # Constraints file
├── create_project.tcl            # Project creation script
├── build.tcl                     # Complete build script
├── program_fpga.tcl              # FPGA programming script
├── docs/                         # Documentation
│   ├── VIVADO_IMPLEMENTATION_GUIDE.md  # Build instructions
│   ├── TROUBLESHOOTING.md              # Error solutions
│   └── PROJECT_PROPOSAL.md             # Original proposal
└── README.md                     # This file
```

## Contributing

This is a course project for UCLA CS M152A. Contributions, bug reports, and suggestions are welcome!

## License

This project is created for educational purposes as part of UCLA CS M152A Lab 4.

## Authors

Created for UCLA CS M152A - Introduction to Digital Systems

## Acknowledgments

- UCLA CS M152A course staff
- Digilent for Basys 3 board documentation
- Xilinx for Vivado Design Suite
