`timescale 1ns/1ps

module tb_counter_4bit;
    reg clk = 1'b0;
    reg reset = 1'b0;
    reg increment_enable = 1'b0;
    wire [3:0] count;

    counter_4bit dut (
        .clk(clk),
        .reset(reset),
        .increment_enable(increment_enable),
        .count(count)
    );

    always #5 clk = ~clk;

    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task check_count(input [3:0] expected, input [8*48-1:0] test_name);
        begin
            if (count !== expected) begin
                $display("FAIL: %0s expected=%h actual=%h at %0t",
                         test_name, expected, count, $time);
                $fatal(1);
            end else begin
                $display("PASS: %0s count=%h", test_name, count);
            end
        end
    endtask

    integer i;
    initial begin
        $dumpfile("counter_4bit.vcd");
        $dumpvars(0, tb_counter_4bit);

        // Synchronous active-high reset.
        reset = 1'b1;
        increment_enable = 1'b1;
        tick();
        check_count(4'h0, "synchronous reset clears count");

        // Reset deasserted; enabled edges increment.
        @(negedge clk);
        reset = 1'b0;
        increment_enable = 1'b1;
        tick();
        check_count(4'h1, "first increment");
        tick();
        check_count(4'h2, "second increment");

        // Disabled edges hold the prior value.
        @(negedge clk);
        increment_enable = 1'b0;
        tick();
        check_count(4'h2, "disabled counter holds");
        tick();
        check_count(4'h2, "continues holding");

        // Resume incrementing to 15 then verify wraparound to 0.
        @(negedge clk);
        increment_enable = 1'b1;
        for (i = 3; i <= 15; i = i + 1) begin
            tick();
            check_count(i[3:0], "increment sequence");
        end
        tick();
        check_count(4'h0, "wraps from 15 to 0");

        // Reset must take priority over the enable.
        @(negedge clk);
        reset = 1'b1;
        increment_enable = 1'b1;
        tick();
        check_count(4'h0, "reset priority over increment enable");

        $display("ALL 4-BIT COUNTER TESTS PASSED");
        $finish;
    end
endmodule
