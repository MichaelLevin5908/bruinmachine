// VGA Controller for 640x480 @ 60Hz
// Basys3 has 100MHz clock, we divide to ~25MHz for VGA pixel clock
module vga_controller (
    input  wire        clk,        // 100MHz system clock
    input  wire        rst,
    output reg  [9:0]  pixel_x,    // Current pixel X (0-799)
    output reg  [9:0]  pixel_y,    // Current pixel Y (0-524)
    output wire        video_on,   // High when in visible area
    output wire        hsync,
    output wire        vsync
);
    // VGA 640x480 @ 60Hz timing parameters
    localparam H_DISPLAY = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = H_DISPLAY + H_FRONT + H_SYNC + H_BACK; // 800

    localparam V_DISPLAY = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = V_DISPLAY + V_FRONT + V_SYNC + V_BACK; // 525

    // Clock divider: 100MHz -> 25MHz (divide by 4)
    reg [1:0] clk_div;
    wire pixel_tick = (clk_div == 2'b00);

    always @(posedge clk or posedge rst) begin
        if (rst)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1'b1;
    end

    // Horizontal and vertical counters
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel_x <= 0;
            pixel_y <= 0;
        end else if (pixel_tick) begin
            if (pixel_x == H_TOTAL - 1) begin
                pixel_x <= 0;
                if (pixel_y == V_TOTAL - 1)
                    pixel_y <= 0;
                else
                    pixel_y <= pixel_y + 1'b1;
            end else begin
                pixel_x <= pixel_x + 1'b1;
            end
        end
    end

    // Sync signals (active low)
    assign hsync = ~((pixel_x >= H_DISPLAY + H_FRONT) &&
                     (pixel_x < H_DISPLAY + H_FRONT + H_SYNC));
    assign vsync = ~((pixel_y >= V_DISPLAY + V_FRONT) &&
                     (pixel_y < V_DISPLAY + V_FRONT + V_SYNC));

    // Video on signal
    assign video_on = (pixel_x < H_DISPLAY) && (pixel_y < V_DISPLAY);
endmodule
