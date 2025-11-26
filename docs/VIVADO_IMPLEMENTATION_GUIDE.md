# Vivado Implementation Guide for Bruin Machine

This guide provides step-by-step instructions to successfully build and deploy the vending machine controller on the Basys 3 FPGA board using Vivado 2023.2.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Method 1: Automated Setup (Recommended)](#method-1-automated-setup-recommended)
3. [Method 2: Manual Setup](#method-2-manual-setup)
4. [Running Synthesis and Implementation](#running-synthesis-and-implementation)
5. [Programming the FPGA](#programming-the-fpga)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

- Xilinx Vivado 2023.2 (or compatible version)
- Basys 3 FPGA board
- Pmod AMP2 audio amplifier module (optional, for sound)
- USB cable to connect Basys 3 to your computer

## Method 1: Automated Setup (Recommended)

The fastest way to set up your project is using the provided TCL script:

### Step 1: Open Vivado TCL Shell

1. Launch Vivado 2023.2
2. Click on **Window > Tcl Console** (if not already visible)
3. Navigate to the project directory:
   ```tcl
   cd /path/to/bruinmachine
   ```

### Step 2: Run the Setup Script

Execute the automated setup script:
```tcl
source create_project.tcl
```

This script will:
- Create a new Vivado project named `vending_machine`
- Set the target board to Basys 3 (xc7a35tcpg236-1)
- Add all Verilog source files from the `src/` directory
- Add the constraints file `basys3.xdc`
- Set `vending_machine_top.v` as the top module
- Configure project settings for synthesis and implementation

### Step 3: Proceed to Synthesis

Once the script completes, proceed to [Running Synthesis and Implementation](#running-synthesis-and-implementation).

## Method 2: Manual Setup

If you prefer to set up the project manually:

### Step 1: Create New Project

1. Launch Vivado 2023.2
2. Click **Create Project**
3. Click **Next**
4. Enter project name: `vending_machine`
5. Choose project location (parent directory of where you want the project)
6. Click **Next**
7. Select **RTL Project**
8. Check **Do not specify sources at this time**
9. Click **Next**

### Step 2: Select Target Board

1. In the **Default Part** dialog, click the **Boards** tab
2. Search for **Basys 3**
3. Select **Basys3** (xc7a35tcpg236-1)
4. Click **Next**, then **Finish**

### Step 3: Add Source Files

1. In the **Flow Navigator**, click **Add Sources** (or press Alt+A)
2. Select **Add or create design sources**, click **Next**
3. Click **Add Files**
4. Navigate to the `src/` directory
5. Select all `.v` files EXCEPT `vending_machine_top_tb.v`:
   - `vending_machine_top.v`
   - `bcd_to_7seg.v`
   - `change_calc.v`
   - `coin_handler.v`
   - `debounce.v`
   - `display_driver.v`
   - `fsm_controller.v`
   - `inventory.v`
   - `led_feedback.v`
   - `price_lookup.v`
   - `seg7_mux.v`
   - `sound_module.v`
6. Click **OK**, then **Finish**

### Step 4: Set Top Module

1. In the **Sources** window, find `vending_machine_top`
2. Right-click on `vending_machine_top.v`
3. Select **Set as Top**

### Step 5: Add Constraints File

1. In the **Flow Navigator**, click **Add Sources**
2. Select **Add or create constraints**, click **Next**
3. Click **Add Files**
4. Navigate to the project root directory
5. Select `basys3.xdc`
6. Click **OK**, then **Finish**

### Step 6: Add Simulation Sources (Optional)

If you want to run behavioral simulation:

1. In the **Flow Navigator**, click **Add Sources**
2. Select **Add or create simulation sources**, click **Next**
3. Click **Add Files**
4. Navigate to the `src/` directory
5. Select `vending_machine_top_tb.v`
6. Click **OK**, then **Finish**

## Running Synthesis and Implementation

### Step 1: Run Synthesis

1. In the **Flow Navigator**, click **Run Synthesis**
2. Wait for synthesis to complete (this may take several minutes)
3. When prompted, select **Open Synthesized Design** or click **Cancel** to proceed to implementation

### Step 2: Review Synthesis Reports

After synthesis completes, check for errors or critical warnings:

1. Expand **Synthesis** in the **Design Runs** tab
2. Review the **Messages** tab
3. Look for any critical warnings or errors

Common issues to check:
- Inferred latches (should be none for this design)
- Timing violations
- Incomplete sensitivity lists

### Step 3: Run Implementation

1. In the **Flow Navigator**, click **Run Implementation**
2. Wait for implementation to complete (this may take several minutes)
3. When prompted, select **Open Implemented Design** or click **Cancel** to proceed to bitstream generation

### Step 4: Review Implementation Reports

After implementation completes, check key reports:

1. **Utilization Report**: Verify resource usage is reasonable
   - LUTs, Flip-Flops, Block RAM, DSPs
2. **Timing Report**: Ensure all timing constraints are met
   - WNS (Worst Negative Slack) should be positive
   - WHS (Worst Hold Slack) should be positive

### Step 5: Generate Bitstream

1. In the **Flow Navigator**, click **Generate Bitstream**
2. Wait for bitstream generation to complete
3. Click **OK** when finished

## Programming the FPGA

### Step 1: Connect the Basys 3 Board

1. Connect the Basys 3 board to your computer via USB
2. Turn on the board using the power switch
3. Ensure the board is recognized by your computer

### Step 2: Open Hardware Manager

1. In the **Flow Navigator**, click **Open Hardware Manager**
2. Click **Open Target** > **Auto Connect**
3. Wait for Vivado to detect the Basys 3 board

### Step 3: Program the Device

1. Right-click on the FPGA device (xc7a35t_0)
2. Select **Program Device**
3. Verify the bitstream file path is correct:
   ```
   vending_machine.runs/impl_1/vending_machine_top.bit
   ```
4. Click **Program**
5. Wait for programming to complete

### Step 4: Test the Design

Once programmed:
1. The 7-segment display should show the initial state
2. Use switches to select items (sw_item[1:0])
3. Press buttons to insert coins (btn_coin1, btn_coin2, btn_coin5)
4. Press the purchase button to complete a transaction
5. Observe LEDs for status feedback
6. If Pmod AMP2 is connected, you should hear audio feedback

## Troubleshooting

### Error: "The design is empty"

**Cause**: No top-level module is set, or all logic was optimized away.

**Solution**:
1. Verify `vending_machine_top` is set as the top module
2. Check that all source files are added to the project
3. Ensure the constraints file is properly loaded

### Error: "create_clock: No valid object(s) found for '-objects [get_ports clk]'"

**Cause**: The clock constraint is referencing a port that doesn't exist or hasn't been elaborated yet.

**Solution**:
1. Verify the top module has a `clk` input port
2. Run synthesis before implementation
3. Check that the constraints file is in the correct constraint set

### Critical Warning: "set_property expects at least one object"

**Cause**: A constraint is referencing a port or net that doesn't exist in the design.

**Solution**:
1. Review the constraints file `basys3.xdc`
2. Ensure all port names match the top module exactly
3. Check for typos in port names

### Synthesis Failed: Spawn failed

**Cause**: Vivado couldn't launch synthesis process (usually permissions or path issues).

**Solution**:
1. Ensure you have write permissions in the project directory
2. Try running Vivado as administrator
3. Check that the project path doesn't contain special characters or spaces
4. Close and reopen Vivado

### Timing Violations

**Cause**: Design doesn't meet the 100 MHz clock constraint.

**Solution**:
1. Review the timing report to identify critical paths
2. Consider reducing the clock frequency in `basys3.xdc` (increase period)
3. Add pipeline stages to critical paths if needed

### Simulation Errors

**Cause**: Testbench issues or uninitialized signals.

**Solution**:
1. Verify `vending_machine_top_tb.v` is in the simulation sources
2. Check that all signals are properly initialized in the testbench
3. Review simulation log messages for specific errors

### Board Not Detected

**Cause**: USB drivers not installed or board not powered.

**Solution**:
1. Install Xilinx cable drivers
2. Ensure the board is powered on
3. Try a different USB port or cable
4. Check Device Manager (Windows) or lsusb (Linux) for the device

## Additional Resources

- [Basys 3 Reference Manual](https://reference.digilentinc.com/basys3/refmanual)
- [Vivado Design Suite User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2023_2/ug973-vivado-release-notes-install-license.pdf)
- [Pmod AMP2 Documentation](https://reference.digilentinc.com/reference/pmod/pmodamp2/start)

## Tips for Success

1. **Save Often**: Save your project frequently to avoid losing work
2. **Check Messages**: Always review synthesis and implementation messages
3. **Version Control**: Use git to track changes to your design
4. **Incremental Builds**: If making changes, use incremental synthesis when possible
5. **Backup Bitstreams**: Save working bitstreams before making significant changes
6. **Test in Simulation**: Use the testbench to verify functionality before programming hardware

## Project Structure

```
bruinmachine/
├── src/                      # Verilog source files
│   ├── vending_machine_top.v       # Top-level module
│   ├── fsm_controller.v            # Main FSM
│   ├── coin_handler.v              # Coin input processing
│   ├── inventory.v                 # Stock management
│   ├── price_lookup.v              # Pricing logic
│   ├── display_driver.v            # Display data formatting
│   ├── seg7_mux.v                  # 7-segment multiplexer
│   ├── bcd_to_7seg.v               # BCD to 7-segment decoder
│   ├── led_feedback.v              # LED status indicators
│   ├── sound_module.v              # Audio feedback
│   ├── debounce.v                  # Button debouncer
│   └── vending_machine_top_tb.v    # Testbench
├── basys3.xdc                # Constraints file
├── docs/                     # Documentation
└── README.md                 # Project overview
```

## Next Steps

After successfully programming the FPGA:
1. Test all features thoroughly
2. Document any issues or unexpected behavior
3. Consider enhancements or modifications
4. Share your results!

For questions or issues, refer to the project documentation or create an issue in the project repository.
