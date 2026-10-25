`timescale 1ns/1ps

module tb_prefix_counter_top;
    reg clk = 1'b0;
    reg reset = 1'b0;
    reg run = 1'b0;
    wire [3:0] count;
    wire [6:0] seg;
    wire run_enable;
    wire fsm_state;

    prefix_counter_top dut (
        .clk(clk),
        .reset(reset),
        .run(run),
        .count(count),
        .seg(seg),
        .run_enable(run_enable),
        .fsm_state(fsm_state)
    );

    always #5 clk = ~clk;

    task expect_count(input [3:0] expected, input [8*48-1:0] label_text);
        begin
            @(negedge clk);
            if (count !== expected) begin
                $display("FAIL: %0s expected count=%h actual=%h",
                         label_text, expected, count);
                $fatal(1);
            end
            $display("PASS: %0s count=%h seg=%b", label_text, count, seg);
        end
    endtask

    integer i;
    initial begin
        $dumpfile("prefix_counter_top.vcd");
        $dumpvars(0, tb_prefix_counter_top);

        // Synchronous reset; controller returns to HOLD and count becomes 0.
        reset = 1'b1;
        run = 1'b0;
        @(posedge clk);
        #1;
        if (count !== 4'h0) begin
            $display("FAIL: reset did not clear top-level counter");
            $fatal(1);
        end
        if (seg !== 7'b1111110) begin
            $display("FAIL: reset count 0 decoded incorrectly: %b", seg);
            $fatal(1);
        end
        $display("PASS: reset count and display");

        // FSM is registered. Allow run control to enter RUN before checking count.
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        @(negedge clk);
        // First edge after run was sampled makes state RUN; next edge increments.
        @(negedge clk);
        if (run_enable !== 1'b1) begin
            $display("FAIL: run_enable did not assert for run=1");
            $fatal(1);
        end
        if (count !== 4'h1) begin
            $display("FAIL: count should be 1 after RUN settles, got %h", count);
            $fatal(1);
        end
        $display("PASS: RUN increments using prefix adder; count=%h", count);

        // Keep RUN for a few cycles.
        @(negedge clk);
        if (count !== 4'h2) begin
            $display("FAIL: expected count 2, got %h", count);
            $fatal(1);
        end
        $display("PASS: repeated RUN increment");

        // Deassert run; FSM leaves RUN after an edge, so one final increment can
        // occur before run_enable becomes HOLD. Then count must remain constant.
        run = 1'b0;
        @(negedge clk);
        @(negedge clk);
        i = count;
        @(negedge clk);
        if (count !== i[3:0]) begin
            $display("FAIL: counter changed after FSM entered HOLD");
            $fatal(1);
        end
        $display("PASS: HOLD preserves count=%h", count);

        // Reset again to restart a clean RUN sequence and exercise wraparound.
        reset = 1'b1;
        run = 1'b0;
        @(posedge clk);
        #1;
        if (count !== 4'h0) begin
            $display("FAIL: second reset did not clear counter");
            $fatal(1);
        end
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        // Wait for FSM to enter RUN.
        repeat (2) @(negedge clk);
        // Count is now incrementing; drive run and observe until count wraps.
        // Keep run asserted through 16 increments after registered RUN enable.
        for (i = 0; i < 18; i = i + 1)
            @(negedge clk);
        if (count > 4'hF) begin
            $display("FAIL: impossible counter value");
            $fatal(1);
        end
        $display("PASS: top-level operated through multiple modulo-16 cycles (count=%h)", count);

        $display("TOP-LEVEL INTEGRATION TESTS COMPLETED");
        $finish;
    end
endmodule
