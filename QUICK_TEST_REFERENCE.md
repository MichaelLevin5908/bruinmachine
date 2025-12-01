# Vending Machine - Quick Test Reference Card

## Basys 3 Hardware Controls

### Switches (Bottom of Board)
```
SW3      SW2       SW1 SW0
[RST]  [RESTOCK]  [ITEM SELECT]
 ↓        ↓         ↓   ↓
DOWN=Run  UP=Fill   00=Item0 ($3)
UP=Reset            01=Item1 ($4)
                    10=Item2 ($6)
                    11=Item3 ($7)
```

### Buttons (Center of Board)
```
        [BTNU]
         $1
          ↑
[BTNL] ← · → [BTNR]
  $5         PURCHASE
          ↓
        [BTND]
         $2
```

### LEDs (Top of Board)
```
15 14 13 12 | 11 10  9  8 | 7  6  5  4 | 3  2  1  0
[STOCK LVL] | [UNUSED  ] | [ANIMATION] | [AVAILABLE]
```

### 7-Segment Display
```
Shows: Current Credit / Price / Change / Error Messages
```

---

## Quick Test Sequence (30 seconds)

### 1. Power On & Reset
- [ ] SW3 **DOWN** (run mode)
- [ ] Display shows `000`
- [ ] LEDs 0-3 all **ON**

### 2. Simple Purchase
- [ ] **SW1=0, SW0=0** (select item 0)
- [ ] Press **BTNL** ($5) → Display: `005`
- [ ] Press **BTNR** (purchase) → Display: `donE` then `002`
- [ ] LED animation plays
- [ ] ✅ **PASS** if display shows `002` (change)

### 3. Error Test
- [ ] **SW1=1, SW0=0** (select item 2, $6)
- [ ] Press **BTNU** ($1) → Display: `001`
- [ ] Press **BTNR** (purchase) → Display: `Err`
- [ ] LEDs blink
- [ ] ✅ **PASS** if error displayed

### 4. Restock Test
- [ ] **SW2 UP** (restock)
- [ ] LEDs 12-15 go to max brightness
- [ ] **SW2 DOWN**
- [ ] ✅ **PASS** if stock refilled

---

## Simulation Test (Vivado)

### Run Simulation
1. Flow Navigator → **Run Behavioral Simulation**
2. Wait for compilation
3. Check **TCL Console** for:
   ```
   [OK] Credit increments to $5 after coin insertion
   [OK] Vend pulse completed without sticking high
   [OK] Credit reduced to $2 after vend and change
   [OK] Change due of $2 computed
   [OK] Inventory decremented for item0
   All testbench checks passed.
   ```
4. ✅ **PASS** if no `[ERROR]` messages

---

## Common Issues

| Problem | Fix |
|---------|-----|
| Display shows garbage | **Reset:** SW3 UP then DOWN |
| Buttons don't work | Check you're not in reset (SW3 should be DOWN) |
| No response | Re-program bitstream |
| Simulation won't run | Set `vending_machine_top_tb` as simulation top |
| Synthesis fails | Set `vending_machine_top` as design top (not testbench!) |

---

## Expected Values Cheat Sheet

### Item Prices
| Item | Normal Price | Low Stock (≤2) |
|------|--------------|----------------|
| 0 | $3 | $4 |
| 1 | $4 | $5 |
| 2 | $6 | $7 |
| 3 | $7 | $8 |

### Coin Values
- BTNU = $1
- BTND = $2
- BTNL = $5

### FSM States (for debugging)
- 0 = IDLE
- 1 = CREDIT
- 2 = CHECK
- 3 = VEND
- 4 = CHANGE
- 5 = ERROR
- 6 = THANK

### Display Messages
- `000`-`015` = Credit/Change amount
- `Err` = Error
- `donE` = Thank you

---

## Quick Debug Commands (Vivado TCL)

```tcl
# Check current top module
current_fileset

# Reset synthesis
reset_run synth_1

# Check for errors
get_msg_config -severity ERROR

# Rerun simulation
launch_simulation
run all
```

---

**✅ System Working If:**
- Simulation passes all checks
- Can insert coins and see credit increase
- Can purchase items and get change
- Stock decrements after purchase
- Error handling works for insufficient funds

**🏆 Full Test Pass:** All items in checklist complete
