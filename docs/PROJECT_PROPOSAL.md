# CS M152A Lab 4 – Project Proposal

## Vending Machine Controller
**Team Members:** Michael Levin & Johnny Zheng  \\
**TA:** Yangchao Wu  \\
**Section:** Prof. Majid Sarrafzadeh

## 1. Project Overview
We will design and implement a Vending Machine Controller on the Basys 3 FPGA. The system simulates a vending machine that accepts virtual coins, allows users to select an item, handles purchases and change returns, manages inventory, and displays system state via the 7-segment display, LEDs, and switches/buttons. The project demonstrates FSM design, synchronous logic, counters, debouncing, and multi-module integration.

## 2. Functional Description
### 2.1 Accepted Inputs
- **Coin Inputs (BTN0, BTN1, BTN2):** BTN0 = $1, BTN1 = $2, BTN2 = $5.
- **Item Selection (SW0–SW2):** User selects an item (0–3), each with its own price (e.g., $3, $4, $6, $7).
- **Purchase Button (BTN3):** Confirms purchase attempt.
- **Reset (SW15):** Resets credit, state, and inventory.

### 2.2 Outputs
- **4-digit 7-segment display:** Shows current credit when idle; shows price, "Err," or "Done" depending on state.
- **LEDs:** Indicate item inventory (LED0–LED3), insufficient funds (blinking LED), and change returned.
- **Sound:** Generated via `sound_module.v` using a clock divider and square-wave generator to drive an external speaker through the Pmod AMP2 audio amplifier. Different sounds will play for each item.

### 2.3 System Behavior
1. User inserts money.
2. User selects an item using switches.
3. Pressing BTN3 attempts purchase:
   - If credit < price → reject & show "Err."
   - Checks if the item is out of stock; if so, reject.
   - Otherwise decrement inventory, deduct cost, return change if needed, and show "Done."

## 3. Technical Requirements
### 3.1 FSM States
- **IDLE:** Waiting for coins/selection.
- **CREDIT_UPDATE:** Adding coin value.
- **CHECK_ITEM:** Verifying availability.
- **CHECK_BALANCE:** Comparing credit to item price.
- **VEND:** Release item and update inventory.
- **CHANGE_RETURN:** Return excess credit.
- **ERROR:** Insufficient funds or empty stock.
- **THANK_YOU:** Show success screen.

### 3.2 Modules
- **coin_handler.v:** Debounces buttons and adds coin value to credit.
- **inventory.v:** Maintains item counts (initial stock = 5 each).
- **price_lookup.v:** Returns the price of the selected item.
- **change_calc.v:** Implements credit-price subtraction and drives change outputs.
- **fsm_controller.v:** Main state machine coordinating behavior.
- **display_driver.v:** Drives the 7-segment display to show credit, error, or confirmation.
- **debounce.v:** Debounces all button inputs.
- **sound_module.v:** Generates audio tones with a clock divider and square-wave output; plays during vending or error events.

## 4. Creativity Features (Planned Enhancements)
- Dynamic pricing: prices increase as inventory drops (simulating demand surge).
- LED animation when an item is dispensed.
- Overcharge protection: reject values above $15.

## 5. Correctness Rubric
### Rubric Part 1 – Basic Credit Handling (25%)
- Coin inputs correctly increase credit.
- Display shows current credit.
- Reset returns credit to 0.
- No overflow beyond $15.

### Rubric Part 2 – Item Selection & Pricing (25%)
- Each item selectable via switches.
- Prices displayed correctly.
- Insufficient funds produce an error state and return to IDLE.

### Rubric Part 3 – Inventory & Vending Logic (25%)
- Inventory starts at correct count and decrements on purchase.
- Sold-out items trigger an error state.
- Successful purchases enter "THANK_YOU" state.

### Rubric Part 4 – Change Return & Creative Features (25%)
- Correct change calculation and LED pattern to indicate change.
- At least one creative feature demonstrated (dynamic pricing, LED animation, or sound feedback with distinct tones per item via Pmod AMP2).

## 6. Summary
This project satisfies Lab 4 requirements by using multiple FPGA peripherals (7-segment, LEDs, buttons, switches), employing a multi-module FSM-based design with timers, arithmetic logic, and debouncing, and incorporating creativity features with clear, testable demonstrations.
