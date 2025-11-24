# Vivado TCL script to create Basys 3 vending machine project
# Compatible with Vivado 2023.2
# Usage: vivado -mode batch -source create_vivado_project.tcl

set project_name "vending_machine"
set project_dir "./vivado_project"

# Create project
create_project $project_name $project_dir -part xc7a35tcpg236-1 -force

# Set project properties
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

# Add source files
add_files -norecurse {
    src/basys3_vending_machine.v
    src/vending_machine_top.v
    src/seg7_display.v
    src/fsm_controller.v
    src/coin_handler.v
    src/inventory.v
    src/price_lookup.v
    src/change_calc.v
    src/display_driver.v
    src/debounce.v
    src/sound_module.v
    src/led_feedback.v
}

# Add constraints
add_files -fileset constrs_1 -norecurse constraints/basys3.xdc

# Set top module
set_property top basys3_vending_machine [current_fileset]

# Update compile order
update_compile_order -fileset sources_1

puts "Project created successfully!"
puts "Next steps:"
puts "  1. Open project: vivado vivado_project/vending_machine.xpr"
puts "  2. Run Synthesis"
puts "  3. Run Implementation"
puts "  4. Generate Bitstream"
puts "  5. Program device"
