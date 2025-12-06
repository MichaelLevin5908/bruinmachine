// VGA Balance Display - Super simple version
// Just colored bars and state indicators
module vga_balance_display (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  credit,
    input  wire [7:0]  price,
    input  wire [2:0]  state,
    input  wire [9:0]  pixel_x,
    input  wire [9:0]  pixel_y,
    input  wire        video_on,
    output reg  [3:0]  vga_r,
    output reg  [3:0]  vga_g,
    output reg  [3:0]  vga_b
);
    // States
    localparam STATE_IDLE   = 3'd0;
    localparam STATE_CREDIT = 3'd1;
    localparam STATE_VEND   = 3'd3;
    localparam STATE_ERROR  = 3'd5;

    // Credit bar: each $1 = 20 pixels wide (max 15 = 300px)
    wire [9:0] credit_width = {2'b0, credit[7:0]} * 10'd20;
    wire [9:0] price_width  = {2'b0, price[7:0]} * 10'd20;

    // Regions
    wire in_title    = (pixel_y >= 40) && (pixel_y < 80);
    wire in_credit   = (pixel_y >= 150) && (pixel_y < 200) &&
                       (pixel_x >= 100) && (pixel_x < 100 + credit_width);
    wire in_price    = (pixel_y >= 280) && (pixel_y < 330) &&
                       (pixel_x >= 100) && (pixel_x < 100 + price_width);
    wire in_status   = (pixel_y >= 400) && (pixel_y < 460) &&
                       (pixel_x >= 200) && (pixel_x < 440);

    always @(*) begin
        if (!video_on) begin
            vga_r = 4'h0;
            vga_g = 4'h0;
            vga_b = 4'h0;
        end else if (in_title) begin
            // Blue title bar
            vga_r = 4'h0;
            vga_g = 4'h0;
            vga_b = 4'hF;
        end else if (in_credit) begin
            // Green credit bar
            vga_r = 4'h0;
            vga_g = 4'hF;
            vga_b = 4'h0;
        end else if (in_price) begin
            // Yellow price bar
            vga_r = 4'hF;
            vga_g = 4'hF;
            vga_b = 4'h0;
        end else if (in_status) begin
            case (state)
                STATE_IDLE:   begin vga_r = 4'h8; vga_g = 4'h8; vga_b = 4'h8; end
                STATE_CREDIT: begin vga_r = 4'h0; vga_g = 4'hA; vga_b = 4'h0; end
                STATE_VEND:   begin vga_r = 4'h0; vga_g = 4'hF; vga_b = 4'h0; end
                STATE_ERROR:  begin vga_r = 4'hF; vga_g = 4'h0; vga_b = 4'h0; end
                default:      begin vga_r = 4'h4; vga_g = 4'h4; vga_b = 4'h4; end
            endcase
        end else begin
            // Dark background
            vga_r = 4'h1;
            vga_g = 4'h1;
            vga_b = 4'h2;
        end
    end
endmodule
