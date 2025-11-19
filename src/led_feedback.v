// Drives LED indicators for inventory availability, change return, error blinking,
// and vend animation.
module led_feedback #(
    parameter integer ANIM_TICKS   = 6,
    parameter integer ERROR_TICKS  = 8
) (
    input  wire       clk,
    input  wire       rst,
    input  wire [2:0] state,
    input  wire       vend_event,
    input  wire       error_event,
    input  wire       change_returning,
    input  wire [7:0] change_due,
    input  wire [3:0] stock_available,
    input  wire [1:0] item_select,
    output reg  [7:0] leds
);
    localparam STATE_CHANGE = 3'd4;
    localparam STATE_DONE   = 3'd6;

    reg [23:0] slow_counter;
    wire slow_tick = (slow_counter == 0);
    wire blink_phase = slow_counter[23];

    reg [2:0]  anim_timer;
    reg [3:0]  anim_pattern;
    reg        anim_active;

    reg [3:0]  error_timer;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            slow_counter <= 0;
        end else begin
            slow_counter <= slow_counter + 1'b1;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            anim_timer   <= 0;
            anim_pattern <= 4'b0001;
            anim_active  <= 1'b0;
        end else begin
            if (vend_event) begin
                anim_active  <= 1'b1;
                anim_timer   <= ANIM_TICKS[2:0];
                anim_pattern <= 4'b0001 << item_select;
            end else if (anim_active && slow_tick) begin
                if (anim_timer == 0) begin
                    anim_active <= 1'b0;
                end else begin
                    anim_timer   <= anim_timer - 1'b1;
                    anim_pattern <= {anim_pattern[2:0], anim_pattern[3]};
                end
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            error_timer <= 0;
        end else begin
            if (error_event)
                error_timer <= ERROR_TICKS[3:0];
            else if (error_timer != 0 && slow_tick)
                error_timer <= error_timer - 1'b1;
        end
    end

    always @(*) begin
        leds[3:0] = stock_available;
        leds[7:4] = 4'b0000;

        if (error_timer != 0) begin
            leds[7:4] = blink_phase ? 4'b1111 : 4'b0000;
        end else if (anim_active) begin
            leds[7:4] = anim_pattern;
        end else if (change_returning || ((state == STATE_DONE || state == STATE_CHANGE) && change_due != 0)) begin
            leds[7:4] = change_due[3:0];
        end
    end
endmodule
