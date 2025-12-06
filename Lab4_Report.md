# CS M152A – Lab 4: Bruin Machine

**Team Members:** Michael Levin & Johnny Zheng
**Section:** Yangchao Wu
**Date:** December 7th, 2025
**Instructor:** Prof. Majid Sarrafzadeh

---

## 1. Introduction and Requirements

This lab assignment requires us to design a fully functional vending machine controller on the Basys 3 FPGA board using Xilinx Vivado. The vending machine must accept coin inputs from push buttons, track credit balance, manage inventory for multiple items, compute change, and present status information on both the four-digit seven-segment display and VGA output.

The vending machine operates as a state-driven controller that accepts three denominations of coins ($1, $2, and $5) through dedicated push buttons. Users select one of four items using two slider switches (SW0-SW1), with each item having a different base price ($3, $4, $6, or $7). A dynamic pricing feature adds a $1 surcharge when stock falls below a threshold.

The purchase button initiates a transaction. The controller validates that sufficient credit exists and that the selected item is in stock. Upon successful purchase, the machine dispenses the item (indicated by LED animation), displays "donE" on the seven-segment display, computes and returns change, and decrements inventory.

Error conditions are handled gracefully: attempting to purchase with insufficient funds or from an empty slot triggers an "Err" display and blinking LED feedback. A restock switch refills all inventory slots to maximum capacity.

The VGA display provides visual feedback showing the current credit as a green bar, the item price as a yellow bar, and a status indicator that changes color based on the machine state.

---

## 2. Design Description

### Block Diagram

```
                    +------------------+
    btn_coin1 ----->|                  |
    btn_coin2 ----->|   coin_handler   |-----> coin_pulse, coin_value
    btn_coin5 ----->|                  |
                    +------------------+
                             |
                             v
    +----------+    +------------------+    +-------------+
    | debounce |--->|                  |<---|  inventory  |<--- restock
    +----------+    |  fsm_controller  |    +-------------+
                    |                  |<---|price_lookup |<--- sw_item[1:0]
    btn_purchase -->|                  |    +-------------+
                    +------------------+
                      |    |    |    |
                      v    v    v    v
                   credit state vend_pulse change_due
                      |    |         |         |
                      v    v         v         v
              +---------------+  +---------------+
              |display_driver |  | led_feedback  |
              +---------------+  +---------------+
                      |                  |
                      v                  v
              +---------------+      +-------+
              |   seg7_mux    |      |  LEDs |
              +---------------+      +-------+
                      |
                      v
                 7-segment display

              +---------------+    +---------------------+
              |vga_controller |--->| vga_balance_display |---> VGA output
              +---------------+    +---------------------+
```

### State Diagram

```
                    +-------+
         reset ---->| IDLE  |<-----------------+
                    +-------+                  |
                       |  ^                    |
            coin_pulse |  | no action          |
                       v  |                    |
                    +--------+                 |
                    | CREDIT |                 |
                    +--------+                 |
                        |                      |
             purchase_btn                      |
                        v                      |
                    +-------+                  |
                    | CHECK |                  |
                    +-------+                  |
                   /    |    \                 |
         out of   /     |     \ insufficient  |
         stock   /      |      \ funds        |
                v       v       v             |
           +-------+ +------+ +-------+       |
           | ERROR | | VEND | | ERROR |       |
           +-------+ +------+ +-------+       |
                |       |         |           |
                |       v         |           |
                |   +-------+     |           |
                |   | THANK |     |           |
                |   +-------+     |           |
                |       |         |           |
                |       v         |           |
                |   +--------+    |           |
                +-->| CHANGE |<---+           |
                    +--------+                |
                        |                     |
                        +---------------------+
```

### Module Descriptions

The design is partitioned into input conditioning, control logic, computation, inventory management, and display subsystems that interact through well-defined signals.

**Input Conditioning:**
- `debounce.v`: Filters mechanical switch bounce using a counter-based approach with synchronization flip-flops to prevent metastability
- `coin_handler.v`: Detects rising edges on coin buttons and outputs a single-cycle pulse with the corresponding coin value ($1, $2, or $5)

**Control Logic:**
- `fsm_controller.v`: Seven-state FSM orchestrating the vending operation (IDLE, CREDIT, CHECK, VEND, THANK, CHANGE, ERROR). Manages credit accumulation, validates purchases, and coordinates state transitions

**Computation:**
- `change_calc.v`: Combinational module computing purchase feasibility and change due
- `price_lookup.v`: Maps item selection to base prices with dynamic surcharge when stock is low

**Inventory Management:**
- `inventory.v`: Tracks stock levels for four items using an array of 4-bit counters. Decrements on successful vend, supports bulk restock

**Display Subsystems:**
- `display_driver.v`: Generates 7-segment encoded digits showing credit, price, "Err", or "donE" based on state
- `seg7_mux.v`: Time-multiplexes four digits at ~1kHz refresh rate for the Basys 3 display
- `led_feedback.v`: Drives LEDs showing stock availability (lower 4), error blinking, vend animation, and change amount (upper 4)
- `vga_controller.v`: Generates 640x480 @ 60Hz VGA timing signals with 25MHz pixel clock
- `vga_balance_display.v`: Renders colored bars representing credit and price on VGA output

