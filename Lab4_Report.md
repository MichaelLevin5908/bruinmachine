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

*Figure 1: The block diagram represents all the inputs into the vending machine controller and their data flow. The diagram shows how the FSM controller coordinates between coin handling, inventory management, price lookup, and the display subsystems. Debounced button inputs feed into the coin handler and FSM, while the FSM outputs drive both the 7-segment and VGA displays.*

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

*Figure 2: The state machine shows the transitions between IDLE, CREDIT, CHECK, VEND, THANK, CHANGE, and ERROR states. The machine accumulates credit until a purchase is requested. The CHECK state validates stock and funds before transitioning to VEND (success) or ERROR (failure). The THANK state displays confirmation before CHANGE computes and returns any remaining balance. Credit is preserved through error states and across multiple transactions.*

### Module Descriptions

The design is partitioned into input conditioning, control logic, computation, inventory management, and display subsystems that interact through well-defined signals.

The debounce module filters mechanical switch bounce using a counter-based approach with two synchronization flip-flops to prevent metastability from propagating into the synchronous logic. Each button press must remain stable for 25,000 clock cycles (~250μs) before being registered.

The coin_handler module detects rising edges on the three coin buttons and outputs a single-cycle pulse with the corresponding coin value ($1, $2, or $5). Priority encoding ensures that simultaneous button presses are resolved deterministically, with higher denominations taking precedence.

The fsm_controller module implements a seven-state finite state machine orchestrating the vending operation. It tracks credit accumulation, validates purchase requests against both stock levels and available funds, generates vend pulses, and computes change. The controller ensures credit is preserved through error conditions while properly deducting after successful transactions.

The change_calc module is a purely combinational block computing purchase feasibility (credit >= price) and the change due (credit - price). This separation keeps the FSM clean and allows easy modification of pricing logic.

The price_lookup module maps the 2-bit item selection to base prices ($3, $4, $6, $7) and applies a $1 surcharge when stock falls to 2 units or below, implementing dynamic pricing based on scarcity.

The inventory module tracks stock levels for four items using an array of 4-bit counters initialized to 5. It decrements the selected item on vend_pulse and supports bulk restocking via a dedicated switch.

The display_driver module generates 7-segment encoded outputs showing credit during idle/credit states, "Err" during errors, and "donE" after successful vending. The seg7_mux module time-multiplexes these four digits at ~1kHz refresh rate.

The led_feedback module drives the 8 onboard LEDs: the lower 4 show stock availability for each item, while the upper 4 display error blinking patterns, vend animations, or change amount depending on state.

The vga_controller module generates 640x480 @ 60Hz VGA timing by dividing the 100MHz clock to 25MHz and counting through the horizontal (800) and vertical (525) totals. The vga_balance_display module renders colored bars representing credit (green) and price (yellow), with a status box that changes color based on FSM state.

---

## 3. Simulation Documentation

Testbenches exercise the complete vending machine functionality including coin insertion, successful purchases, error conditions, and inventory management. Simulated waveforms confirm that credit accumulates correctly, purchases decrement inventory, change is computed accurately, and error states preserve user credit.

For testing, we first tested if coin insertion correctly incremented the credit register. After pressing btn_coin5, we observed credit increase from 0 to 5. We then verified btn_coin1 and btn_coin2 added $1 and $2 respectively. Next, we checked that the reset switch cleared all credit back to 0 and restored inventory to initial values.

We then tested the purchase flow by inserting $5 and selecting item 0 (price $3). After pressing the purchase button, we verified the FSM transitioned through CHECK → VEND → THANK → CHANGE, the inventory decremented from 5 to 4, and change_due showed $2. The credit register correctly showed the remaining $2 balance.

We noticed an issue where the vend_pulse remained high for multiple cycles, causing double-decrements of inventory. We fixed this by ensuring vend_pulse is registered and only asserted for exactly one clock cycle: `vend_pulse <= (state == STATE_VEND)` with the state immediately transitioning to THANK.

For error conditions, we tested purchasing with insufficient funds. With $1 credit and item 2 selected (price $6), pressing purchase correctly triggered the ERROR state, displayed "Err", and preserved the $1 credit after returning to IDLE.

We also tested the out-of-stock condition by repeatedly purchasing item 0 until inventory reached 0, then attempting another purchase. The FSM correctly entered ERROR state without decrementing the already-zero inventory.

The dynamic pricing feature was verified by purchasing items until stock fell to 2 units. We confirmed the price increased by $1 (item 0 changed from $3 to $4 at low stock).

*Images 1 and 2: The first waveform shows the credit register incrementing on coin insertion and decrementing after purchase. The second waveform shows the state transitions during a successful vend cycle with the inventory count decreasing.*

---

## 4. Conclusion

The implemented Bruin Machine vending controller satisfies all specifications by integrating robust input handling, accurate credit management, dynamic pricing, inventory tracking, change computation, and multi-format display output. Modular decomposition simplified verification and will support future enhancements such as additional payment methods or expanded inventory slots.

For difficulties, we had trouble with the vend_pulse signal staying high for multiple clock cycles, which caused inventory to decrement more than once per purchase. We fixed this by making the VEND state transition immediately to THANK, ensuring vend_pulse is high for exactly one cycle. We also encountered issues with the VGA character ROM not synthesizing correctly in Vivado; we simplified to a bar-graph display using purely combinational region detection logic, which synthesized reliably.

Another challenge was ensuring credit persisted correctly through error states while being properly deducted after successful purchases. We carefully structured the FSM so that credit modification only occurs in the CHANGE state after a successful vend, never during ERROR handling.

I really enjoyed this lab as it demonstrated practical FSM design with real-world transaction logic. The modular architecture made debugging straightforward, and seeing the complete vending machine work on hardware was very satisfying.

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
