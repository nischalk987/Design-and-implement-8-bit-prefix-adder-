

`timescale 1ns/1ps

module tb_waveform;

    reg clk = 1'b0;
    reg reset = 1'b1;
    reg run = 1'b0;

    wire [3:0] count;
    wire [6:0] seg;
    wire run_enable;
    wire fsm_state;

    // DUT: Prefix Counter Top
    prefix_counter_top dut (
        .clk(clk),
        .reset(reset),
        .run(run),
        .count(count),
        .seg(seg),
        .run_enable(run_enable),
        .fsm_state(fsm_state)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin

        // Waveform dump
        $dumpfile("counter_waveform.vcd");
        $dumpvars(0, tb_waveform);

        // Initial control values
        reset = 1'b1;
        run   = 1'b0;

        // RESET: hold for two clock cycles
        repeat (2) @(negedge clk);

        // Release reset
        reset = 1'b0;

        // RUN: counter increments
        run = 1'b1;
        repeat (5) @(negedge clk);

        // HOLD: counter remains unchanged
        run = 1'b0;
        repeat (3) @(negedge clk);

        // RUN resumes
        run = 1'b1;
        repeat (5) @(negedge clk);

        // Stop counting
        run = 1'b0;
        repeat (2) @(negedge clk);

        // End simulation
        $finish;

    end

endmodule
