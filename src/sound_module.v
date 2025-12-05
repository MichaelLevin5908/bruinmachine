// Square-wave tone generator for vending feedback.
module sound_module #(
    parameter integer CLOCK_HZ       = 100_000_000,
    parameter integer ITEM0_FREQ_HZ  = 800,
    parameter integer ITEM1_FREQ_HZ  = 1000,
    parameter integer ITEM2_FREQ_HZ  = 1200,
    parameter integer ITEM3_FREQ_HZ  = 1400,
    parameter integer ERROR_FREQ_HZ  = 300,
    parameter integer TONE_MS        = 150,
    parameter integer TEST_MODE      = 1  // Set to 1 to play continuous 440Hz test tone
) (
    input  wire       clk,
    input  wire       rst,
    input  wire       vend_event,
    input  wire       error_event,
    input  wire [1:0] item_select,
    output reg        audio_out
);
    // Test mode: 440Hz continuous tone for debugging
    localparam integer TEST_FREQ_HZ = 440;
    localparam integer TEST_DIVIDER = CLOCK_HZ / (2 * TEST_FREQ_HZ);
    localparam integer TONE_CYCLES = (CLOCK_HZ / 1000) * TONE_MS;

    reg [31:0] divider_target;
    reg [31:0] counter;
    reg [31:0] tone_timer;
    reg        active;

    reg [31:0] vend_divider;

    always @(*) begin
        case (item_select)
            2'd0: vend_divider = CLOCK_HZ / (2 * ITEM0_FREQ_HZ);
            2'd1: vend_divider = CLOCK_HZ / (2 * ITEM1_FREQ_HZ);
            2'd2: vend_divider = CLOCK_HZ / (2 * ITEM2_FREQ_HZ);
            default: vend_divider = CLOCK_HZ / (2 * ITEM3_FREQ_HZ);
        endcase
    end

    always @(*) begin
        if (error_event)
            divider_target = CLOCK_HZ / (2 * ERROR_FREQ_HZ);
        else
            divider_target = vend_divider;
    end

    // Test mode counter
    reg [31:0] test_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter      <= 0;
            tone_timer   <= 0;
            active       <= 1'b0;
            audio_out    <= 1'b0;
            test_counter <= 0;
        end else if (TEST_MODE) begin
            // Test mode: continuous 440Hz tone
            if (test_counter >= TEST_DIVIDER) begin
                test_counter <= 0;
                audio_out    <= ~audio_out;
            end else begin
                test_counter <= test_counter + 1'b1;
            end
        end else begin
            if (error_event || vend_event) begin
                active     <= 1'b1;
                tone_timer <= TONE_CYCLES[31:0];
                counter    <= 0;
                audio_out  <= 1'b0;
            end else if (active) begin
                if (tone_timer == 0) begin
                    active    <= 1'b0;
                    audio_out <= 1'b0;
                    counter   <= 0;
                end else begin
                    tone_timer <= tone_timer - 1'b1;
                    if (counter >= divider_target) begin
                        counter   <= 0;
                        audio_out <= ~audio_out;
                    end else begin
                        counter <= counter + 1'b1;
                    end
                end
            end else begin
                audio_out <= 1'b0;
            end
        end
    end
endmodule
