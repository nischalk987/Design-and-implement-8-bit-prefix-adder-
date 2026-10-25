// 4-bit 2:1 RUN/HOLD multiplexer.
// Input 0 (count_current) is selected during HOLD (run=0).
// Input 1 (count_incremented) is selected during RUN (run=1).
module run_hold_mux_4bit (
    input  wire [3:0] count_current,
    input  wire [3:0] count_incremented,
    input  wire       run,
    output wire [3:0] next_count
);
    assign next_count = run ? count_incremented : count_current;
endmodule
