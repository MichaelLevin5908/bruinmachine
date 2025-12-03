// BCD to 7-segment decoder with support for special characters.
// Segments are active-low for Basys 3 board.
module bcd_to_7seg (
    input  wire [3:0] bcd,
    output reg  [6:0] seg  // {g, f, e, d, c, b, a}
);
    always @(*) begin
        case (bcd)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b1011111; // r (for "Err")
            4'hB: seg = 7'b1010100; // n (for "Done")
            4'hC: seg = 7'b1011100; // o (for "Done")
            4'hD: seg = 7'b0100001; // d (for "Done")
            4'hE: seg = 7'b0000110; // E (for "Err" and "Done")
            default: seg = 7'b1111111; // blank
        endcase
    end
endmodule
