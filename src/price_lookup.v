// Maps item selections to prices with optional dynamic adjustment based on inventory.
module price_lookup #(
    parameter [7:0] PRICE0 = 8'd4,
    parameter [7:0] PRICE1 = 8'd5,
    parameter [7:0] PRICE2 = 8'd6,
    parameter [7:0] PRICE3 = 8'd7,
    parameter integer LOW_STOCK_THRESHOLD = 2,
    parameter [7:0] LOW_STOCK_SURCHARGE = 8'd1
) (
    input  wire [1:0] item_select,
    input  wire [3:0] stock_level,
    output reg  [7:0] price_out
);
    always @(*) begin
        case (item_select)
            2'd0: price_out = PRICE0;
            2'd1: price_out = PRICE1;
            2'd2: price_out = PRICE2;
            default: price_out = PRICE3;
        endcase

        if (stock_level <= LOW_STOCK_THRESHOLD)
            price_out = price_out + LOW_STOCK_SURCHARGE;
    end
endmodule
