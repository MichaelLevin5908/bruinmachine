# Vending Machine Controller - Testing Guide

## Overview

This guide covers both **simulation testing** (using the testbench) and **hardware testing** (on the Basys 3 board).

---

## Part 1: Simulation Testing (In Vivado)

### Setup

1. **Ensure testbench is set as simulation top:**
   - Sources window → Simulation Sources
   - Right-click `vending_machine_top_tb` → "Set as Top"

2. **Launch Behavioral Simulation:**
   - Flow Navigator → Simulation → **Run Behavioral Simulation**
   - Wait for the simulator to compile and load

### What the Testbench Does

The testbench (`vending_machine_top_tb.v`) automatically tests two scenarios:

#### Scenario 1: Successful Purchase
- Inserts $5 coin
- Selects item 0 (costs $3)
- Presses purchase button
- **Expected results:**
  - Credit should reach $5
  - After purchase, credit drops to $2
  - Change due = $2
  - Inventory for item 0 decrements from 5 → 4

#### Scenario 2: Insufficient Funds Error
- With $2 remaining credit
- Selects item 2 (costs $6)
- Attempts purchase
- **Expected results:**
  - FSM enters ERROR state
  - Returns to IDLE state
  - Credit preserved at $2

### Viewing Simulation Results

#### In TCL Console:
Look for output messages like:
```
[OK] 500ns: Credit increments to $5 after coin insertion
[OK] 800ns: Vend pulse completed without sticking high
[OK] 850ns: Credit reduced to $2 after vend and change
All testbench checks passed.
```

If you see `[ERROR]` messages, the test failed.

#### In Waveform Viewer:

**Add key signals to watch:**

1. Click the **Scope** window, select `vending_machine_top_tb`
2. Drag these signals to the waveform:

**Top-level signals:**
```
clk
rst
btn_coin1, btn_coin2, btn_coin5
btn_purchase
sw_item[1:0]
```

**Internal DUT signals** (expand `dut`):
```
dut/state[2:0]
dut/credit[7:0]
dut/price[7:0]
dut/vend_pulse
dut/error_flag
dut/change_due[7:0]
dut/stock_level[3:0]
```

**Outputs:**
```
leds[7:0]
seg[6:0]
an[3:0]
audio_out
```

3. **Run the simulation:**
   - The testbench runs automatically and calls `$finish`
   - If it stops early, click **Run All** (F3)

4. **Zoom to fit:** Click the **Zoom Fit** button to see the entire waveform

### Interpreting Waveforms

**State transitions** (dut/state):
- 0 = IDLE
- 1 = CREDIT
- 2 = CHECK
- 3 = VEND
- 4 = CHANGE
- 5 = ERROR
- 6 = THANK

**Expected flow:**
```
IDLE → (coin inserted) → CREDIT → (purchase pressed) → CHECK → VEND → THANK → CHANGE → IDLE
```

### Customizing the Testbench

You can modify `vending_machine_top_tb.v` to test additional scenarios:

```verilog
// Add this before $finish; in the initial block:

$display("=== Scenario 3: Test multiple coins ===");
sw_item <= 2'd1;  // Select item 1 (price $4)
pulse_coin1();    // Insert $1
pulse_coin1();    // Insert $1
pulse_coin2();    // Insert $2
repeat (6) @(posedge clk);
check(dut.ctrl.credit == 8'd4, "Credit = $4 after multiple coins");
pulse_purchase();
repeat (8) @(posedge clk);
check(dut.ctrl.credit == 8'd0, "Exact change, credit = $0");
```

---

## Part 2: Hardware Testing (On Basys 3 Board)

### Prerequisites

1. **Generate bitstream:**
   - Flow Navigator → Program and Debug → **Generate Bitstream**
   - Wait for completion (may take 5-10 minutes)

2. **Connect hardware:**
   - Connect Basys 3 board to your computer via USB
   - Turn on the board (power switch)

3. **Program the FPGA:**
   - Flow Navigator → **Open Hardware Manager**
   - Click **Open Target** → Auto Connect
   - Click **Program Device** → Select your bitstream → Program

