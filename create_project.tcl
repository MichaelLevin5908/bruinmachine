# Vivado TCL Script for Automatic Project Creation
# Bruin Machine - Vending Machine Controller for Basys 3
# Compatible with Vivado 2023.2

# Set project name and directory
set project_name "vending_machine"
set project_dir "./vivado_project"

# Get the directory where this script is located
set script_dir [file dirname [info script]]

# Create project directory if it doesn't exist
file mkdir $project_dir

# Create project
puts "Creating project: $project_name"
create_project $project_name $project_dir -part xc7a35tcpg236-1 -force

# Set project properties
set_property board_part digilentinc.com:basys3:part0:1.2 [current_project]
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

# Add design source files
puts "Adding design source files..."
add_files -norecurse [list \
    "$script_dir/src/vending_machine_top.v" \
    "$script_dir/src/fsm_controller.v" \
    "$script_dir/src/coin_handler.v" \
    "$script_dir/src/inventory.v" \
    "$script_dir/src/price_lookup.v" \
    "$script_dir/src/change_calc.v" \
    "$script_dir/src/display_driver.v" \
    "$script_dir/src/seg7_mux.v" \
    "$script_dir/src/bcd_to_7seg.v" \
    "$script_dir/src/led_feedback.v" \
    "$script_dir/src/sound_module.v" \
    "$script_dir/src/debounce.v" \
]

# Set top module
set_property top vending_machine_top [current_fileset]

# Add constraints file
puts "Adding constraints file..."
add_files -fileset constrs_1 -norecurse "$script_dir/basys3.xdc"

# Add simulation source files
puts "Adding simulation source files..."
add_files -fileset sim_1 -norecurse "$script_dir/src/vending_machine_top_tb.v"
set_property top vending_machine_top_tb [get_filesets sim_1]

# Update compile order
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Set synthesis strategy
puts "Configuring synthesis settings..."
set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]

# Set implementation strategy
puts "Configuring implementation settings..."
set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]

# Configure synthesis settings for better results
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
set_property -name {STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY} -value {rebuilt} -objects [get_runs synth_1]

# Enable bitstream compression to reduce file size
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

puts ""
puts "=========================================="
puts "Project creation complete!"
puts "=========================================="
puts "Project: $project_name"
puts "Location: [file normalize $project_dir]"
puts ""
puts "Next steps:"
puts "1. Run synthesis: launch_runs synth_1 -jobs 4"
puts "2. Wait for completion: wait_on_run synth_1"
puts "3. Run implementation: launch_runs impl_1 -jobs 4"
puts "4. Wait for completion: wait_on_run impl_1"
puts "5. Generate bitstream: launch_runs impl_1 -to_step write_bitstream -jobs 4"
puts ""
puts "Or open the project in GUI mode:"
puts "   start_gui"
puts "=========================================="
