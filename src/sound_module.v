// Square-wave tone generator for vending feedback.
module sound_module #(
    parameter integer CLOCK_HZ      = 100_000_000,
    parameter integer VEND_FREQ_HZ  = 1_000,
    parameter integer ERROR_FREQ_HZ = 300
) (
    input  wire clk,
    input  wire rst,
    input  wire vend_event,
    input  wire error_event,
    output reg  audio_out
);
    reg [31:0] divider_target;
    reg [31:0] counter;

    always @(*) begin
        if (vend_event)
            divider_target = CLOCK_HZ / (2 * VEND_FREQ_HZ);
        else if (error_event)
            divider_target = CLOCK_HZ / (2 * ERROR_FREQ_HZ);
        else
            divider_target = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter   <= 0;
            audio_out <= 1'b0;
        end else if (divider_target == 0) begin
            counter   <= 0;
            audio_out <= 1'b0;
        end else if (counter >= divider_target) begin
            counter   <= 0;
            audio_out <= ~audio_out;
        end else begin
            counter <= counter + 1'b1;
        end
    end
endmodule
