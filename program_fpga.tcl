# FPGA Programming Script for Bruin Machine
# Programs the Basys 3 board with the generated bitstream
# Compatible with Vivado 2023.2

set project_name "vending_machine"
set project_dir "./vivado_project"
set bit_file "$project_dir/$project_name.runs/impl_1/vending_machine_top.bit"

# Check if project exists
if {![file exists "$project_dir/$project_name.xpr"]} {
    # Try alternate bitstream location
    set bit_file "./vending_machine_top.bit"
    if {![file exists $bit_file]} {
        puts "ERROR: No bitstream file found!"
        puts "Expected location: $project_dir/$project_name.runs/impl_1/vending_machine_top.bit"
        puts "Or: ./vending_machine_top.bit"
        puts ""
        puts "Please run the build first:"
        puts "  source build.tcl"
        exit 1
    }
}

puts ""
puts "=========================================="
puts "  FPGA Programming Tool"
puts "=========================================="
puts ""
puts "Bitstream: $bit_file"
puts ""

# Open hardware manager
puts "Opening Hardware Manager..."
open_hw_manager

# Connect to hardware server
puts "Connecting to hardware server..."
connect_hw_server -url localhost:3121 -allow_non_jtag

# Open hardware target (auto-detect board)
puts "Detecting hardware target..."
if {[catch {open_hw_target} err]} {
    puts "ERROR: Failed to detect hardware target!"
    puts "Error: $err"
    puts ""
    puts "Troubleshooting:"
    puts "  1. Ensure Basys 3 board is connected via USB"
    puts "  2. Verify the board is powered on"
    puts "  3. Check that USB drivers are installed"
    puts "  4. Try reconnecting the USB cable"
    puts "  5. Close and reopen Vivado"
    puts ""
    exit 1
}

puts "Hardware target detected successfully!"

# Get the FPGA device
set fpga_device [get_hw_devices xc7a35t_0]

if {$fpga_device == ""} {
    puts "ERROR: No FPGA device found!"
    puts "Expected device: xc7a35t_0 (Basys 3)"
    puts ""
    puts "Available devices:"
    puts [get_hw_devices]
    puts ""
    exit 1
}

puts "FPGA device: $fpga_device"

# Set the programming file
puts ""
puts "Setting programming file..."
set_property PROGRAM.FILE $bit_file $fpga_device

# Refresh device
current_hw_device $fpga_device
refresh_hw_device -update_hw_probes false $fpga_device

# Program the device
puts ""
puts "Programming device..."
puts "This will take approximately 5-10 seconds..."
puts ""

if {[catch {program_hw_devices $fpga_device} err]} {
    puts "ERROR: Programming failed!"
    puts "Error: $err"
    puts ""
    puts "Troubleshooting:"
    puts "  1. Power cycle the board"
    puts "  2. Reconnect the USB cable"
    puts "  3. Try programming again"
    puts "  4. Check for USB connection issues"
    puts ""
    exit 1
}

puts ""
puts "=========================================="
puts "  Programming Successful!"
puts "=========================================="
puts ""
puts "Your Basys 3 board is now programmed with the vending machine controller!"
puts ""
puts "Testing the Design:"
puts "  1. Switches 0-1 (sw_item): Select item (00=chips, 01=soda, 10=candy, 11=water)"
puts "  2. Switch 2 (restock): Restock inventory (flip on then off)"
puts "  3. Switch 3 (rst): Reset the controller (normally off)"
puts "  4. Button Center (btn_coin1): Insert 1 cent"
puts "  5. Button Down (btn_coin2): Insert 2 cents"
puts "  6. Button Left (btn_coin5): Insert 5 cents"
puts "  7. Button Right (btn_purchase): Purchase item"
puts ""
puts "Outputs:"
puts "  - 7-segment display: Shows credit, price, or change"
puts "  - LEDs 0-7: Status indicators (credit, errors, dispensing)"
puts "  - LEDs 12-15 (stock_level): Current inventory level"
puts "  - Audio (if Pmod AMP2 connected): Sound feedback"
puts ""
puts "To close Hardware Manager:"
puts "  close_hw_manager"
puts ""
puts "=========================================="
puts ""
