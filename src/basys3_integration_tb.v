`timescale 1ns/1ps

// Integration testbench for Basys 3 top-level wrapper
module basys3_integration_tb;
    reg clk = 0;
    reg btnC = 1;  // Reset (active high)
    reg btnU = 0;  // $1 coin
    reg btnL = 0;  // $2 coin
    reg btnD = 0;  // $5 coin
    reg btnR = 0;  // Purchase
    reg [1:0] sw = 0;    // Item select
    reg sw15 = 0;  // Restock

    wire [6:0] seg;
    wire [3:0] an;
    wire [15:0] led;
    wire aud_sd;
    wire aud_pwm;

    // Clock generation (100 MHz)
    always #5 clk = ~clk;

    // DUT - Basys 3 wrapper
    basys3_vending_machine dut(
        .clk(clk),
        .btnC(btnC),
        .btnU(btnU),
        .btnL(btnL),
        .btnD(btnD),
        .btnR(btnR),
        .sw(sw),
        .sw15(sw15),
        .seg(seg),
        .an(an),
        .led(led),
        .aud_sd(aud_sd),
        .aud_pwm(aud_pwm)
    );

    // Override debounce for faster simulation
    defparam dut.core.db0.CNTR_MAX = 2;
    defparam dut.core.db1.CNTR_MAX = 2;
    defparam dut.core.db2.CNTR_MAX = 2;
    defparam dut.core.db3.CNTR_MAX = 2;

    integer errors = 0;

    task check;
        input condition;
        input [256*8-1:0] message;
        begin
            if (!condition) begin
                errors = errors + 1;
                $display("[ERROR] %0t: %s", $time, message);
            end else begin
                $display("[OK] %0t: %s", $time, message);
            end
        end
    endtask

    task press_button;
        input [2:0] btn_id;  // 0=U($1), 1=L($2), 2=D($5), 3=R(purchase)
        begin
            case (btn_id)
                0: btnU = 1;
                1: btnL = 1;
                2: btnD = 1;
                3: btnR = 1;
            endcase
            repeat (4) @(posedge clk);
            btnU = 0;
            btnL = 0;
            btnD = 0;
            btnR = 0;
        end
    endtask

    initial begin
        $display("=== Basys 3 Integration Test ===");

        // Apply reset
        repeat (3) @(posedge clk);
        btnC = 0;
        repeat (2) @(posedge clk);

        $display("\n=== Test 1: Button Mapping ===");
        // Test $1 coin (btnU)
        press_button(0);
        repeat (6) @(posedge clk);
        check(dut.core.credit == 8'd1, "BTNU correctly adds $1");

        // Test $2 coin (btnL)
        press_button(1);
        repeat (6) @(posedge clk);
        check(dut.core.credit == 8'd3, "BTNL correctly adds $2");

        // Test $5 coin (btnD)
        press_button(2);
        repeat (6) @(posedge clk);
        check(dut.core.credit == 8'd8, "BTND correctly adds $5");

        $display("\n=== Test 2: 7-Segment Display ===");
        // Credit should be displayed
        check(dut.display.digit3 == 4'd0, "Display digit3 shows correct tens");
        check(dut.display.digit2 == 4'd0, "Display digit2 shows correct tens");
        check(dut.display.digit1 == 4'd8, "Display digit1 shows credit ones");
        check(seg != 7'b1111111, "7-segment pattern is not blank");
        check(an != 4'b1111, "At least one anode is enabled");

        $display("\n=== Test 3: Item Selection & Purchase ===");
        sw = 2'd0;  // Select item 0 (price $3)
        repeat (2) @(posedge clk);
        press_button(3);  // Purchase
        repeat (10) @(posedge clk);

        check(dut.core.ctrl.credit == 8'd5, "Credit correctly reduced to $5 after purchase");
        check(dut.core.ctrl.change_due == 8'd5, "Change due calculated correctly");
        check(dut.core.inv.stock_level == 4'd4, "Inventory decremented to 4");

        $display("\n=== Test 4: LED Stock Indicators ===");
        // Stock availability indicators are on LED11-8 (one bit per item)
        check(led[8] == 1'b1, "LED8 shows item0 in stock");
        check(led[9] == 1'b1, "LED9 shows item1 in stock");
        check(led[10] == 1'b1, "LED10 shows item2 in stock");
        check(led[11] == 1'b1, "LED11 shows item3 in stock");
        // LED3-0 shows selected item's stock count
        check(led[3:0] == 4'd4, "LED3-0 shows item0 stock count (4)");

        $display("\n=== Test 5: Audio Output ===");
        check(aud_sd == 1'b1, "Audio amplifier enabled (shutdown inactive)");
        // Audio PWM should have toggled during vending

        $display("\n=== Test 6: Error State ===");
        sw = 2'd2;  // Select item 2 (price $6)
        press_button(3);  // Purchase (insufficient funds)
        @(posedge dut.core.ctrl.error_flag);
        @(posedge clk);
        check(dut.core.ctrl.state == 3'd5, "FSM enters ERROR state");
        check(dut.display.digit3 == 4'hE, "Display shows 'E' for error");
        repeat (2) @(posedge clk);
        check(dut.core.ctrl.credit == 8'd5, "Credit preserved after error");

        $display("\n=== Test 7: Restock Function ===");
        // Buy some items to reduce stock
        sw = 2'd1;  // Item 1 (starts at stock level 5)
        btnC = 1;  // Reset system
        repeat (5) @(posedge clk);
        btnC = 0;
        repeat (5) @(posedge clk);

        // Add credit (starting from $0 after reset)
        repeat (3) press_button(2);  // Add $15 total
        repeat (10) @(posedge clk);

        $display("  Initial stock: %0d, credit: $%0d", dut.core.inv.stock_level, dut.core.ctrl.credit);

        // Buy 3 items
        repeat (3) begin
            press_button(3);
            repeat (20) @(posedge clk);  // Wait for FSM to complete
            $display("  Stock: %0d, credit: $%0d", dut.core.inv.stock_level, dut.core.ctrl.credit);
        end

        check(dut.core.inv.stock_level == 4'd2, "Item 1 stock reduced to 2 after 3 purchases");
        check(led[9] == 1'b1, "LED9 still shows item1 in stock (stock>0)");

        // Restock
        sw15 = 1;
        repeat (2) @(posedge clk);
        sw15 = 0;
        repeat (2) @(posedge clk);

        check(dut.core.inv.stock_level == 4'd5, "Inventory restocked to 5");
        check(led[9] == 1'b1, "LED9 shows item1 in stock after restock");

        // Summary
        $display("\n=== Test Summary ===");
        if (errors == 0) begin
            $display("ALL TESTS PASSED! Basys 3 wrapper is fully functional.");
        end else begin
            $display("Tests completed with %0d errors.", errors);
        end

        $finish;
    end
endmodule