---

## 3. Simulation Documentation

Testbenches exercise the complete vending machine functionality including coin insertion, successful purchases, error conditions, and inventory management.

### Test Scenarios

**Scenario 1: Successful Purchase with Change**
- Insert $5 coin (btn_coin5)
- Select item 0 (price $3)
- Press purchase button
- Verify: credit increments to $5, vend pulse fires, change of $2 computed, inventory decrements

**Scenario 2: Insufficient Funds Error**
- With $1 credit remaining from previous transaction
- Select item 2 (price $6-7 depending on stock)
- Press purchase button
- Verify: FSM enters ERROR state, "Err" displayed, returns to IDLE with credit preserved

**Scenario 3: Out of Stock Error**
- Deplete inventory of an item through repeated purchases
- Attempt purchase of depleted item
- Verify: ERROR state triggered, credit preserved

**Scenario 4: Dynamic Pricing**
- Purchase items until stock falls below threshold (2 units)
- Verify: price increases by $1 surcharge

### Simulation Results

The testbench confirms:
- Credit correctly accumulates from multiple coin insertions
- Maximum credit limit ($15) prevents overflow
- Change calculation accurate across all price points
- Inventory tracking persists correctly across transactions
- State machine returns to IDLE after both successful and failed transactions

For testing, we first verified that coin insertion correctly incremented the credit register. We observed the credit increase by $1, $2, or $5 depending on which button was pressed. Next, we confirmed that the reset switch cleared all credit and restored inventory to initial values.

We encountered an issue where the vend pulse remained high for multiple cycles, causing double-decrements of inventory. We fixed this by ensuring vend_pulse is registered and only asserted for exactly one clock cycle during the VEND state.

The thank-you display timing was initially too long for simulation, so we parameterized THANK_YOU_CYCLES to allow shorter delays during testbench execution while maintaining 1-second display on hardware.

---

## 4. Conclusion

The implemented Bruin Machine vending controller satisfies all specifications by integrating robust input handling, accurate credit management, dynamic pricing, inventory tracking, change computation, and multi-format display output. The modular decomposition simplified verification and supports future enhancements such as additional payment methods or expanded inventory.

Key challenges encountered:
1. **Debounce timing**: Initial debounce delays were too short, causing spurious coin insertions. We increased CNTR_MAX to 25000 cycles (~250μs at 100MHz) for reliable operation.
2. **State persistence**: The FSM needed careful handling to preserve credit through error states while correctly clearing it after successful transactions with exact payment.
3. **VGA synthesis**: The initial character-ROM based VGA display had synthesis issues with Vivado. We simplified to bar-graph display using purely combinational logic.

The project demonstrates practical application of FSM design, modular hardware architecture, and multi-output display systems on FPGA hardware.

---

## 5. Appendix

### A. Source Files

| File | Description |
|------|-------------|
| `vending_machine_top.v` | Top-level module integrating all subsystems |
| `fsm_controller.v` | Main 7-state finite state machine |
| `coin_handler.v` | Coin button edge detection and value encoding |
| `inventory.v` | 4-item inventory tracker with restock |
| `price_lookup.v` | Item-to-price mapping with dynamic surcharge |
| `change_calc.v` | Purchase validation and change computation |
| `display_driver.v` | 7-segment digit encoder |
| `seg7_mux.v` | 4-digit display multiplexer |
| `led_feedback.v` | LED status indicators and animations |
| `debounce.v` | Input debouncing with synchronization |
| `vga_controller.v` | VGA timing generator (640x480 @ 60Hz) |
| `vga_balance_display.v` | VGA graphics renderer |
| `vending_machine_top_tb.v` | Testbench for functional verification |
| `basys3.xdc` | Pin constraints for Basys 3 board |

### B. Pin Assignments

| Signal | Pin | Function |
|--------|-----|----------|
| clk | W5 | 100MHz system clock |
| rst | R2 | Reset (SW15) |
| btn_coin1 | U18 | Insert $1 (BTNC) |
| btn_coin2 | T18 | Insert $2 (BTNU) |
| btn_coin5 | W19 | Insert $5 (BTNL) |
| btn_purchase | T17 | Purchase (BTNR) |
| sw_item[1:0] | V17, V16 | Item selection |
| restock | W16 | Restock inventory (SW3) |
| vga_r[3:0] | G19, H19, J19, N19 | VGA Red |
| vga_g[3:0] | J17, H17, G17, D17 | VGA Green |
| vga_b[3:0] | N18, L18, K18, J18 | VGA Blue |
| vga_hs | P19 | VGA Horizontal Sync |
| vga_vs | R19 | VGA Vertical Sync |

### C. References

- CS M152A Lab 4 Handout
- Basys 3 Reference Manual (Digilent)
- Xilinx Vivado Design Suite User Guide
