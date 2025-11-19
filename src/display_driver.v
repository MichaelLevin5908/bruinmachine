// Produces 4-digit BCD output for a seven-segment driver or simulation monitor.
module display_driver (
    input  wire [7:0] credit,
    input  wire [7:0] price,
    input  wire [7:0] change_due,
    input  wire [2:0] state,
    output reg  [3:0] digit3,
    output reg  [3:0] digit2,
    output reg  [3:0] digit1,
    output reg  [3:0] digit0
);
    localparam STATE_IDLE    = 3'd0;
    localparam STATE_ERROR   = 3'd5;
    localparam STATE_DONE    = 3'd6;

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
        digit3 = 4'd0;
        digit2 = 4'd0;
        digit1 = 4'd0;
        digit0 = 4'd0;
        to_bcd(credit, hundreds, tens, ones);
        if (state == STATE_ERROR) begin
            // "Err"
            digit3 = 4'hE;
            digit2 = 4'hE;
            digit1 = 4'h0;
            digit0 = 4'h0;
        end else if (state == STATE_DONE) begin
            // "Done"
            digit3 = 4'hD;
            digit2 = 4'h0;
            digit1 = 4'hE;
            digit0 = 4'h0;
        end else begin
            digit3 = hundreds;
            digit2 = tens;
            digit1 = ones;
            digit0 = 4'd0;

            if (price != 0 && state != STATE_IDLE) begin
                to_bcd(price, hundreds, tens, ones);
                digit3 = hundreds;
                digit2 = tens;
                digit1 = ones;
                digit0 = 4'd0;
            end

            if (change_due != 0 && state == STATE_DONE) begin
                to_bcd(change_due, hundreds, tens, ones);
                digit3 = hundreds;
                digit2 = tens;
                digit1 = ones;
                digit0 = 4'd0;
            end
        end
    end
endmodule
