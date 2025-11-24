// Seven-segment display controller with time multiplexing for Basys 3
// Converts 4-digit BCD input to 7-segment patterns and multiplexes across 4 digits
module seg7_display #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer REFRESH_RATE = 1000  // 1kHz refresh per digit
) (
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  digit3,  // Leftmost digit BCD
    input  wire [3:0]  digit2,
    input  wire [3:0]  digit1,
    input  wire [3:0]  digit0,  // Rightmost digit BCD
    output reg  [6:0]  seg,     // 7-segment pattern {g,f,e,d,c,b,a}
    output reg  [3:0]  an       // Digit enable (active low)
);
    // Verilog-2001 friendly clog2 replacement
    function integer clog2;
        input integer value;
        integer i;
        begin
            value = value - 1;
            for (i = 0; value > 0; i = i + 1)
                value = value >> 1;
            clog2 = i;
        end
    endfunction

    // Refresh counter to cycle through digits
    localparam integer COUNT_MAX = CLK_FREQ / (REFRESH_RATE * 4);
    localparam integer COUNTER_WIDTH = clog2(COUNT_MAX + 1);
    reg [COUNTER_WIDTH-1:0] refresh_counter;
    reg [1:0] digit_select;

    // BCD to 7-segment decoder
    function [6:0] bcd_to_seg;
        input [3:0] bcd;
        begin
            case (bcd)
                4'h0: bcd_to_seg = 7'b1000000; // 0
                4'h1: bcd_to_seg = 7'b1111001; // 1
                4'h2: bcd_to_seg = 7'b0100100; // 2
                4'h3: bcd_to_seg = 7'b0110000; // 3
                4'h4: bcd_to_seg = 7'b0011001; // 4
                4'h5: bcd_to_seg = 7'b0010010; // 5
                4'h6: bcd_to_seg = 7'b0000010; // 6
                4'h7: bcd_to_seg = 7'b1111000; // 7
                4'h8: bcd_to_seg = 7'b0000000; // 8
                4'h9: bcd_to_seg = 7'b0010000; // 9
                4'hA: bcd_to_seg = 7'b0001000; // A
                4'hB: bcd_to_seg = 7'b0000011; // b
                4'hC: bcd_to_seg = 7'b1000110; // C
                4'hD: bcd_to_seg = 7'b0100001; // d
                4'hE: bcd_to_seg = 7'b0000110; // E (for Error)
                4'hF: bcd_to_seg = 7'b0001110; // F
                default: bcd_to_seg = 7'b1111111; // Blank
            endcase
        end
    endfunction

    // Refresh counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 0;
            digit_select <= 0;
        end else begin
            if (refresh_counter >= COUNT_MAX - 1) begin
                refresh_counter <= 0;
                digit_select <= digit_select + 1;
            end else begin
                refresh_counter <= refresh_counter + 1;
            end
        end
    end

    // Digit multiplexing
    reg [3:0] current_digit;
    always @(*) begin
        case (digit_select)
            2'd0: begin
                an = 4'b1110;  // Enable rightmost digit
                current_digit = digit0;
            end
            2'd1: begin
                an = 4'b1101;
                current_digit = digit1;
            end
            2'd2: begin
                an = 4'b1011;
                current_digit = digit2;
            end
            2'd3: begin
                an = 4'b0111;  // Enable leftmost digit
                current_digit = digit3;
            end
            default: begin
                an = 4'b1111;  // All off
                current_digit = 4'd0;
            end
        endcase
        seg = bcd_to_seg(current_digit);
    end
endmodule
