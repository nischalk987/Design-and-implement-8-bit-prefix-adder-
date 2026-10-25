`timescale 1ns/1ps

module tb_run_hold_fsm;
    reg clk = 1'b0;
    reg reset = 1'b0;
    reg run = 1'b0;
    wire state;
    wire run_enable;

    localparam HOLD = 1'b0;
    localparam RUN  = 1'b1;

    run_hold_fsm dut (
        .clk(clk),
        .reset(reset),
        .run(run),
        .state(state),
        .run_enable(run_enable)
    );

    always #5 clk = ~clk;

    task expect_state(input reg expected, input [8*40-1:0] label_text);
        begin
            // State changes on posedge due to synchronous sequential logic.
            @(negedge clk);
            if (state !== expected || run_enable !== expected) begin
                $display("FAIL: %0s expected state/run_enable=%b, got %b/%b at %0t",
                         label_text, expected, state, run_enable, $time);
                $fatal(1);
            end else begin
                $display("PASS: %0s state=%b run_enable=%b",
                         label_text, state, run_enable);
            end
        end
    endtask

    initial begin
        $dumpfile("run_hold_fsm.vcd");
        $dumpvars(0, tb_run_hold_fsm);

        // Synchronous reset: assert reset before the next rising edge.
        reset = 1'b1;
        run = 1'b1;
        @(posedge clk);
        #1;
        if (state !== HOLD) begin
            $display("FAIL: synchronous reset did not select HOLD");
            $fatal(1);
        end
        $display("PASS: synchronous reset selects HOLD");

        // Deassert reset and check transitions based on run input.
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        expect_state(RUN, "run=1 enters RUN");

        run = 1'b0;
        expect_state(HOLD, "run=0 enters HOLD");

        run = 1'b1;
        expect_state(RUN, "HOLD to RUN transition");

        // Reset must take priority over run=1 on the active edge.
        @(negedge clk);
        reset = 1'b1;
        run = 1'b1;
        @(posedge clk);
        #1;
        if (state !== HOLD) begin
            $display("FAIL: reset did not override run");
            $fatal(1);
        end
        $display("PASS: reset overrides run");

        @(negedge clk);
        reset = 1'b0;
        run = 1'b0;
        expect_state(HOLD, "RUN to HOLD transition");

        $display("ALL RUN/HOLD FSM TESTS PASSED");
        $finish;
    end
endmodule
