`timescale 1ns/1ps
// Top-level design for the Level 2 counter + 8-bit prefix adder mini-project.
//
// RUN/HOLD FSM tracks the sampled control state. The raw run input controls
// the combinational counter MUX so RUN/HOLD takes effect on the next active
// counter edge without an extra enable-cycle delay. The 4-bit current count is
// zero-extended and incremented by the 8-bit prefix adder. The selected value is registered,
// and the registered count is decoded for a common-cathode seven-segment
// display (seg[6:0] = {a,b,c,d,e,f,g}).
module prefix_counter_top (
    input  wire       clk,
    input  wire       reset,
    input  wire       run,
    output wire [3:0] count,
    output wire [6:0] seg,
    output wire       run_enable,
    output wire       fsm_state
);
    wire [7:0] count_extended;
    wire [7:0] incremented_sum;
    wire       adder_cout;
    wire [3:0] next_count;

    // RUN/HOLD control state.
    run_hold_fsm control_fsm (
        .clk(clk),
        .reset(reset),
        .run(run),
        .state(fsm_state),
        .run_enable(run_enable)
    );

    // Extend current count to 8 bits and compute count + 1.
    assign count_extended = {4'b0000, count};

    prefix_adder_8bit increment_adder (
        .A(count_extended),
        .B(8'b00000001),
        .cin(1'b0),
        .sum(incremented_sum),
        .cout(adder_cout)
    );

    // MUX: HOLD selects current count; RUN selects low 4 sum bits.
    run_hold_mux_4bit next_count_mux (
        .count_current(count),
        .count_incremented(incremented_sum[3:0]),
        .run(run),
        .next_count(next_count)
    );

    // Four-bit register, synchronous active-high reset.
    reg [3:0] count_register;
    assign count = count_register;

    always @(posedge clk) begin
        if (reset)
            count_register <= 4'b0000;
        else
            count_register <= next_count;
    end

    // Decode the registered count for common-cathode display output.
    seven_segment_hex_decoder hex_decoder (
        .count(count),
        .seg(seg)
    );

endmodule
