`timescale 1ns/1ps
// 4-bit counter whose increment path is computed by the 8-bit prefix adder.
// The counter register still stores only four bits. The 4-bit count is
// zero-extended to 8 bits, then 8'd1 is added by prefix_adder_8bit.
// The low four sum bits provide modulo-16 increment behavior.
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
