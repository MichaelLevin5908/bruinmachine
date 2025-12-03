# Quick Reference Card - Bruin Machine

A quick reference for common tasks and commands.

## Quick Start Commands

### Automated Build (One Command)
```bash
vivado -mode batch -source build.tcl
```

### Program FPGA (One Command)
```bash
vivado -mode batch -source program_fpga.tcl
```

### Create Project Only
```bash
vivado -mode batch -source create_project.tcl
```

## Vivado TCL Commands

### Project Management
```tcl
# Create project
source create_project.tcl

# Open existing project
open_project ./vivado_project/vending_machine.xpr

# Close project
close_project

# Launch GUI
start_gui
```

### Synthesis
```tcl
# Reset synthesis
reset_run synth_1

# Run synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check synthesis status
get_property STATUS [get_runs synth_1]

# Open synthesized design
open_run synth_1
```

### Implementation
```tcl
# Reset implementation
reset_run impl_1

# Run implementation
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# Check implementation status
get_property STATUS [get_runs impl_1]

# Open implemented design
open_run impl_1
```

### Bitstream Generation
```tcl
# Generate bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# Bitstream location
./vivado_project/vending_machine.runs/impl_1/vending_machine_top.bit
```

### Programming
```tcl
# Open hardware manager
open_hw_manager

# Connect to board
open_hw_target

# Set bitstream file
set_property PROGRAM.FILE {./vivado_project/vending_machine.runs/impl_1/vending_machine_top.bit} [get_hw_devices xc7a35t_0]

# Program FPGA
program_hw_devices [get_hw_devices xc7a35t_0]

# Refresh device
refresh_hw_device [get_hw_devices xc7a35t_0]
```

### Simulation
```tcl
# Run behavioral simulation
launch_simulation

# Run simulation for specific time
run 1000us

# Close simulation
close_sim
```

### Reports
```tcl
# Utilization report
report_utilization -file utilization.txt

# Timing report
report_timing_summary -file timing.txt

# Power report
report_power -file power.txt

# DRC report
report_drc -file drc.txt
```

## Hardware Pin Mapping

### Basys 3 Board Connections

| Function | Component | Pin | Port Name |
|----------|-----------|-----|-----------|
| **Clock** | | | |
| System Clock (100MHz) | Built-in | W5 | clk |
| **Switches** | | | |
| Item Select [0] | SW0 | V17 | sw_item[0] |
| Item Select [1] | SW1 | V16 | sw_item[1] |
| Restock | SW2 | W16 | restock |
| Reset | SW3 | W17 | rst |
| **Buttons** | | | |
| Insert 1¢ | BTNC | U18 | btn_coin1 |
| Insert 2¢ | BTND | T18 | btn_coin2 |
| Insert 5¢ | BTNL | W19 | btn_coin5 |
| Purchase | BTNR | T17 | btn_purchase |
| **LEDs (Status)** | | | |
| Status LED 0 | LED0 | U16 | leds[0] |
| Status LED 1 | LED1 | E19 | leds[1] |
| Status LED 2 | LED2 | U19 | leds[2] |
| Status LED 3 | LED3 | V19 | leds[3] |
| Status LED 4 | LED4 | W18 | leds[4] |
| Status LED 5 | LED5 | U15 | leds[5] |
| Status LED 6 | LED6 | U14 | leds[6] |
| Status LED 7 | LED7 | V14 | leds[7] |
| **LEDs (Stock)** | | | |
| Stock Level [0] | LED12 | V13 | stock_level[0] |
| Stock Level [1] | LED13 | V3 | stock_level[1] |
| Stock Level [2] | LED14 | W3 | stock_level[2] |
| Stock Level [3] | LED15 | U3 | stock_level[3] |
| **7-Segment Display** | | | |
| Anode 0 | AN0 | U2 | an[0] |
| Anode 1 | AN1 | U4 | an[1] |
| Anode 2 | AN2 | V4 | an[2] |
| Anode 3 | AN3 | W4 | an[3] |
| Segment A | CA | W7 | seg[0] |
| Segment B | CB | W6 | seg[1] |
| Segment C | CC | U8 | seg[2] |
| Segment D | CD | V8 | seg[3] |
| Segment E | CE | U5 | seg[4] |
| Segment F | CF | V5 | seg[5] |
| Segment G | CG | U7 | seg[6] |
| **Audio (Pmod JA)** | | | |
| Audio Out | JA3 | J2 | audio_out |
| Shutdown (Enable) | JA1 | J1 | audio_sd |
| Gain Select | JA2 | L2 | audio_gain |

