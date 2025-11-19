# Bruin Machine

FPGA-based vending machine controller project for UCLA CS M152A Lab 4. The design targets the Basys 3 board and demonstrates a multi-module FSM with debounced inputs, dynamic pricing, change handling, inventory management, 7-segment/LED output, and sound feedback via Pmod AMP2.

## RTL sources
- `src/debounce.v` – two-flop synchronizer and counter-based debouncer for buttons/switches.
- `src/coin_handler.v` – edge detector that converts coin button presses into single-cycle pulses with associated value.
- `src/inventory.v` – per-item stock tracker with restock support and sold-out detection.
- `src/price_lookup.v` – base price lookup with optional low-stock surcharge for dynamic pricing.
- `src/change_calc.v` – combinational helper that checks purchase eligibility and computes change.
- `src/fsm_controller.v` – main vending FSM managing credit, vending, and error/thank-you paths.
- `src/display_driver.v` – simple 4-digit BCD mux for seven-segment display driving or simulation visibility.
- `src/sound_module.v` – square-wave tone generator for vend and error feedback.
- `src/vending_machine_top.v` – top-level wrapper wiring together debouncing, coins, FSM, inventory, display, and sound.

## Documentation
- [Project Proposal](docs/PROJECT_PROPOSAL.md)
