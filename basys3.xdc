## Basys 3 Constraints File for Vending Machine Controller
## Compatible with Vivado 2023.2

## Clock signal (100 MHz)
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Switches
## SW0-SW2: Item selection (rubric specifies SW0-SW2 for item select)
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {sw_item[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {sw_item[1]}]
## SW3: Restock function
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports restock]
## SW15: Reset (rubric specifies SW15 for reset)
set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports rst]

## Buttons (active-high) - rubric mapping
## BTN0 = BTNC (center) = Insert $1
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports btn_coin1]
## BTN1 = BTNU (up) = Insert $2
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports btn_coin2]
## BTN2 = BTNL (left) = Insert $5
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports btn_coin5]
## BTN3 = BTNR (right) = Purchase
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports btn_purchase]

## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {leds[0]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {leds[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {leds[2]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {leds[3]}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {leds[4]}]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports {leds[5]}]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {leds[6]}]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports {leds[7]}]

## 7-Segment Display Anodes (active-low)
set_property -dict { PACKAGE_PIN U2    IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN U4    IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN V4    IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN W4    IOSTANDARD LVCMOS33 } [get_ports {an[3]}]

## 7-Segment Display Cathodes (active-low)
set_property -dict { PACKAGE_PIN W7    IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]
set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]
set_property -dict { PACKAGE_PIN U5    IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]
set_property -dict { PACKAGE_PIN V5    IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]

## Stock Level LEDs (using upper LEDs)
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports {stock_level[0]}]
set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports {stock_level[1]}]
set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [get_ports {stock_level[2]}]
set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports {stock_level[3]}]

## Pmod AMP2 Audio Amplifier (Pmod JB connector - moved from JA for testing)
## Pin 1 (AIN - Audio Input): Square wave audio signal
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33  DRIVE 12  SLEW FAST } [get_ports audio_out]
## Pin 3 (!SHUTDOWN - Active-low shutdown): Tied high to enable amplifier
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33  DRIVE 12 } [get_ports audio_sd]

## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
