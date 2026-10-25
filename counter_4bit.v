`timescale 1ns/1ps
// 4-bit synchronous counter/register.
// reset is synchronous and active-high. When increment_enable is high,
// count increments on each rising edge; otherwise count is retained.
// Natural 4-bit arithmetic wraps 4'hF to 4'h0.
module counter_4bit (
    input  wire       clk,
    input  wire       reset,
    input  wire       increment_enable,
    output reg  [3:0] count
);
    always @(posedge clk) begin
        if (reset)
            count <= 4'b0000;
        else if (increment_enable)
            count <= count + 4'b0001;
        // else: no assignment, so the register holds its value.
    end
endmodule
