`timescale 1ns/1ps

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

    run_hold_fsm control_fsm (
        .clk(clk),
        .reset(reset),
        .run(run),
        .state(fsm_state),
        .run_enable(run_enable)
    );

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

    seven_segment_hex_decoder hex_decoder (
        .count(count),
        .seg(seg)
    );

endmodule
