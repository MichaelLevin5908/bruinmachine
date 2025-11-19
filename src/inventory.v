// Tracks inventory per item and decrements on successful vend pulses.
module inventory #(
    parameter integer ITEM_COUNT   = 4,
    parameter integer START_QTY    = 5,
    parameter integer MAX_QTY      = 5
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        restock,
    input  wire [1:0]  item_select,
    input  wire        vend_pulse,
    output reg  [3:0]  stock_level,
    output wire        sold_out
);
    reg [3:0] stock [ITEM_COUNT-1:0];

    integer idx;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (idx = 0; idx < ITEM_COUNT; idx = idx + 1)
                stock[idx] <= START_QTY[3:0];
        end else if (restock) begin
            for (idx = 0; idx < ITEM_COUNT; idx = idx + 1)
                stock[idx] <= MAX_QTY[3:0];
        end else if (vend_pulse && stock[item_select] != 0) begin
            stock[item_select] <= stock[item_select] - 1'b1;
        end
    end

    always @(*) begin
        stock_level = stock[item_select];
    end

    assign sold_out = (stock_level == 0);
endmodule
