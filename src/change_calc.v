// Computes purchase feasibility, change due, and remaining credit.
module change_calc (
    input  wire [7:0] credit,
    input  wire [7:0] price,
    output wire        can_purchase,
    output wire [7:0]  change_due,
    output wire [7:0]  next_credit
);
    assign can_purchase = (credit >= price) && (price != 0);
    assign change_due   = (credit > price) ? (credit - price) : 8'd0;
    assign next_credit  = can_purchase ? (credit - price) : credit;
endmodule