### Basys 3 Board Pin Mapping

#### Inputs

| Component | Basys 3 Location | Function |
|-----------|------------------|----------|
| **SW0** | Bottom-right switch | Item select bit 0 |
| **SW1** | Second from right | Item select bit 1 |
| **SW2** | Third from right | Restock button |
| **SW3** | Fourth from right | Reset (keep DOWN for normal operation) |
| **BTNU** | Center-top button | Insert $1 coin |
| **BTND** | Center-bottom button | Insert $2 coin |
| **BTNL** | Center-left button | Insert $5 coin |
| **BTNR** | Center-right button | Purchase button |

#### Item Selection (SW1, SW0)

| SW1 | SW0 | Item | Base Price |
|-----|-----|------|------------|
| 0 | 0 | Item 0 | $3 |
| 0 | 1 | Item 1 | $4 |
| 1 | 0 | Item 2 | $6 |
| 1 | 1 | Item 3 | $7 |

*Note: Price increases by $1 if stock ≤ 2*

#### Outputs

| Component | Function |
|-----------|----------|
| **LEDs 0-3** (rightmost) | Stock availability (1=available, 0=sold out) |
| **LEDs 4-7** | Animation/change display |
| **LEDs 12-15** (leftmost) | Stock level for selected item (binary) |
| **7-Segment Display** | Shows credit/price/change |
| **Pmod JA** (optional) | Audio output (requires Pmod AMP2) |

### Hardware Test Procedures

#### Test 1: Basic Purchase

1. **Reset the system:**
   - SW3 UP (reset) → wait → SW3 DOWN (run)
   - Display should show `000` (no credit)
   - LEDs 0-3 should all be lit (all items in stock)

2. **Select an item:**
   - SW1=0, SW0=0 (Item 0, $3)
   - Display may briefly flash the price

3. **Insert coins:**
   - Press **BTNL** ($5 coin)
   - Display should show `005` (credit = $5)

4. **Purchase:**
   - Press **BTNR** (purchase button)
   - **Expected behavior:**
     - Display briefly shows "Done"
     - LEDs 4-7 animate (spinning pattern)
     - Audio tone plays (if Pmod AMP2 connected)
     - Display shows `002` (change = $2)
     - LED 12 dims slightly (item 0 stock: 5→4)

#### Test 2: Insufficient Funds Error

1. **Start fresh:**
   - Reset (SW3 up/down)

2. **Insert insufficient funds:**
   - Select item 2 (SW1=1, SW0=0, price $6)
   - Press **BTNU** twice ($1 + $1 = $2)
   - Display shows `002`

3. **Attempt purchase:**
   - Press **BTNR**
   - **Expected behavior:**
     - Display briefly shows "Err"
     - LEDs 4-7 blink rapidly
     - Low-pitched error tone
     - Returns to showing credit `002`

#### Test 3: Multiple Coins

1. **Reset**

2. **Insert multiple coins:**
   - Select item 1 (SW1=0, SW0=1, price $4)
   - Press **BTNU** (insert $1) → display: `001`
   - Press **BTND** (insert $2) → display: `003`
   - Press **BTNU** (insert $1) → display: `004`

3. **Purchase:**
   - Press **BTNR**
   - **Expected:** Exact change, credit returns to `000`

#### Test 4: Inventory Depletion

1. **Select one item (e.g., item 3: SW1=1, SW0=1)**

2. **Purchase 5 times:**
   - Insert $7+ each time
   - Press purchase
   - Watch LED 15 count down: 5→4→3→2→1→0

3. **When stock reaches 0:**
   - LED 3 turns OFF (item 3 sold out)
   - Attempting to purchase shows error

4. **Restock:**
   - Flip SW2 UP (restock switch)
   - All LEDs 0-3 turn ON
   - All stock refilled to 5
   - Flip SW2 DOWN

#### Test 5: Low Stock Surcharge

1. **Deplete item 0 to 2 remaining:**
   - Purchase item 0 three times

2. **Check price:**
   - With item 0 selected, the price increases from $3 → $4
   - Verify by attempting to purchase with only $3 credit (should error)

