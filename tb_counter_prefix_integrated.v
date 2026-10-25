`timescale 1ns/1ps

module tb_counter_prefix_integrated;
    reg clk = 1'b0;
    reg reset = 1'b0;
    reg run = 1'b0;
    wire [3:0] count;

    counter_prefix_integrated dut (
        .clk(clk),
        .reset(reset),
        .run(run),
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
        $dumpfile("counter_prefix_integrated.vcd");
        $dumpvars(0, tb_counter_prefix_integrated);

        // Reset is synchronous and has priority over RUN.
        reset = 1'b1;
        run = 1'b1;
        tick();
        check_count(4'h0, "reset clears count");

        // RUN increments using the prefix adder.
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        tick();
        check_count(4'h1, "RUN increments to 1");
        tick();
        check_count(4'h2, "RUN increments to 2");

        // HOLD keeps the registered value unchanged.
        @(negedge clk);
        run = 1'b0;
        tick();
        check_count(4'h2, "HOLD retains 2");
        tick();
        check_count(4'h2, "HOLD continues retaining 2");

        // Continue RUN through 15, then check modulo-16 wraparound.
        @(negedge clk);
        run = 1'b1;
        for (i = 3; i <= 15; i = i + 1) begin
            tick();
            check_count(i[3:0], "prefix-adder increment sequence");
        end
        tick();
        check_count(4'h0, "wraps 15 to 0 using low sum bits");

        // Check reset priority even when RUN is selected.
        @(negedge clk);
        reset = 1'b1;
        run = 1'b1;
        tick();
        check_count(4'h0, "reset overrides RUN");

        $display("ALL PREFIX-ADDER COUNTER INTEGRATION TESTS PASSED");
        $finish;
    end
endmodule
