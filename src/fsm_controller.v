// Main vending machine FSM controlling credit, vending, and error handling.
module fsm_controller #(
    parameter integer MAX_CREDIT = 15
) (
    input  wire        clk,
    input  wire        rst,
    input  wire        coin_pulse,
    input  wire [7:0]  coin_value,
    input  wire        purchase_btn,
    input  wire [1:0]  item_select,
    input  wire [3:0]  stock_level,
    input  wire [7:0]  price,
    output reg  [7:0]  credit,
    output reg         vend_pulse,
    output reg  [2:0]  state,
    output reg         error_flag,
    output reg         change_returning,
    output reg  [7:0]  change_due
);
    localparam STATE_IDLE    = 3'd0;
    localparam STATE_CREDIT  = 3'd1;
    localparam STATE_CHECK   = 3'd2;
    localparam STATE_VEND    = 3'd3;
    localparam STATE_CHANGE  = 3'd4;
    localparam STATE_ERROR   = 3'd5;
    localparam STATE_THANK   = 3'd6;

    wire can_purchase;
    wire [7:0] next_credit_calc;
    wire [7:0] change_calc_val;

    change_calc calc(
        .credit(credit),
        .price(price),
        .can_purchase(can_purchase),
        .change_due(change_calc_val),
        .next_credit(next_credit_calc)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            credit           <= 0;
            vend_pulse       <= 1'b0;
            state            <= STATE_IDLE;
            error_flag       <= 1'b0;
            change_returning <= 1'b0;
            change_due       <= 0;
        end else begin
            vend_pulse       <= 1'b0;
            error_flag       <= 1'b0;
            change_returning <= 1'b0;

            case (state)
                STATE_IDLE, STATE_CREDIT: begin
                    if (coin_pulse) begin
                        if (credit + coin_value > MAX_CREDIT) begin
                            error_flag <= 1'b1;
                            state      <= STATE_ERROR;
                        end else begin
                            credit <= credit + coin_value;
                            state  <= STATE_CREDIT;
                        end
                    end else if (purchase_btn) begin
                        state <= STATE_CHECK;
                    end else begin
                        state <= STATE_IDLE;
                    end
                end
                STATE_CHECK: begin
                    if (stock_level == 0) begin
                        error_flag <= 1'b1;
                        state      <= STATE_ERROR;
                    end else if (!can_purchase) begin
                        error_flag <= 1'b1;
                        state      <= STATE_ERROR;
                    end else begin
                        state <= STATE_VEND;
                    end
                end
                STATE_VEND: begin
                    vend_pulse <= 1'b1;
                    state      <= STATE_THANK;
                end
                STATE_THANK: begin
                    state <= STATE_CHANGE;
                end
                STATE_CHANGE: begin
                    change_due       <= change_calc_val;
                    credit           <= next_credit_calc;
                    change_returning <= (change_calc_val != 0);
                    state            <= STATE_IDLE;
                end
                STATE_ERROR: begin
                    state <= STATE_IDLE;
                end
                default: state <= STATE_IDLE;
            endcase
        end
    end
endmodule
