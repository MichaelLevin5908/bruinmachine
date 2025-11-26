# Complete Build Script for Bruin Machine
# This script creates the project and runs the complete build flow
# Compatible with Vivado 2023.2

# Configuration
set project_name "vending_machine"
set project_dir "./vivado_project"
set num_jobs 4

# Get script directory
set script_dir [file dirname [info script]]

puts ""
puts "=========================================="
puts "  Bruin Machine - Automated Build"
puts "=========================================="
puts ""

# Step 1: Create project (or open if exists)
if {[file exists "$project_dir/$project_name.xpr"]} {
    puts "Opening existing project..."
    open_project "$project_dir/$project_name.xpr"
} else {
    puts "Creating new project..."
    source "$script_dir/create_project.tcl"
}

puts ""
puts "=========================================="
puts "  Step 1: Running Synthesis"
puts "=========================================="
puts ""

# Reset synthesis run to ensure clean build
reset_run synth_1

# Launch synthesis
puts "Launching synthesis with $num_jobs parallel jobs..."
launch_runs synth_1 -jobs $num_jobs

# Wait for synthesis to complete
puts "Waiting for synthesis to complete..."
wait_on_run synth_1

# Check synthesis status
set synth_status [get_property STATUS [get_runs synth_1]]
set synth_progress [get_property PROGRESS [get_runs synth_1]]

puts ""
puts "Synthesis Status: $synth_status"
puts "Synthesis Progress: $synth_progress"
puts ""

if {$synth_status != "synth_design Complete!"} {
    puts "ERROR: Synthesis failed!"
    puts "Please check the log files for details:"
    puts "  $project_dir/$project_name.runs/synth_1/runme.log"
    exit 1
}

puts "SUCCESS: Synthesis completed successfully!"

# Open synthesized design to check for errors
open_run synth_1

# Report synthesis statistics
puts ""
puts "=========================================="
puts "  Synthesis Statistics"
puts "=========================================="
puts ""

# Report utilization
report_utilization -file "$project_dir/utilization_synth.txt"
puts "Utilization report saved to: $project_dir/utilization_synth.txt"

# Check for critical warnings
set crit_warns [get_msg_config -count -severity {CRITICAL WARNING}]
puts "Critical Warnings: $crit_warns"

if {$crit_warns > 0} {
    puts "WARNING: There are critical warnings in synthesis!"
    puts "Review the messages before proceeding."
}

# Close synthesized design
close_design

puts ""
puts "=========================================="
puts "  Step 2: Running Implementation"
puts "=========================================="
puts ""

# Reset implementation run
reset_run impl_1

# Launch implementation
puts "Launching implementation with $num_jobs parallel jobs..."
launch_runs impl_1 -jobs $num_jobs

# Wait for implementation to complete
puts "Waiting for implementation to complete..."
wait_on_run impl_1

# Check implementation status
set impl_status [get_property STATUS [get_runs impl_1]]
set impl_progress [get_property PROGRESS [get_runs impl_1]]

puts ""
puts "Implementation Status: $impl_status"
puts "Implementation Progress: $impl_progress"
puts ""

if {$impl_status != "route_design Complete!"} {
    puts "ERROR: Implementation failed!"
    puts "Please check the log files for details:"
    puts "  $project_dir/$project_name.runs/impl_1/runme.log"
    exit 1
}

puts "SUCCESS: Implementation completed successfully!"

# Open implemented design
open_run impl_1

# Report implementation statistics
puts ""
puts "=========================================="
puts "  Implementation Statistics"
puts "=========================================="
puts ""

# Report final utilization
report_utilization -file "$project_dir/utilization_impl.txt"
puts "Utilization report saved to: $project_dir/utilization_impl.txt"

# Report timing
report_timing_summary -file "$project_dir/timing_summary.txt"
puts "Timing summary saved to: $project_dir/timing_summary.txt"

# Get timing results
set wns [get_property SLACK [get_timing_paths]]
set whs [get_property SLACK [get_timing_paths -hold]]