#### Test 6: Credit Limit

1. **Try to exceed $15 credit:**
   - Insert $5 three times (total = $15) ✓
   - Insert $5 again
   - **Expected:** Error indication, credit stays at $15

### 7-Segment Display Meanings

| Display | Meaning |
|---------|---------|
| `000` - `015` | Current credit amount |
| `003` - `007` | Item price (shown briefly during purchase) |
| `Err` | Error (insufficient funds, sold out, or credit limit) |
| `donE` | Purchase successful ("Thank you") |
| `002` (after purchase) | Change amount |

### Audio Feedback (if Pmod AMP2 connected)

| Event | Tone |
|-------|------|
| Item 0 vend | 800 Hz |
| Item 1 vend | 1000 Hz |
| Item 2 vend | 1200 Hz |
| Item 3 vend | 1400 Hz |
| Error | 300 Hz (low buzz) |

All tones play for 150ms.

---

## Part 3: Advanced Testing

### Using ILA (Integrated Logic Analyzer)

For debugging on hardware without external equipment:

1. **Add ILA core in Vivado:**
   - Tools → Set up Debug
   - Select internal signals to monitor
   - Re-generate bitstream

2. **Useful signals to probe:**
   - `fsm_controller/state`
   - `fsm_controller/credit`
   - `coin_handler/coin_pulse`
   - `inventory/stock[0]`, `stock[1]`, etc.

### Stress Testing

1. **Rapid button presses:**
   - Test debounce circuit by rapidly pressing coin buttons
   - Should only register discrete coin insertions

2. **Multiple switches:**
   - Change item selection rapidly while purchasing
   - Verify no race conditions

3. **Edge cases:**
   - Purchase at exact credit amount
   - Switch items mid-transaction
   - Reset during vend operation

---

## Troubleshooting

### Simulation Issues

| Problem | Solution |
|---------|----------|
| Simulation doesn't start | Verify testbench is set as simulation top |
| "Unknown signals" in waveform | Re-elaborate design (right-click → Relaunch Simulation) |
| Testbench errors | Check TCL console for assertion failures |

### Hardware Issues

| Problem | Solution |
|---------|----------|
| Nothing happens after programming | Check SW3 is DOWN (not in reset) |
| Display shows random values | Verify bitstream programmed correctly |
| Buttons don't respond | Check debounce parameter (should be 25000 for hardware) |
| No audio | Ensure Pmod AMP2 connected to JA, verify audio_sd=1 |
| LEDs stuck | Reset the board (SW3 up, then down) |

---

## Expected Test Results

### Simulation
- **Runtime:** ~1-2 microseconds
- **All checks passed:** "All testbench checks passed."
- **No errors:** 0 errors reported

### Hardware (Basys 3)
- **Bitstream size:** ~5-15% of FPGA resources
- **Response time:** Instant (button debounce ~0.25ms)
- **Display refresh:** ~1kHz (no visible flicker)
- **Audio:** Clear square wave tones

---

## Test Checklist

- [ ] Simulation runs without errors
- [ ] All testbench assertions pass
- [ ] Waveforms show correct state transitions
- [ ] Bitstream generates successfully
- [ ] FPGA programs without errors
- [ ] All coin buttons work
- [ ] Purchase button responds correctly
- [ ] Item selection switches work
- [ ] 7-segment display shows credit
- [ ] LEDs indicate stock levels
- [ ] Stock decrements on purchase
- [ ] Change calculation correct
- [ ] Restock function works
- [ ] Error handling works (insufficient funds)
- [ ] Error handling works (sold out items)
- [ ] Audio feedback plays (if applicable)
- [ ] Reset function works properly

---

## Next Steps After Testing

If all tests pass:
1. ✅ Your vending machine controller is fully functional
2. Consider adding features (bill acceptor, LCD display, etc.)
3. Create documentation for your project

If tests fail:
1. Note which specific test failed
2. Check TCL console / waveforms for clues
3. Use ILA for hardware debugging
4. Verify all source files are up to date
