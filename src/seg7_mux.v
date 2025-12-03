// 7-segment display multiplexer for Basys 3 board.
// Cycles through 4 digits at ~1kHz refresh rate.
module seg7_mux #(
    parameter integer REFRESH_COUNT = 100000  // ~1kHz refresh (100MHz / 100000)
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [6:0]  digit3,  // leftmost digit (7-segment encoded)
    input  wire [6:0]  digit2,
    input  wire [6:0]  digit1,
    input  wire [6:0]  digit0,  // rightmost digit (7-segment encoded)
    output reg  [6:0]  seg,     // cathodes (active-low)
    output reg  [3:0]  an       // anodes (active-low)
);
    // Clock divider for display refresh
    reg [16:0] refresh_counter;
    reg [1:0] digit_select;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 0;
            digit_select <= 0;
        end else begin
            if (refresh_counter == REFRESH_COUNT - 1) begin
                refresh_counter <= 0;
                digit_select <= digit_select + 1;
            end else begin
                refresh_counter <= refresh_counter + 1;
            end
        end
    end

    // Anode control (active-low, one digit at a time)
    always @(*) begin
        case (digit_select)
            2'd0: an = 4'b1110; // digit0 (rightmost)
            2'd1: an = 4'b1101; // digit1
            2'd2: an = 4'b1011; // digit2
            2'd3: an = 4'b0111; // digit3 (leftmost)
            default: an = 4'b1111;
        endcase
    end

    // Multiplex 7-segment encoded digits
    always @(*) begin
        case (digit_select)
            2'd0: seg = digit0;
            2'd1: seg = digit1;
            2'd2: seg = digit2;
            2'd3: seg = digit3;
            default: seg = 7'b1111111; // All segments off
        endcase
    end
endmodule