puts ""
puts "Timing Results:"
puts "  WNS (Worst Negative Slack): $wns ns"
puts "  WHS (Worst Hold Slack): $whs ns"
puts ""

if {$wns < 0} {
    puts "WARNING: Design has negative setup slack!"
    puts "The design may not meet timing at the specified frequency."
    puts "Consider:"
    puts "  1. Reducing clock frequency in basys3.xdc"
    puts "  2. Using a different implementation strategy"
    puts "  3. Adding pipeline stages"
} else {
    puts "TIMING MET: All timing constraints are satisfied!"
}

# Report power
report_power -file "$project_dir/power_summary.txt"
puts "Power report saved to: $project_dir/power_summary.txt"

# Close implemented design
close_design

puts ""
puts "=========================================="
puts "  Step 3: Generating Bitstream"
puts "=========================================="
puts ""

# Launch bitstream generation
puts "Generating bitstream..."
launch_runs impl_1 -to_step write_bitstream -jobs $num_jobs

# Wait for bitstream generation to complete
wait_on_run impl_1

# Check bitstream status
set bit_status [get_property STATUS [get_runs impl_1]]
set bit_progress [get_property PROGRESS [get_runs impl_1]]

puts ""
puts "Bitstream Status: $bit_status"
puts "Bitstream Progress: $bit_progress"
puts ""

if {$bit_status != "write_bitstream Complete!"} {
    puts "ERROR: Bitstream generation failed!"
    puts "Please check the log files for details:"
    puts "  $project_dir/$project_name.runs/impl_1/runme.log"
    exit 1
}

puts "SUCCESS: Bitstream generated successfully!"

# Get bitstream file location
set bit_file "$project_dir/$project_name.runs/impl_1/vending_machine_top.bit"
puts ""
puts "Bitstream location: $bit_file"

# Copy bitstream to project root for easy access
file copy -force $bit_file "$script_dir/vending_machine_top.bit"
puts "Bitstream copied to: $script_dir/vending_machine_top.bit"

# Generate final reports
puts ""
puts "=========================================="
puts "  Generating Final Reports"
puts "=========================================="
puts ""

open_run impl_1

# Generate comprehensive reports
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -file "$project_dir/timing_summary_detailed.txt"
puts "Detailed timing report: $project_dir/timing_summary_detailed.txt"

report_utilization -hierarchical -file "$project_dir/utilization_hierarchical.txt"
puts "Hierarchical utilization: $project_dir/utilization_hierarchical.txt"

report_drc -file "$project_dir/drc_report.txt"
puts "DRC report: $project_dir/drc_report.txt"

close_design

puts ""
puts "=========================================="
puts "  Build Summary"
puts "=========================================="
puts ""
puts "Project: $project_name"
puts "Bitstream: $script_dir/vending_machine_top.bit"
puts ""
puts "Reports Generated:"
puts "  - Synthesis utilization: $project_dir/utilization_synth.txt"
puts "  - Implementation utilization: $project_dir/utilization_impl.txt"
puts "  - Hierarchical utilization: $project_dir/utilization_hierarchical.txt"
puts "  - Timing summary: $project_dir/timing_summary.txt"
puts "  - Detailed timing: $project_dir/timing_summary_detailed.txt"
puts "  - Power analysis: $project_dir/power_summary.txt"
puts "  - DRC report: $project_dir/drc_report.txt"
puts ""
puts "Next Steps:"
puts "  1. Connect your Basys 3 board"
puts "  2. Open Hardware Manager: open_hw_manager"
puts "  3. Auto-connect to board: open_hw_target"
puts "  4. Program device:"
puts "     set_property PROGRAM.FILE {$bit_file} [get_hw_devices xc7a35t_0]"
puts "     program_hw_devices [get_hw_devices xc7a35t_0]"
puts ""
puts "Or run: source program_fpga.tcl"
puts ""
puts "=========================================="
puts "  Build Complete!"
puts "=========================================="
puts ""
