`timescale 1ns/1ps

module counter_prefix_integrated (
    input  wire       clk,
    input  wire       reset,
    input  wire       run,
    output reg  [3:0] count
);
    wire [7:0] count_extended;
    wire [7:0] incremented_sum;
    wire       adder_cout;
    wire [3:0] selected_next_count;

    assign count_extended = {4'b0000, count};

    prefix_adder_8bit increment_adder (
        .A(count_extended),
        .B(8'b00000001),
        .cin(1'b0),
        .sum(incremented_sum),
        .cout(adder_cout)
    );

    // RUN selects the increment result; HOLD selects the current count.
    assign selected_next_count = run ? incremented_sum[3:0] : count;

    // Synchronous active-high reset; the register holds when run=0.
    always @(posedge clk) begin
        if (reset)
            count <= 4'b0000;
        else
            count <= selected_next_count;
    end
endmodule
