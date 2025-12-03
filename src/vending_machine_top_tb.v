`timescale 1ns/1ps

module vending_machine_top_tb;
    reg clk = 0;
    reg rst = 1;
    reg btn_coin1 = 0;
    reg btn_coin2 = 0;
    reg btn_coin5 = 0;
    reg btn_purchase = 0;
    reg [1:0] sw_item = 0;
    reg restock = 0;

    wire [6:0] seg;
    wire [3:0] an;
    wire [3:0] stock_level;
    wire [7:0] leds;
    wire       audio_out;
    wire       audio_sd;

    // Clock generation
    always #5 clk = ~clk; // 100 MHz equivalent

    vending_machine_top dut(
        .clk(clk),
        .rst(rst),
        .btn_coin1(btn_coin1),
        .btn_coin2(btn_coin2),
        .btn_coin5(btn_coin5),
        .btn_purchase(btn_purchase),
        .sw_item(sw_item),
        .restock(restock),
        .seg(seg),
        .an(an),
        .stock_level(stock_level),
        .leds(leds),
        .audio_out(audio_out),
        .audio_sd(audio_sd)
    );

    // Shorten debounce delay for simulation
    defparam dut.db0.CNTR_MAX = 2;
    defparam dut.db1.CNTR_MAX = 2;
    defparam dut.db2.CNTR_MAX = 2;
    defparam dut.db3.CNTR_MAX = 2;

    // Speed up display refresh for simulation
    defparam dut.seg7.REFRESH_COUNT = 10;

    // Speed up thank you message for simulation (10 cycles instead of 100M)
    defparam dut.ctrl.THANK_YOU_CYCLES = 10;

    integer errors = 0;

    task pulse_coin5;
        begin
            btn_coin5 <= 1'b1;
            repeat (4) @(posedge clk);
            btn_coin5 <= 1'b0;
        end
    endtask

    task pulse_purchase;
        begin
            btn_purchase <= 1'b1;
            repeat (4) @(posedge clk);
            btn_purchase <= 1'b0;
        end
    endtask

    task check(input condition, input [256:0] message);
        begin
            if (!condition) begin
                errors = errors + 1;
                $display("[ERROR] %0t: %s", $time, message);
            end else begin
                $display("[OK] %0t: %s", $time, message);
            end
        end
    endtask

    initial begin
        // Apply reset
        repeat (3) @(posedge clk);
        rst <= 0;

        $display("=== Scenario 1: Insert $5, buy item0 (cost $3) ===");
        sw_item <= 2'd0;
        pulse_coin5();
        repeat (6) @(posedge clk);
        check(dut.ctrl.credit == 8'd5, "Credit increments to $5 after coin insertion");

        pulse_purchase();
        repeat (20) @(posedge clk);  // More cycles to account for THANK_YOU state

        check(dut.ctrl.vend_pulse === 1'b0, "Vend pulse completed without sticking high");
        check(dut.ctrl.credit == 8'd1, "Credit reduced to $1 after vend and change");
        check(dut.ctrl.change_due == 8'd1, "Change due of $1 computed");
        check(dut.inv.stock_level == 4'd4, "Inventory decremented for item0");

        $display("=== Scenario 2: Attempt purchase with insufficient funds ===");
        sw_item <= 2'd2; // price 6 when stock high (or 7 if stock low)
        pulse_purchase();
        @(posedge dut.ctrl.error_flag);
        @(posedge clk);
        check(dut.ctrl.state == 3'd5, "FSM enters ERROR state on insufficient funds");
        @(posedge clk);
        check(dut.ctrl.state == 3'd0, "FSM returns to IDLE after error handling");
        check(dut.ctrl.credit == 8'd1, "Credit preserved after failed purchase");

        if (errors == 0) begin
            $display("All testbench checks passed.");
        end else begin
            $display("Testbench completed with %0d errors.", errors);
        end

        $finish;
    end
endmodule
