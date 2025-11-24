# Vending machine testbench

The `src/vending_machine_top_tb.v` bench provides a simple, self-checking simulation for the top-level controller. It pulses coin and purchase inputs, shortens debounce timers for fast runs, and checks credit, change, inventory, and error recovery behavior.

## How to run

1. Build the simulation (requires a Verilog-2001/SystemVerilog-capable simulator such as `iverilog`):

   ```sh
   iverilog -g2012 -s vending_machine_top_tb -o sim_out src/*.v
   ```

2. Run the produced executable to see the scenario logs and pass/fail messages:

   ```sh
   vvp sim_out
   ```

If your environment lacks `iverilog`, install it (e.g., `sudo apt-get install iverilog`) or use another simulator that supports SystemVerilog `defparam` syntax.

### Vivado/XSim notes

Vivado's default "Verilog" compilation mode will accept the bench as-is (it uses only Verilog-2001 constructs). If you see a missing compiler/tool error when launching simulation, ensure Vivado's GCC simulator toolchain is installed and on your PATH, or switch the simulation set to use the bundled XSim flow.
