// Simple debouncer for active-high inputs.
module debounce #(
    parameter integer CNTR_MAX = 25000
) (
    input  wire clk,
    input  wire rst,
    input  wire noisy,
    output reg  clean
);
    reg [$clog2(CNTR_MAX):0] counter;
    reg sync_0;
    reg sync_1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_0   <= 1'b0;
            sync_1   <= 1'b0;
        end else begin
            sync_0   <= noisy;
            sync_1   <= sync_0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            clean   <= 1'b0;
        end else if (sync_1 == clean) begin
            counter <= 0;
        end else begin
            if (counter == CNTR_MAX) begin
                clean   <= sync_1;
                counter <= 0;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
endmodule
