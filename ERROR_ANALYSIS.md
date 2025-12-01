# Vivado Error Analysis - Vending Machine Controller

## Date: 2025-12-01

## Error Summary

The Vivado project is showing 31 errors and 70 critical warnings related to synthesis, implementation, and simulation failures.

## Root Cause

**The testbench (`vending_machine_top_tb`) is set as the top-level module for synthesis/implementation instead of the actual hardware design (`vending_machine_top`).**

## Detailed Error Analysis

### 1. Error: "The design is empty" (Place 30-494)

**Cause:** Testbenches contain simulation-only constructs that cannot be synthesized:
- `initial` blocks
- `reg` declarations for test stimulus
- `$display`, `$finish` system tasks
- `defparam` statements
- Tasks like `pulse_coin5()` and `check()`

When Vivado attempts to synthesize a testbench, it strips away all non-synthesizable code, resulting in an empty design.

**Location:** Place Design stage

**Resolution:** Set `vending_machine_top.v` as the top-level module for synthesis

### 2. Error: "create_clock: No valid object(s) found for '-objects [get_ports clk]'" (Vivado 12-4739)

**Cause:** The testbench does not have a `clk` input port. It generates the clock internally:
```verilog
// testbench code:
reg clk = 0;
always #5 clk = ~clk;
```

The constraint file (basys3.xdc) expects the actual hardware module which has:
```verilog
// vending_machine_top.v:
input wire clk
```

**Location:** Synthesis timing constraints

**Resolution:** Set `vending_machine_top.v` as the top-level module

### 3. Error: "Detected error while running simulation" (Vivado 12-4473)

**Cause:** Likely related to simulation configuration issues or missing files

**Location:** Behavioral simulation

**Resolution:** Verify all design files are included and testbench is in Simulation Sources

### 4. Error: "Command failed: Placer could not place all instances" (Common 17-69)

**Cause:** No instances to place because synthesis produced an empty design

**Location:** Implementation - Place Design

**Resolution:** Fix the root cause (wrong top-level module)

## Solution Steps

### Step 1: Set Correct Top-Level Module

**For Synthesis/Implementation:**
1. In Vivado Sources window, expand "Design Sources"
2. Right-click on **`vending_machine_top`** (not the testbench)
3. Select **"Set as Top"**
4. Verify the hierarchy icon appears next to `vending_machine_top`

**For Simulation:**
1. In Vivado Sources window, expand "Simulation Sources"
2. Right-click on **`vending_machine_top_tb`**
3. Select **"Set as Top"**
4. This should already be correct

### Step 2: Verify File Organization

**Design Sources** should contain:
- vending_machine_top.v (TOP)
- fsm_controller.v
- coin_handler.v
- inventory.v
- debounce.v
- seg7_mux.v
- bcd_to_7seg.v
- display_driver.v
- led_feedback.v
- price_lookup.v
- change_calc.v
- sound_module.v

**Simulation Sources** should contain:
- vending_machine_top_tb.v (TOP)

**Constraints** should contain:
- basys3.xdc

### Step 3: Reset and Rerun

1. **Reset Synthesis:**
   - Flow Navigator → Synthesis → Right-click "Run Synthesis" → Reset Runs

2. **Reset Implementation:**
   - Flow Navigator → Implementation → Right-click "Run Implementation" → Reset Runs

3. **Rerun Synthesis:**
   - Click "Run Synthesis"
   - Wait for completion
   - Check that no critical errors remain

4. **Rerun Implementation:**
   - Click "Run Implementation"
   - Verify successful completion

### Step 4: Verify Simulation Works

1. Flow Navigator → Simulation → Run Behavioral Simulation
2. The testbench should execute and show waveforms
3. Check TCL console for test results

## Important Concepts

### Testbench vs Hardware Design

| Aspect | Testbench | Hardware Design |
|--------|-----------|----------------|
| Purpose | Test the design | Implement on FPGA |
| File | `*_tb.v` | `*.v` (non-testbench) |
| Contains | Simulation code | Synthesizable code |
| Used for | Simulation only | Synthesis & Implementation |
| Top-level for | Behavioral Simulation | Synthesis, Implementation, Bitstream |

### Synthesizable vs Non-Synthesizable Code

**Non-Synthesizable (Testbench only):**
- `initial` blocks
- `#delay` statements
- `$display`, `$monitor`, `$finish`
- `defparam`
- Most procedural tasks for stimulus generation

**Synthesizable (Hardware design):**
- `always @(posedge clk)` blocks
- `always @(*)` combinational blocks
- `assign` statements
- Registers and wires
- Module instantiations with proper connectivity

## File Summary

All design files in your repository appear correct and synthesizable:

1. **vending_machine_top.v** (145 lines) - Top-level hardware module ✓
2. **fsm_controller.v** (100 lines) - State machine ✓
3. **coin_handler.v** (51 lines) - Coin pulse detection ✓
4. **inventory.v** (40 lines) - Stock tracking ✓
5. **debounce.v** (54 lines) - Button debouncing ✓
6. **seg7_mux.v** (62 lines) - 7-segment display driver ✓
7. **bcd_to_7seg.v** (25 lines) - BCD decoder ✓
8. **display_driver.v** (77 lines) - Display logic ✓
9. **led_feedback.v** (84 lines) - LED animations ✓
10. **price_lookup.v** (26 lines) - Price mapping ✓
11. **change_calc.v** (13 lines) - Change calculation ✓
12. **sound_module.v** (75 lines) - Audio feedback ✓
13. **basys3.xdc** (60 lines) - Pin constraints ✓
14. **vending_machine_top_tb.v** (116 lines) - Testbench ✓

All modules are properly coded and should synthesize successfully once the top-level is set correctly.

## Expected Results After Fix

After setting the correct top-level module:

1. **Synthesis:** Should complete with 0 critical errors
2. **Implementation:** Should place and route successfully
3. **Design:** Should use approximately 200-500 LUTs on Basys 3
4. **Timing:** Should meet timing at 100 MHz with positive slack
5. **Simulation:** Should pass all testbench checks

## Additional Notes

The constraint file (basys3.xdc) is properly configured for:
- 100 MHz clock input (W5 pin)
- All required buttons, switches, LEDs, and 7-segment displays
- Pmod AMP2 audio amplifier connections
- Proper I/O standards (LVCMOS33)

No modifications to source files are needed - this is purely a project configuration issue.
