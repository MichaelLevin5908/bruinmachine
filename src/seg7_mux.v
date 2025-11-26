// 7-segment display multiplexer for Basys 3 board.
// Cycles through 4 digits at ~1kHz refresh rate.
module seg7_mux #(
    parameter integer REFRESH_COUNT = 100000  // ~1kHz refresh (100MHz / 100000)
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  digit3,  // leftmost digit
    input  wire [3:0]  digit2,
    input  wire [3:0]  digit1,
    input  wire [3:0]  digit0,  // rightmost digit
    output wire [6:0]  seg,     // cathodes (active-low)
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

    // Select current digit BCD value
    reg [3:0] current_digit;
    always @(*) begin
        case (digit_select)
            2'd0: current_digit = digit0;
            2'd1: current_digit = digit1;
            2'd2: current_digit = digit2;
            2'd3: current_digit = digit3;
            default: current_digit = 4'h0;
        endcase
    end

    // BCD to 7-segment decoder
    bcd_to_7seg decoder (
        .bcd(current_digit),
        .seg(seg)
    );
endmodule
