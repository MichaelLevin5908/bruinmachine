// Top-level module connecting the vending machine controller blocks.
module vending_machine_top (
    input  wire clk,
    input  wire rst,
    input  wire btn_coin1,
    input  wire btn_coin2,
    input  wire btn_coin5,
    input  wire btn_purchase,
    input  wire [1:0] sw_item,
    input  wire restock,
    output wire [3:0] digit3,
    output wire [3:0] digit2,
    output wire [3:0] digit1,
    output wire [3:0] digit0,
    output wire [3:0] stock_level,
    output wire       audio_out
);
    // Debounce buttons
    wire db_coin1;
    wire db_coin2;
    wire db_coin5;
    wire db_purchase;

    debounce db0(.clk(clk), .rst(rst), .noisy(btn_coin1), .clean(db_coin1));
    debounce db1(.clk(clk), .rst(rst), .noisy(btn_coin2), .clean(db_coin2));
    debounce db2(.clk(clk), .rst(rst), .noisy(btn_coin5), .clean(db_coin5));
    debounce db3(.clk(clk), .rst(rst), .noisy(btn_purchase), .clean(db_purchase));

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

    inventory inv(
        .clk(clk),
        .rst(rst),
        .restock(restock),
        .item_select(sw_item),
        .vend_pulse(vend_pulse),
        .stock_level(stock_level),
        .sold_out()
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

    // Display driver
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

    // Sound feedback
    sound_module sound(
        .clk(clk),
        .rst(rst),
        .vend_event(vend_pulse),
        .error_event(error_flag),
        .audio_out(audio_out)
    );
endmodule
