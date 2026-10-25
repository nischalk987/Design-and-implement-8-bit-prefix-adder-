`timescale 1ns/1ps

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

    end
endmodule
