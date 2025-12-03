// Produces 4-digit 7-segment encoded output for a seven-segment display.
module display_driver (
    input  wire [7:0] credit,
    input  wire [7:0] price,
    input  wire [7:0] change_due,
    input  wire [2:0] state,
    output reg  [6:0] digit3,
    output reg  [6:0] digit2,
    output reg  [6:0] digit1,
    output reg  [6:0] digit0
);
    localparam STATE_IDLE    = 3'd0;
    localparam STATE_CHANGE  = 3'd4;
    localparam STATE_ERROR   = 3'd5;
    localparam STATE_THANK   = 3'd6;

    // Function to convert 4-bit value to 7-segment encoding (active-low)
    function [6:0] to_7seg;
        input [3:0] data_in;
        begin
            case (data_in)
                // Hexadecimal digits 0-9
                4'h0: to_7seg = 7'b1000000; // 0
                4'h1: to_7seg = 7'b1111001; // 1
                4'h2: to_7seg = 7'b0100100; // 2
                4'h3: to_7seg = 7'b0110000; // 3
                4'h4: to_7seg = 7'b0011001; // 4
                4'h5: to_7seg = 7'b0010010; // 5
                4'h6: to_7seg = 7'b0000010; // 6
                4'h7: to_7seg = 7'b1111000; // 7
                4'h8: to_7seg = 7'b0000000; // 8
                4'h9: to_7seg = 7'b0010000; // 9

                // Letters for special displays
                4'hA: to_7seg = 7'b0101111; // 'r' (for "Err")
                4'hB: to_7seg = 7'b0000011; // 'b'
                4'hC: to_7seg = 7'b1000110; // 'C'
                4'hD: to_7seg = 7'b0100001; // 'd' (for "Done")
                4'hE: to_7seg = 7'b0000110; // 'E' (for "Err" or "donE")
                4'hF: to_7seg = 7'b1111111; // blank (all segments off)
                // Additional letters for "done" message
                // Using values 10-12 (decimal) for o, n, e_lower
                4'd10: to_7seg = 7'b1011100; // 'o' (segments c, d, e, g)
                4'd11: to_7seg = 7'b1010100; // 'n' (segments c, e, g)

                default: to_7seg = 7'b1111111; // All segments off for undefined inputs
            endcase
        end
    endfunction

    task automatic to_bcd;
        input  [7:0] value;
        output [3:0] h;
        output [3:0] t;
        output [3:0] o;
        integer v;
        begin
            v = value;
            h = v / 100;
            v = v % 100;
            t = v / 10;
            o = v % 10;
        end
    endtask

    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;

    always @(*) begin
        digit3 = 7'b1111111;  // blank
        digit2 = 7'b1111111;  // blank
        digit1 = 7'b1111111;  // blank
        digit0 = 7'b1111111;  // blank
        to_bcd(credit, hundreds, tens, ones);
        if (state == STATE_ERROR) begin
            // "Err"
            digit3 = to_7seg(4'hE);  // 'E'
            digit2 = to_7seg(4'hA);  // 'r'
            digit1 = to_7seg(4'hA);  // 'r'
            digit0 = to_7seg(4'hF);  // blank
        end else if (state == STATE_CHANGE && change_due != 0) begin
            to_bcd(change_due, hundreds, tens, ones);
            digit3 = to_7seg(hundreds);
            digit2 = to_7seg(tens);
            digit1 = to_7seg(ones);
            digit0 = to_7seg(4'd0);
        end else if (state == STATE_THANK) begin
            // "done"
            digit3 = to_7seg(4'hD);   // 'd'
            digit2 = to_7seg(4'd10);  // 'o'
            digit1 = to_7seg(4'd11);  // 'n'
            digit0 = to_7seg(4'hE);   // 'e'
        end else begin
            digit3 = to_7seg(hundreds);
            digit2 = to_7seg(tens);
            digit1 = to_7seg(ones);
            digit0 = to_7seg(4'd0);

            if (price != 0 && state != STATE_IDLE) begin
                to_bcd(price, hundreds, tens, ones);
                digit3 = to_7seg(hundreds);
                digit2 = to_7seg(tens);
                digit1 = to_7seg(ones);
                digit0 = to_7seg(4'd0);
            end

        end
    end
endmodule
