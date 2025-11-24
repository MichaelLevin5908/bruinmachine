// Basys 3 top-level wrapper for vending machine controller
// Maps Basys 3 hardware to vending machine controller
module basys3_vending_machine (
    input  wire        clk,           // 100 MHz clock (W5)
    input  wire        btnC,          // Center button - Reset
    input  wire        btnU,          // Up button - $1 coin
    input  wire        btnL,          // Left button - $2 coin
    input  wire        btnD,          // Down button - $5 coin
    input  wire        btnR,          // Right button - Purchase
    input  wire [1:0]  sw,            // SW1-SW0 for item selection
    input  wire        sw15,          // SW15 for restock
    output wire [6:0]  seg,           // 7-segment cathodes
    output wire [3:0]  an,            // 7-segment anodes (active low)
    output wire [15:0] led,           // LEDs
    output wire        aud_sd,        // Pmod AMP2 shutdown (active low)
    output wire        aud_pwm        // Pmod AMP2 PWM audio
);
    // Internal signals from vending machine core
    wire [3:0] digit3, digit2, digit1, digit0;
    wire [3:0] stock_level;
    wire [7:0] core_leds;
    wire audio_out;

    // Vending machine core with shorter debounce for hardware
    vending_machine_top #(
        .DEBOUNCE_MAX(2_500_000)  // 25ms debounce at 100MHz
    ) core (
        .clk(clk),
        .rst(btnC),
        .btn_coin1(btnU),
        .btn_coin2(btnL),
        .btn_coin5(btnD),
        .btn_purchase(btnR),
        .sw_item(sw),
        .restock(sw15),
        .digit3(digit3),
        .digit2(digit2),
        .digit1(digit1),
        .digit0(digit0),
        .stock_level(stock_level),
        .leds(core_leds),
        .audio_out(audio_out)
    );

    // 7-segment display controller
    seg7_display display (
        .clk(clk),
        .rst(btnC),
        .digit3(digit3),
        .digit2(digit2),
        .digit1(digit1),
        .digit0(digit0),
        .seg(seg),
        .an(an)
    );

    // LED mapping: show stock on LED3-0 and other info on LED11-8
    assign led[3:0]   = stock_level;      // Stock availability
    assign led[7:4]   = core_leds[7:4];   // Change/animation/error
    assign led[11:8]  = core_leds[3:0];   // Duplicate of stock for visibility
    assign led[15:12] = 4'b0000;          // Unused

    // Audio output (Pmod AMP2 on JA)
    assign aud_pwm = audio_out;
    assign aud_sd = 1'b1;  // Enable amplifier (active low shutdown)

endmodule
