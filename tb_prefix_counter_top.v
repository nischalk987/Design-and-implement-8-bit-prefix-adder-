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
    reg [3:0] previous_count;

    initial begin
        $dumpfile("prefix_counter_top.vcd");
        $dumpvars(0, tb_prefix_counter_top);

        // Reset clears count and puts the controller into HOLD.
        reset = 1'b1;
        run = 1'b0;
        @(posedge clk);
        check_count(4'h0, "synchronous reset clears count");
        if (seg !== 7'b1111110) begin
            $display("FAIL: zero display code incorrect, got %b", seg);
            $fatal(1);
        end
        $display("PASS: seven-segment decoder displays zero");

        // Deassert reset and request RUN. The FSM registers run_enable,
        // so wait for the state transition and then check two count updates.
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        @(posedge clk);
        #1;
        if (run_enable !== 1'b1) begin
            $display("FAIL: FSM did not enter RUN");
            $fatal(1);
        end
        check_count(4'h0, "counter still at zero on FSM transition edge");
        @(posedge clk);
        check_count(4'h1, "prefix-adder path increments to one");
        @(posedge clk);
        check_count(4'h2, "prefix-adder path increments to two");

        // Request HOLD; allow the registered FSM state to switch, then verify
        // the count remains stable for multiple rising clock edges.
        @(negedge clk);
        run = 1'b0;
        @(posedge clk);
        #1;
        if (run_enable !== 1'b0) begin
            $display("FAIL: FSM did not enter HOLD");
            $fatal(1);
        end
        check_count(4'h2, "count retained after entering HOLD");
        @(posedge clk);
        check_count(4'h2, "HOLD retains count on next edge");

        // Reset and enter RUN again to verify the full modulo-16 count cycle.
        @(negedge clk);
        reset = 1'b1;
        run = 1'b0;
        @(posedge clk);
        check_count(4'h0, "reset before wraparound test");
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        @(posedge clk); // FSM samples run and enters RUN
        #1;
        if (run_enable !== 1'b1) begin
            $display("FAIL: FSM failed to re-enter RUN");
            $fatal(1);
        end
        // Starting at 0, the following 16 enabled edges visit 1..15,0.
        for (i = 1; i <= 16; i = i + 1) begin
            @(posedge clk);
            check_count(i[3:0], "modulo-16 sequence");
        end

        // Check reset priority even if RUN is requested.
        @(negedge clk);
        reset = 1'b1;
        run = 1'b1;
        @(posedge clk);
        check_count(4'h0, "reset overrides RUN");

        $display("ALL TOP-LEVEL INTEGRATION TESTS PASSED");
        $finish;
    end
endmodule
