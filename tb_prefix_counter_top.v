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

    task check_count(input [3:0] expected, input [8*48-1:0] label_text);
        begin
            #1;
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

        // Synchronous reset clears count and resets the FSM to HOLD.
        reset = 1'b1;
        run = 1'b0;
        @(posedge clk);
        check_count(4'h0, "synchronous reset clears count");
        if (seg !== 7'b1111110) begin
            $display("FAIL: zero display pattern incorrect: %b", seg);
            $fatal(1);
        end
        $display("PASS: seven-segment decoder displays zero");

        // RUN is applied directly to the MUX, so counting starts on the next
        // rising edge. FSM state/run_enable separately track sampled control.
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        @(posedge clk);
        check_count(4'h1, "RUN increments to one");
        if (fsm_state !== 1'b1 || run_enable !== 1'b1) begin
            $display("FAIL: FSM state did not register RUN");
            $fatal(1);
        end
        @(posedge clk);
        check_count(4'h2, "RUN increments to two");

        // HOLD is effective at the next rising edge; no extra increment occurs.
        @(negedge clk);
        run = 1'b0;
        @(posedge clk);
        check_count(4'h2, "HOLD preserves count immediately");
        if (fsm_state !== 1'b0 || run_enable !== 1'b0) begin
            $display("FAIL: FSM state did not register HOLD");
            $fatal(1);
        end
        @(posedge clk);
        check_count(4'h2, "HOLD continues to preserve count");

        // Reset and then verify the complete modulo-16 sequence.
        @(negedge clk);
        reset = 1'b1;
        run = 1'b0;
        @(posedge clk);
        check_count(4'h0, "reset before wraparound");
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        for (i = 1; i <= 16; i = i + 1) begin
            @(posedge clk);
            check_count(i[3:0], "modulo-16 prefix-adder sequence");
        end

        // Synchronous reset must clear count even with RUN selected.
        @(negedge clk);
        reset = 1'b1;
        run = 1'b1;
        @(posedge clk);
        check_count(4'h0, "reset overrides RUN");

        $display("ALL TOP-LEVEL INTEGRATION TESTS PASSED");
        $finish;
    end
endmodule
