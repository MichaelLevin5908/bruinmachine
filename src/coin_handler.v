// Detects coin button presses and outputs a single-cycle pulse with the coin value.
module coin_handler #(
    parameter integer COIN1_VALUE   = 1,
    parameter integer COIN2_VALUE   = 2,
    parameter integer COIN5_VALUE   = 5
) (
    input  wire clk,
    input  wire rst,
    input  wire btn_coin1,
    input  wire btn_coin2,
    input  wire btn_coin5,
    output reg  coin_pulse,
    output reg [7:0] coin_value
);
    reg btn1_d;
    reg btn2_d;
    reg btn5_d;

    wire rise1 = btn_coin1 & ~btn1_d;
    wire rise2 = btn_coin2 & ~btn2_d;
    wire rise5 = btn_coin5 & ~btn5_d;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn1_d     <= 1'b0;
            btn2_d     <= 1'b0;
            btn5_d     <= 1'b0;
            coin_pulse <= 1'b0;
            coin_value <= 0;
        end else begin
            btn1_d <= btn_coin1;
            btn2_d <= btn_coin2;
            btn5_d <= btn_coin5;

            if (rise5) begin
                coin_pulse <= 1'b1;
                coin_value <= COIN5_VALUE[7:0];
            end else if (rise2) begin
                coin_pulse <= 1'b1;
                coin_value <= COIN2_VALUE[7:0];
            end else if (rise1) begin
                coin_pulse <= 1'b1;
                coin_value <= COIN1_VALUE[7:0];
            end else begin
                coin_pulse <= 1'b0;
                coin_value <= 0;
            end
        end
    end
endmodule
