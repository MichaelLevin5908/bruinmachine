# Basys 3 Deployment Guide

## Hardware Requirements
- **FPGA Board**: Digilent Basys 3 (XC7A35TCPG236C-1)
- **Audio Module**: Pmod AMP2 (optional, for sound feedback)
- **Software**: Xilinx Vivado 2023.2

## Hardware Setup

### Button Mapping
- **BTNC (Center)**: Reset
- **BTNU (Up)**: Insert $1 coin
- **BTNL (Left)**: Insert $2 coin
- **BTND (Down)**: Insert $5 coin
- **BTNR (Right)**: Purchase button

### Switch Mapping
- **SW0-SW1**: Item selection (00=Item0, 01=Item1, 10=Item2, 11=Item3)
- **SW15**: Restock inventory

### LED Indicators
- **LED0-LED3**: Item stock availability (1=in stock, 0=sold out)
- **LED4-LED7**: Change return amount / Animation / Error indicator
- **LED8-LED11**: Duplicate stock indicators for visibility

### 7-Segment Display
Shows current credit, item price, error messages ("Err"), or "done" confirmation.

### Audio Output (Optional)
Connect Pmod AMP2 to **JA header** (top row, pins 1-4):
- **JA1**: PWM audio output
- **JA3**: Shutdown control (active low)
- **GND/VCC**: Power rails

## Vivado Project Setup

### Option 1: Automated TCL Script
```bash
cd /path/to/bruinmachine
vivado -mode batch -source create_vivado_project.tcl
```

Then open the generated project:
```bash
vivado vivado_project/vending_machine.xpr
```

### Option 2: Manual Setup
1. **Create New Project**
   - Launch Vivado 2023.2
   - Create RTL Project
   - Select **xc7a35tcpg236-1** as target device

2. **Add Source Files**
   - Add all `.v` files from `src/` directory
   - Set `basys3_vending_machine.v` as top module

3. **Add Constraints**
   - Add `constraints/basys3.xdc`

4. **Synthesis & Implementation**
   - Run Synthesis
   - Run Implementation
   - Generate Bitstream

5. **Program Device**
   - Connect Basys 3 via USB
   - Open Hardware Manager
   - Program device with generated `.bit` file

## Item Pricing
Default prices (with dynamic pricing):
- **Item 0**: $3 (normal) / $4 (low stock ≤2)
- **Item 1**: $4 (normal) / $5 (low stock ≤2)
- **Item 2**: $6 (normal) / $7 (low stock ≤2)
- **Item 3**: $7 (normal) / $8 (low stock ≤2)

Initial stock: 5 units per item

## Operation

### Making a Purchase
1. Insert coins using BTNU/BTNL/BTND buttons
2. Watch credit accumulate on 7-segment display
3. Select item using SW0-SW1
4. Press BTNR (purchase) to complete transaction
5. Watch for:
   - Success: "done" displayed, audio tone plays, change shown
   - Error: "Err" displayed, LEDs blink, error tone plays

### Error Conditions
- **Insufficient funds**: Credit < item price
- **Out of stock**: Selected item has 0 inventory
- **Overcharge protection**: Cannot add coins beyond $15

### Restocking
Toggle SW15 to reset all inventory to maximum (5 units each)

## Sound Feedback
Different tones indicate different items:
- **Item 0**: 800 Hz
- **Item 1**: 1000 Hz
- **Item 2**: 1200 Hz
- **Item 3**: 1400 Hz
- **Error**: 300 Hz (low buzz)

## Timing Specifications
- **Clock**: 100 MHz system clock
- **Button Debounce**: 25 ms
- **7-Segment Refresh**: 1 kHz (per digit)
- **Sound Duration**: 150 ms

## Resource Utilization (Estimated)
- **LUTs**: < 500 (< 2% of XC7A35T)
- **FFs**: < 300 (< 1% of XC7A35T)
- **Block RAM**: 0
- **DSPs**: 0

## Troubleshooting

### Display Shows Garbage
- Check that `basys3_vending_machine.v` is set as top module
- Verify constraints file is properly loaded

### Buttons Don't Respond
- Check button debounce is enabled (DEBOUNCE_MAX = 2_500_000)
- Verify button pin constraints in XDC file

### No Audio Output
- Ensure Pmod AMP2 is connected to JA header
- Check aud_sd is high (amplifier enabled)
- Verify audio jumper on Pmod AMP2 is set correctly

### LEDs Not Working
- Check LED pin constraints match Basys 3 schematic
- Verify LED indices in wrapper module

## Files Overview
- `basys3_vending_machine.v`: Top-level Basys 3 wrapper
- `seg7_display.v`: 7-segment display controller with multiplexing
- `vending_machine_top.v`: Core vending machine logic
- `constraints/basys3.xdc`: Pin constraints for Basys 3
- `create_vivado_project.tcl`: Automated project setup script
