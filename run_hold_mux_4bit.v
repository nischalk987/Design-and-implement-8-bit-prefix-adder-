module run_hold_mux_4bit (
    input  wire [3:0] count_current,
    input  wire [3:0] count_incremented,
    input  wire       run,
    output wire [3:0] next_count
);
    assign next_count = run ? count_incremented : count_current;
endmodule