## Item Codes and Prices

| Item | Code (sw_item) | Price |
|------|----------------|-------|
| Chips | 00 | 5¢ |
| Soda | 01 | 10¢ |
| Candy | 10 | 7¢ |
| Water | 11 | 8¢ |

## Operation Workflow

### Normal Purchase
1. Set sw_item to select product (e.g., 00 for chips)
2. Insert coins using buttons until credit ≥ price
3. Press purchase button (BTNR)
4. Observe change returned on display
5. Watch LEDs for vending animation
6. Hear confirmation beep (if audio connected)

### Restock Items
1. Flip SW2 (restock) ON
2. Flip SW2 (restock) OFF
3. Stock resets to maximum (15 items)

### Reset System
1. Flip SW3 (rst) ON
2. Flip SW3 (rst) OFF
3. System returns to idle state
4. Credit cleared, inventory reset

## Common Error Solutions

| Error | Quick Fix |
|-------|-----------|
| Design is empty | `set_property top vending_machine_top [current_fileset]` |
| Spawn failed | Check directory permissions, move to simple path |
| Timing not met | Increase clock period in basys3.xdc line 6 |
| Board not detected | Reinstall cable drivers, check USB connection |
| create_clock error | Verify clock port name matches in .xdc and .v |

## File Locations

| File | Location |
|------|----------|
| Project file | `./vivado_project/vending_machine.xpr` |
| Bitstream | `./vivado_project/vending_machine.runs/impl_1/vending_machine_top.bit` |
| Synthesis log | `./vivado_project/vending_machine.runs/synth_1/runme.log` |
| Implementation log | `./vivado_project/vending_machine.runs/impl_1/runme.log` |
| Main Vivado log | `./vivado_project/vivado.log` |

## Build Times (Approximate)

| Step | Typical Duration |
|------|------------------|
| Synthesis | 2-5 minutes |
| Implementation | 3-7 minutes |
| Bitstream Generation | 1-2 minutes |
| Programming FPGA | 5-10 seconds |
| **Total Build** | **6-14 minutes** |

## Resource Utilization (Expected)

| Resource | Used | Total | Percentage |
|----------|------|-------|------------|
| LUTs | ~800 | 20,800 | ~4% |
| Flip-Flops | ~400 | 41,600 | ~1% |
| Block RAM | 0 | 50 | 0% |
| DSPs | 0 | 90 | 0% |
| I/O | 31 | 106 | ~29% |

## Design Parameters

| Parameter | Value | Location |
|-----------|-------|----------|
| Clock Frequency | 100 MHz | basys3.xdc:6 |
| Clock Period | 10 ns | basys3.xdc:6 |
| Debounce Time | 1 ms | vending_machine_top.v:4 |
| Max Credit | 255¢ | fsm_controller.v |
| Max Stock | 15 items | inventory.v |
| Display Refresh | ~1 kHz | seg7_mux.v |

## Useful Links

- [Implementation Guide](VIVADO_IMPLEMENTATION_GUIDE.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Project Proposal](PROJECT_PROPOSAL.md)
- [Basys 3 Reference](https://reference.digilentinc.com/basys3/refmanual)
- [Vivado Documentation](https://www.xilinx.com/support/documentation/sw_manuals/)

## Support

Having issues? Check:
1. [Troubleshooting Guide](TROUBLESHOOTING.md) - Common errors and solutions
2. Vivado Messages tab - Look for specific error codes
3. Log files in `./vivado_project/vending_machine.runs/`
4. Project repository issues page

---

**Quick Tip**: Bookmark this page for fast reference during development!
