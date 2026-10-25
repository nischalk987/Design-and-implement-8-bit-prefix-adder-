`timescale 1ns/1ps

module run_hold_fsm (
    input  wire clk,
    input  wire reset,
    input  wire run,
    output reg  state,
    output wire run_enable
);
    localparam HOLD = 1'b0;
    localparam RUN  = 1'b1;

    always @(posedge clk) begin
        if (reset)
            state <= HOLD;
        else if (run)
            state <= RUN;
        else
            state <= HOLD;
    end

    assign run_enable = (state == RUN);
endmodule
