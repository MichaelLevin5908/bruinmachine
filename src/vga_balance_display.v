// VGA Balance Display - Shows credit balance on screen
// Displays "$XX" format with large digits
module vga_balance_display (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  credit,      // Current credit/balance (0-15)
    input  wire [7:0]  price,       // Current item price
    input  wire [2:0]  state,       // FSM state
    input  wire [9:0]  pixel_x,
    input  wire [9:0]  pixel_y,
    input  wire        video_on,
    output reg  [3:0]  vga_r,
    output reg  [3:0]  vga_g,
    output reg  [3:0]  vga_b
);
    // States from FSM
    localparam STATE_IDLE   = 3'd0;
    localparam STATE_CREDIT = 3'd1;
    localparam STATE_VEND   = 3'd3;
    localparam STATE_ERROR  = 3'd5;

    // Display regions (centered on 640x480)
    localparam TITLE_Y     = 100;
    localparam CREDIT_Y    = 200;
    localparam PRICE_Y     = 300;
    localparam CHAR_WIDTH  = 32;
    localparam CHAR_HEIGHT = 48;
    localparam START_X     = 200;

    // Character ROM for digits 0-9 and $ (8x8 scaled up)
    // Each digit is 8 rows of 8 bits
    reg [7:0] char_rom [0:10][0:7];

    initial begin
        // '0'
        char_rom[0][0] = 8'b00111100;
        char_rom[0][1] = 8'b01100110;
        char_rom[0][2] = 8'b01101110;
        char_rom[0][3] = 8'b01110110;
        char_rom[0][4] = 8'b01100110;
        char_rom[0][5] = 8'b01100110;
        char_rom[0][6] = 8'b00111100;
        char_rom[0][7] = 8'b00000000;
        // '1'
        char_rom[1][0] = 8'b00011000;
        char_rom[1][1] = 8'b00111000;
        char_rom[1][2] = 8'b00011000;
        char_rom[1][3] = 8'b00011000;
        char_rom[1][4] = 8'b00011000;
        char_rom[1][5] = 8'b00011000;
        char_rom[1][6] = 8'b01111110;
        char_rom[1][7] = 8'b00000000;
        // '2'
        char_rom[2][0] = 8'b00111100;
        char_rom[2][1] = 8'b01100110;
        char_rom[2][2] = 8'b00000110;
        char_rom[2][3] = 8'b00011100;
        char_rom[2][4] = 8'b00110000;
        char_rom[2][5] = 8'b01100000;
        char_rom[2][6] = 8'b01111110;
        char_rom[2][7] = 8'b00000000;
        // '3'
        char_rom[3][0] = 8'b00111100;
        char_rom[3][1] = 8'b01100110;
        char_rom[3][2] = 8'b00000110;
        char_rom[3][3] = 8'b00011100;
        char_rom[3][4] = 8'b00000110;
        char_rom[3][5] = 8'b01100110;
        char_rom[3][6] = 8'b00111100;
        char_rom[3][7] = 8'b00000000;
        // '4'
        char_rom[4][0] = 8'b00001100;
        char_rom[4][1] = 8'b00011100;
        char_rom[4][2] = 8'b00101100;
        char_rom[4][3] = 8'b01001100;
        char_rom[4][4] = 8'b01111110;
        char_rom[4][5] = 8'b00001100;
        char_rom[4][6] = 8'b00001100;
        char_rom[4][7] = 8'b00000000;
        // '5'
        char_rom[5][0] = 8'b01111110;
        char_rom[5][1] = 8'b01100000;
        char_rom[5][2] = 8'b01111100;
        char_rom[5][3] = 8'b00000110;
        char_rom[5][4] = 8'b00000110;
        char_rom[5][5] = 8'b01100110;
        char_rom[5][6] = 8'b00111100;
        char_rom[5][7] = 8'b00000000;
        // '6'
        char_rom[6][0] = 8'b00111100;
        char_rom[6][1] = 8'b01100000;
        char_rom[6][2] = 8'b01111100;
        char_rom[6][3] = 8'b01100110;
        char_rom[6][4] = 8'b01100110;
        char_rom[6][5] = 8'b01100110;
        char_rom[6][6] = 8'b00111100;
        char_rom[6][7] = 8'b00000000;
        // '7'
        char_rom[7][0] = 8'b01111110;
        char_rom[7][1] = 8'b00000110;
        char_rom[7][2] = 8'b00001100;
        char_rom[7][3] = 8'b00011000;
        char_rom[7][4] = 8'b00110000;
        char_rom[7][5] = 8'b00110000;
        char_rom[7][6] = 8'b00110000;
        char_rom[7][7] = 8'b00000000;
        // '8'
        char_rom[8][0] = 8'b00111100;
        char_rom[8][1] = 8'b01100110;
        char_rom[8][2] = 8'b01100110;
        char_rom[8][3] = 8'b00111100;
        char_rom[8][4] = 8'b01100110;
        char_rom[8][5] = 8'b01100110;
        char_rom[8][6] = 8'b00111100;
        char_rom[8][7] = 8'b00000000;
        // '9'
        char_rom[9][0] = 8'b00111100;
        char_rom[9][1] = 8'b01100110;
        char_rom[9][2] = 8'b01100110;
        char_rom[9][3] = 8'b00111110;
        char_rom[9][4] = 8'b00000110;
        char_rom[9][5] = 8'b00001100;
        char_rom[9][6] = 8'b00111000;
        char_rom[9][7] = 8'b00000000;
        // '$'
        char_rom[10][0] = 8'b00011000;
        char_rom[10][1] = 8'b00111110;
        char_rom[10][2] = 8'b01100000;
        char_rom[10][3] = 8'b00111100;
        char_rom[10][4] = 8'b00000110;
        char_rom[10][5] = 8'b01111100;
        char_rom[10][6] = 8'b00011000;
        char_rom[10][7] = 8'b00000000;
    end

    // Convert credit to BCD digits
    wire [3:0] credit_tens = credit / 10;
    wire [3:0] credit_ones = credit % 10;
    wire [3:0] price_tens  = price / 10;
    wire [3:0] price_ones  = price % 10;

    // Check if pixel is within a character cell and get the pixel value
    function is_char_pixel;
        input [9:0] px, py;
        input [9:0] char_x, char_y;
        input [3:0] char_idx;
        reg [2:0] row, col;
        begin
            if (px >= char_x && px < char_x + CHAR_WIDTH &&
                py >= char_y && py < char_y + CHAR_HEIGHT) begin
                col = (px - char_x) / 4;  // Scale 8 pixels to 32
                row = (py - char_y) / 6;  // Scale 8 pixels to 48
                is_char_pixel = char_rom[char_idx][row][7-col];
            end else begin
                is_char_pixel = 0;
            end
        end
    endfunction

    // Pixel color generation
    wire in_credit_dollar = is_char_pixel(pixel_x, pixel_y, START_X, CREDIT_Y, 10);
    wire in_credit_tens   = is_char_pixel(pixel_x, pixel_y, START_X + CHAR_WIDTH, CREDIT_Y, credit_tens);
    wire in_credit_ones   = is_char_pixel(pixel_x, pixel_y, START_X + CHAR_WIDTH*2, CREDIT_Y, credit_ones);

    wire in_price_dollar  = is_char_pixel(pixel_x, pixel_y, START_X, PRICE_Y, 10);
    wire in_price_tens    = is_char_pixel(pixel_x, pixel_y, START_X + CHAR_WIDTH, PRICE_Y, price_tens);
    wire in_price_ones    = is_char_pixel(pixel_x, pixel_y, START_X + CHAR_WIDTH*2, PRICE_Y, price_ones);

    wire in_credit_text = in_credit_dollar || in_credit_tens || in_credit_ones;
    wire in_price_text  = in_price_dollar || in_price_tens || in_price_ones;

    // Title bar region
    wire in_title = (pixel_y >= 50 && pixel_y < 90);

    // Color selection based on state
    always @(*) begin
        if (!video_on) begin
            vga_r = 4'h0;
            vga_g = 4'h0;
            vga_b = 4'h0;
        end else if (in_title) begin
            // Blue title bar
            vga_r = 4'h2;
            vga_g = 4'h2;
            vga_b = 4'hA;
        end else if (in_credit_text) begin
            // Green credit display
            vga_r = 4'h0;
            vga_g = 4'hF;
            vga_b = 4'h0;
        end else if (in_price_text) begin
            // Yellow price display
            vga_r = 4'hF;
            vga_g = 4'hF;
            vga_b = 4'h0;
        end else if (state == STATE_ERROR) begin
            // Red background on error
            vga_r = 4'h4;
            vga_g = 4'h0;
            vga_b = 4'h0;
        end else if (state == STATE_VEND) begin
            // Green background on vend
            vga_r = 4'h0;
            vga_g = 4'h2;
            vga_b = 4'h0;
        end else begin
            // Dark blue background
            vga_r = 4'h1;
            vga_g = 4'h1;
            vga_b = 4'h2;
        end
    end
endmodule
