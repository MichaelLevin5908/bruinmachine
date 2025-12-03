# Troubleshooting Guide for Bruin Machine

This guide addresses common errors and issues when building the vending machine controller in Vivado.

## Table of Contents
1. [Synthesis Errors](#synthesis-errors)
2. [Implementation Errors](#implementation-errors)
3. [Simulation Errors](#simulation-errors)
4. [Constraint Errors](#constraint-errors)
5. [Programming Errors](#programming-errors)

## Synthesis Errors

### Error: [Place 30-494] The design is empty

**Symptom**:
```
[Place 30-494] The design is empty
Resolution: Check if opt_design has removed all the top level ports
```

**Root Causes**:
1. No top module is set in the project
2. All source files were not added to the project
3. Logic was completely optimized away
4. Top module has syntax errors preventing elaboration

**Solutions**:

**Solution 1: Verify Top Module**
```tcl
# In Vivado TCL console
set_property top vending_machine_top [current_fileset]
update_compile_order -fileset sources_1
```

**Solution 2: Check All Source Files Are Added**
1. Open the Sources window
2. Expand "Design Sources"
3. Verify all these files are present:
   - vending_machine_top.v (should have a chip icon indicating it's the top)
   - fsm_controller.v
   - coin_handler.v
   - inventory.v
   - price_lookup.v
   - change_calc.v
   - display_driver.v
   - seg7_mux.v
   - bcd_to_7seg.v
   - led_feedback.v
   - sound_module.v
   - debounce.v

**Solution 3: Reset Synthesis**
```tcl
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
```

**Solution 4: Check for Syntax Errors**
1. Open each source file in the Vivado editor
2. Look for red error markers
3. Fix any syntax errors before running synthesis

### Error: Inferred Latches

**Symptom**:
```
[Synth 8-327] inferring latch for variable 'variable_name'
```

**Cause**: Incomplete combinational logic (missing else clauses or case defaults)

**Solution**:
This design should not have latches. If you see this warning:
1. Check all `always @(*)` blocks have complete assignments
2. Ensure all `case` statements have `default` clauses
3. Verify all `if-else` chains are complete

### Warning: Multi-driven nets

**Symptom**:
```
[Synth 8-3352] multi-driven net on pin X
```

**Cause**: Multiple modules or logic blocks driving the same signal

**Solution**:
1. Review the module instantiations
2. Ensure no signal is assigned in multiple places
3. Check for accidental duplicate wire assignments

## Implementation Errors

### Error: [Vivado 12-4473] Detected error while running simulation

**Symptom**:
```
[Vivado 12-4473] Detected error while running simulation. Please correct the issue and retry this operation.
```

**Root Causes**:
1. Syntax errors in testbench
2. Missing simulation files
3. Uninitialized signals in testbench
4. Simulation timeout

**Solutions**:

**Solution 1: Check Testbench Syntax**
```tcl
# Verify testbench compiles
check_syntax -fileset sim_1
```

**Solution 2: Run Behavioral Simulation First**
1. In Flow Navigator, click "Run Simulation" > "Run Behavioral Simulation"
2. Review the TCL console for specific error messages
3. Fix any errors reported
4. Close the simulation

**Solution 3: Verify Simulation Settings**
```tcl
# Set simulation runtime
set_property -name {xsim.simulate.runtime} -value {1000us} -objects [get_filesets sim_1]
```

### Error: [Common 17-180] Spawn failed. No error

**Symptom**:
```
[Common 17-180] Spawn failed. No error (6 more like this)
```

**Root Causes**:
1. Insufficient permissions in project directory
2. Path contains special characters or spaces
3. Antivirus software blocking Vivado processes
4. Corrupted Vivado installation

**Solutions**:

**Solution 1: Check Directory Permissions**
- Ensure you have read/write access to the project directory
- On Windows: Right-click folder > Properties > Security
- On Linux: `chmod -R u+rw /path/to/project`

**Solution 2: Fix Project Path**
- Move project to a path without spaces or special characters
- Recommended: `C:/FPGA/vending_machine` or `/home/user/vending_machine`
- Avoid: `C:/My Documents/FPGA Project/vending machine`

**Solution 3: Run as Administrator (Windows)**
- Right-click Vivado icon > "Run as administrator"

**Solution 4: Disable Antivirus Temporarily**
- Add Vivado installation folder to antivirus exceptions
- Temporarily disable real-time scanning during synthesis

**Solution 5: Reset Runs**
```tcl
reset_run synth_1
reset_run impl_1
launch_runs synth_1 -jobs 4
```

### Error: Timing Constraints Not Met

**Symptom**:
```
[Timing 38-282] The design failed to meet the timing requirements.
WNS: -0.234ns (negative slack)
```

**Cause**: Design doesn't meet the 100 MHz clock constraint

**Solutions**:

**Solution 1: Reduce Clock Frequency**
Edit `basys3.xdc` line 6:
```tcl
# Change from 10ns (100 MHz) to 20ns (50 MHz)
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports clk]
```

**Solution 2: Use Different Implementation Strategy**
```tcl
set_property strategy Performance_Explore [get_runs impl_1]
reset_run impl_1
launch_runs impl_1 -jobs 4
```

**Solution 3: Enable Physical Optimization**
```tcl
set_property STEPS.PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
```

## Simulation Errors

### Error: Cannot find testbench top module

**Symptom**:
```
ERROR: [VRFC 10-91] 'vending_machine_top_tb' is not compiled
```

**Solution**:
```tcl
# Add testbench to simulation sources
add_files -fileset sim_1 -norecurse src/vending_machine_top_tb.v
set_property top vending_machine_top_tb [get_filesets sim_1]
update_compile_order -fileset sim_1
```

### Error: Undefined module in testbench

**Symptom**:
```
ERROR: [VRFC 10-2989] 'vending_machine_top' is not declared
```

**Cause**: Design sources not visible to simulation

**Solution**:
```tcl
# Ensure design sources are included in simulation
set_property source_mgmt_mode All [current_project]
update_compile_order -fileset sim_1
```

### Warning: Signal 'X' is read before being written

**Symptom**:
```
WARNING: [XSIM 43-3404] Signal 'signal_name' may be read before being written
```

**Solution**: Initialize all signals in testbench:
```verilog
initial begin
    clk = 0;
    rst = 1;
    btn_coin1 = 0;
    btn_coin2 = 0;
    btn_coin5 = 0;
    btn_purchase = 0;
    sw_item = 2'b00;
    restock = 0;

    // Release reset after 100ns
    #100 rst = 0;
end
```

## Constraint Errors

### Error: [Vivado 12-4739] create_clock: No valid object(s) found

**Symptom**:
```
[Vivado 12-4739] create_clock:No valid object(s) found for '-objects [get_ports clk]'
```

**Root Causes**:
1. Port name mismatch between XDC and Verilog
2. Constraint file loaded before elaboration
3. Clock port not defined in top module

**Solutions**:

**Solution 1: Verify Port Name**
Check that `basys3.xdc` line 6 matches the top module:
```verilog
// In vending_machine_top.v
module vending_machine_top (
    input wire clk,  // Must match XDC exactly
    ...
);
```

**Solution 2: Check XDC Syntax**
Ensure line 5 comes before line 6 in `basys3.xdc`:
```tcl
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
```

**Solution 3: Use create_clock After Synthesis**
If the error persists, the constraint might be running too early. This usually resolves after synthesis completes.

### Error: [Common 17-55] 'set_property' expects at least one object

**Symptom**:
```
[Common 17-55] 'set_property' expects at least one object [basys3.xdc:5]
```

**Cause**: Port referenced in XDC doesn't exist in the design

**Solution**:
1. Compare port names in `basys3.xdc` with `vending_machine_top.v`
2. Check for typos
3. Ensure case matches exactly (Verilog is case-sensitive)
4. Verify bus widths match: `sw_item[1:0]` vs `sw_item[0:1]`

### Warning: Port 'X' has no load

**Symptom**:
```
[Synth 8-3331] design vending_machine_top has unconnected port audio_sd
```

**Cause**: Output port not used internally (this is normal for top-level outputs)

**Solution**: This is expected behavior for output ports. No action needed.

### No sound from Pmod AMP2 on Basys 3

**Symptom**: The design bitstream programs successfully, but the speaker connected through Pmod AMP2 is completely silent.

**Cause**: Earlier constraint files accidentally swapped the AMP2 pins: the square-wave audio output was wired to JA1 (the amplifier's `!SHUTDOWN` pin), while the constant enable signal was tied to JA3 (the `AIN` audio input). That mapping continually toggled the shutdown line and held the actual audio input at a DC level, so the amplifier never reproduced the tone.

**Solution**:
1. Verify the XDC maps `audio_out` to JA3 (`PACKAGE_PIN J2`) and `audio_sd` to JA1 (`PACKAGE_PIN J1`).
2. Ensure `audio_sd` is tied high in `vending_machine_top.v` so the amplifier is enabled, and keep `audio_gain` low for 6dB gain.
3. Re-run synthesis/implementation and reprogram the bitstream; the tone generator in `sound_module.v` will then drive the correct AMP2 input.

## Programming Errors

### Error: Board not detected

**Symptom**: Hardware Manager shows "No hardware target is open"

**Solutions**:

**Solution 1: Install Cable Drivers**
```bash
# Linux
cd /tools/Xilinx/Vivado/2023.2/data/xicom/cable_drivers/lin64/install_script/install_drivers
sudo ./install_drivers

# Windows
# Run Vivado as Administrator, drivers install automatically
```

**Solution 2: Check USB Connection**
1. Ensure board is powered on
2. Try a different USB cable
3. Try a different USB port
4. Check Device Manager (Windows) or `lsusb` (Linux) for Xilinx device

**Solution 3: Manually Add Hardware Target**
```tcl
open_hw_manager
connect_hw_server -url localhost:3121
open_hw_target
```

### Error: Bitstream file not found

**Symptom**:
```
ERROR: [Common 17-55] 'get_hw_devices' expects at least one object.
```

**Cause**: Bitstream wasn't generated

**Solution**:
```tcl
# Generate bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
```

### Error: FPGA programming failed

**Symptom**: "Programming failed. Verify cable and board power."

**Solutions**:
1. Power cycle the board
2. Unplug and replug the USB cable
3. Close and reopen Hardware Manager
4. Try programming in batch mode:
```tcl
open_hw_manager
open_hw_target
set_property PROGRAM.FILE {./vivado_project/vending_machine.runs/impl_1/vending_machine_top.bit} [get_hw_devices xc7a35t_0]
program_hw_devices [get_hw_devices xc7a35t_0]
```

## Preventive Measures

### Best Practices to Avoid Errors

1. **Always start fresh when troubleshooting:**
   ```tcl
   reset_run synth_1
   reset_run impl_1
   ```

2. **Check syntax before synthesis:**
   ```tcl
   check_syntax [current_fileset]
   ```

3. **Review messages after each step:**
   - Expand the Messages tab
   - Filter by severity (Errors, Critical Warnings)
   - Address issues before proceeding

4. **Use version control:**
   ```bash
   git commit -m "Working version before changes"
   ```

5. **Keep backups of working bitstreams:**
   ```bash
   cp vending_machine_top.bit vending_machine_top_backup_$(date +%Y%m%d).bit
   ```

6. **Run synthesis in Out-of-Context mode first:**
   ```tcl
   synth_design -top vending_machine_top -mode out_of_context
   ```

## Getting More Help

If you're still encountering issues:

1. **Check Vivado Log Files:**
   - `vivado.log` in the project directory
   - `runme.log` in each run directory

2. **Enable Detailed Messaging:**
   ```tcl
   set_msg_config -severity INFO -new_severity ERROR
   ```

3. **Export Debug Files:**
   ```tcl
   write_checkpoint -force debug_checkpoint.dcp
   ```

4. **Xilinx Support:**
   - [Xilinx Answer Database](https://support.xilinx.com/s/)
   - Search for specific error codes (e.g., "Vivado 12-4473")

5. **Community Forums:**
   - Xilinx Community Forums
   - Stack Overflow (tag: vivado, fpga)
   - Reddit: r/FPGA

## Quick Reference: Common Commands

```tcl
# Project management
open_project ./vivado_project/vending_machine.xpr
close_project

# Reset runs
reset_run synth_1
reset_run impl_1

# Run synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Run implementation
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# Generate bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# Open GUI
start_gui

# Program device
open_hw_manager
open_hw_target
set_property PROGRAM.FILE {./vivado_project/vending_machine.runs/impl_1/vending_machine_top.bit} [get_hw_devices xc7a35t_0]
program_hw_devices [get_hw_devices xc7a35t_0]
refresh_hw_device [get_hw_devices xc7a35t_0]
```

## Error Code Reference

| Error Code | Description | Quick Fix |
|------------|-------------|-----------|
| VRFC 10-91 | Module not compiled | Check file is added to project |
| Synth 8-327 | Inferred latch | Add complete if-else or default case |
| Place 30-494 | Design is empty | Verify top module and sources |
| Timing 38-282 | Timing not met | Reduce clock frequency |
| Common 17-55 | Property expects object | Fix port name in XDC |
| Common 17-180 | Spawn failed | Check permissions/path |
| Vivado 12-4473 | Simulation error | Fix testbench syntax |
| Vivado 12-4739 | create_clock failed | Check clock port name |

Remember: Most errors are resolved by ensuring all source files are added, the top module is set correctly, and the constraints match the actual port names in your design!
