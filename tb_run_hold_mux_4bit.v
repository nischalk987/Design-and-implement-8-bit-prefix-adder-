`timescale 1ns/1ps

module tb_run_hold_mux_4bit;
    reg  [3:0] count_current = 4'h0;
    reg  [3:0] count_incremented = 4'h0;
    reg        run = 1'b0;
    wire [3:0] next_count;

    run_hold_mux_4bit dut (
        .count_current(count_current),
        .count_incremented(count_incremented),
        .run(run),
        .next_count(next_count)
    );

    task check(input [3:0] expected, input [8*40-1:0] label_text);
        begin
            #1;
            if (next_count !== expected) begin
                $display("FAIL: %0s expected=%h actual=%h",
                         label_text, expected, next_count);
                $fatal(1);
            end else begin
                $display("PASS: %0s next_count=%h",
                         label_text, next_count);
            end
        end
    endtask

    initial begin
        $dumpfile("run_hold_mux_4bit.vcd");
        $dumpvars(0, tb_run_hold_mux_4bit);

        // HOLD (run=0) selects current count.
        count_current = 4'h5;
        count_incremented = 4'h6;
        run = 1'b0;
        check(4'h5, "run=0 selects current count");

        count_current = 4'hA;
        count_incremented = 4'hF;
        check(4'hA, "HOLD follows current count changes");

        // RUN (run=1) selects incremented count.
        run = 1'b1;
        check(4'hF, "run=1 selects incremented count");

        count_current = 4'h2;
        count_incremented = 4'h3;
        check(4'h3, "RUN follows incremented count changes");

        // Confirm the mux also selects the wrapped value when RUN is active.
        count_current = 4'hF;
        count_incremented = 4'h0;
        check(4'h0, "RUN selects wrapped 15-to-0 value");

        // Switch back to HOLD after wrap case.
        run = 1'b0;
        check(4'hF, "HOLD selects current value after RUN");

        $display("ALL RUN/HOLD MUX TESTS PASSED");
        $finish;
    end
endmodule
