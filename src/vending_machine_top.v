// Top-level module connecting the vending machine controller blocks.
// Designed for Basys 3 board with Vivado 2023.2 and Pmod AMP2 audio amplifier.
module vending_machine_top #(
    parameter integer DEBOUNCE_MAX = 25000
) (
    input  wire clk,
    input  wire rst,
    input  wire btn_coin1,
    input  wire btn_coin2,
    input  wire btn_coin5,
    input  wire btn_purchase,
    input  wire [1:0] sw_item,
    input  wire restock,
    output wire [6:0] seg,          // 7-segment cathodes
    output wire [3:0] an,           // 7-segment anodes
    output wire [3:0] stock_level,
    output wire [7:0] leds,
    output wire       audio_out,    // Pmod AMP2 audio input
    output wire       audio_sd      // Pmod AMP2 shutdown (active-low, 1=enabled)
);
    // Debounce buttons
    wire db_coin1;
    wire db_coin2;
    wire db_coin5;
    wire db_purchase;

    debounce #(.CNTR_MAX(DEBOUNCE_MAX)) db0(.clk(clk), .rst(rst), .noisy(btn_coin1), .clean(db_coin1));
    debounce #(.CNTR_MAX(DEBOUNCE_MAX)) db1(.clk(clk), .rst(rst), .noisy(btn_coin2), .clean(db_coin2));
    debounce #(.CNTR_MAX(DEBOUNCE_MAX)) db2(.clk(clk), .rst(rst), .noisy(btn_coin5), .clean(db_coin5));
    debounce #(.CNTR_MAX(DEBOUNCE_MAX)) db3(.clk(clk), .rst(rst), .noisy(btn_purchase), .clean(db_purchase));

    // Coin detection
    wire coin_pulse;
    wire [7:0] coin_value;
    coin_handler coins(
        .clk(clk),
        .rst(rst),
        .btn_coin1(db_coin1),
        .btn_coin2(db_coin2),
        .btn_coin5(db_coin5),
        .coin_pulse(coin_pulse),
        .coin_value(coin_value)
    );

    // Inventory and pricing
    wire vend_pulse;
    wire [7:0] price;
    wire [3:0] stock_available;

    inventory inv(
        .clk(clk),
        .rst(rst),
        .restock(restock),
        .item_select(sw_item),
        .vend_pulse(vend_pulse),
        .stock_level(stock_level),
        .sold_out(),
        .stock_available(stock_available)
    );

    price_lookup prices(
        .item_select(sw_item),
        .stock_level(stock_level),
        .price_out(price)
    );

    // FSM controller
    wire [7:0] credit;
    wire [2:0] state;
    wire error_flag;
    wire change_returning;
    wire [7:0] change_due;

    fsm_controller ctrl(
        .clk(clk),
        .rst(rst),
        .coin_pulse(coin_pulse),
        .coin_value(coin_value),
        .purchase_btn(db_purchase),
        .item_select(sw_item),
        .stock_level(stock_level),
        .price(price),
        .credit(credit),
        .vend_pulse(vend_pulse),
        .state(state),
        .error_flag(error_flag),
        .change_returning(change_returning),
        .change_due(change_due)
    );

    wire [7:0] leds_internal;
    led_feedback leds_out(
        .clk(clk),
        .rst(rst),
        .state(state),
        .vend_event(vend_pulse),
        .error_event(error_flag),
        .change_returning(change_returning),
        .change_due(change_due),
        .stock_available(stock_available),
        .item_select(sw_item),
        .leds(leds_internal)
    );

    // Slow down audio_out for LED visibility (divide by ~2^20 for ~95Hz blink)
    reg [19:0] audio_vis_counter;
    always @(posedge clk or posedge rst)
        if (rst) audio_vis_counter <= 0;
        else if (audio_out) audio_vis_counter <= audio_vis_counter + 1'b1;

    // LED[7] = audio_active (ON in test mode), LED[6] = slow blink if audio toggling
    assign leds = {audio_active, audio_vis_counter[19], leds_internal[5:0]};

    // Display driver (7-segment encoded)
    wire [6:0] digit3;
    wire [6:0] digit2;
    wire [6:0] digit1;
    wire [6:0] digit0;

    display_driver display(
        .credit(credit),
        .price(price),
        .change_due(change_due),
        .state(state),
        .digit3(digit3),
        .digit2(digit2),
        .digit1(digit1),
        .digit0(digit0)
    );

    // 7-segment display multiplexer for Basys 3
    seg7_mux seg7(
        .clk(clk),
        .rst(rst),
        .digit3(digit3),
        .digit2(digit2),
        .digit1(digit1),
        .digit0(digit0),
        .seg(seg),
        .an(an)
    );

    // Sound feedback
    wire audio_active;
    sound_module sound(
        .clk(clk),
        .rst(rst),
        .vend_event(vend_pulse),
        .error_event(error_flag),
        .item_select(sw_item),
        .audio_out(audio_out),
        .audio_active(audio_active)  // Will be HIGH in test mode
    );

    // Debug: LED[7] shows audio_active, LED[6] shows audio_out signal (will blink fast if working)

    // Enable Pmod AMP2 (shutdown is active-low, so 1 = amplifier enabled)
    assign audio_sd = 1'b1;
endmodule
