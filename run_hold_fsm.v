`timescale 1ns/1ps
// Two-state RUN/HOLD controller for the Level 2 counter project.
//
// State encoding:
//   HOLD = 1'b0
//   RUN  = 1'b1
//
// A synchronous active-high reset returns the controller to HOLD.
// Otherwise, run=1 selects RUN and run=0 selects HOLD.
// The controller exports run_enable so downstream counter logic can
// increment only in RUN; the FSM itself does not store the counter value.
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
