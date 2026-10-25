`timescale 1ns/1ps

module tb_full_system;
    reg clk = 1'b0;
    reg reset = 1'b0;
    reg run = 1'b0;
    wire [3:0] count;
    wire [6:0] seg;
    wire run_enable;
    wire fsm_state;

    integer errors = 0;
    integer i;
    reg [3:0] expected_count;

    prefix_counter_top dut (
        .clk(clk),
        .reset(reset),
        .run(run),
        .count(count),
        .seg(seg),
        .run_enable(run_enable),
        .fsm_state(fsm_state)
    );

    always #5 clk = ~clk;

    function [6:0] expected_segments(input [3:0] value);
        begin
            case (value)
                4'h0: expected_segments = 7'b1111110;
                4'h1: expected_segments = 7'b0110000;
                4'h2: expected_segments = 7'b1101101;
                4'h3: expected_segments = 7'b1111001;
                4'h4: expected_segments = 7'b0110011;
                4'h5: expected_segments = 7'b1011011;
                4'h6: expected_segments = 7'b1011111;
                4'h7: expected_segments = 7'b1110000;
                4'h8: expected_segments = 7'b1111111;
                4'h9: expected_segments = 7'b1111011;
                4'hA: expected_segments = 7'b1110111;
                4'hB: expected_segments = 7'b0011111;
                4'hC: expected_segments = 7'b1001110;
                4'hD: expected_segments = 7'b0111101;
                4'hE: expected_segments = 7'b1001111;
                4'hF: expected_segments = 7'b1000111;
                default: expected_segments = 7'b0000000;
            endcase
        end
    endfunction

    task check_count(input [3:0] expected, input [8*56-1:0] label_text);
        begin
            #1;
            if (^count === 1'bx) begin
                $display("FAIL: %0s count contains X/Z: %b", label_text, count);
                errors = errors + 1;
            end else if (count !== expected) begin
                $display("FAIL: %0s expected count=%h actual=%h",
                         label_text, expected, count);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s count=%h", label_text, count);
            end

            if (^seg === 1'bx) begin
                $display("FAIL: %0s seg contains X/Z: %b", label_text, seg);
                errors = errors + 1;
            end else if (seg !== expected_segments(expected)) begin
                $display("FAIL: %0s expected seg=%b actual=%b",
                         label_text, expected_segments(expected), seg);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s display=%b", label_text, seg);
            end

            if ((^run_enable === 1'bx) || (^fsm_state === 1'bx)) begin
                $display("FAIL: FSM debug outputs contain X/Z");
                errors = errors + 1;
            end
        end
    endtask

    // Independent combinational check of the actual prefix-adder module.
    reg [7:0] adder_a;
    reg [7:0] adder_b;
    reg adder_cin;
    wire [7:0] adder_sum;
    wire adder_cout;
    reg [8:0] expected_add;
    integer a;
    integer b;
    integer c;
    integer adder_errors = 0;

    prefix_adder_8bit standalone_adder (
        .A(adder_a),
        .B(adder_b),
        .cin(adder_cin),
        .sum(adder_sum),
        .cout(adder_cout)
    );

    task check_adder(input [7:0] av, input [7:0] bv, input cinv);
        begin
            adder_a = av;
            adder_b = bv;
            adder_cin = cinv;
            expected_add = {1'b0, av} + {1'b0, bv} + cinv;
            #1;
            if ((^adder_sum === 1'bx) || (adder_cout === 1'bx)) begin
                $display("FAIL ADDER: X/Z for A=%h B=%h cin=%b", av, bv, cinv);
                adder_errors = adder_errors + 1;
            end else if ({adder_cout, adder_sum} !== expected_add) begin
                $display("FAIL ADDER: A=%h B=%h cin=%b expected=%h actual=%h",
                         av, bv, cinv, expected_add, {adder_cout, adder_sum});
                adder_errors = adder_errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("full_system.vcd");
        $dumpvars(0, tb_full_system);
        adder_a = 0;
        adder_b = 0;
        adder_cin = 0;

        $display("=== Independent 8-bit prefix-adder directed checks ===");
        check_adder(8'h00, 8'h00, 1'b0);
        check_adder(8'h00, 8'h00, 1'b1);
        check_adder(8'h01, 8'h01, 1'b0);
        check_adder(8'h0F, 8'h01, 1'b0);
        check_adder(8'h55, 8'hAA, 1'b0);
        check_adder(8'hFF, 8'h01, 1'b0);
        check_adder(8'hFF, 8'hFF, 1'b1);
        check_adder(8'h7F, 8'h01, 1'b0);

        $display("=== Exhaustive 8-bit prefix-adder verification ===");
        for (a = 0; a < 256; a = a + 1) begin
            for (b = 0; b < 256; b = b + 1) begin
                check_adder(a[7:0], b[7:0], 1'b0);
                check_adder(a[7:0], b[7:0], 1'b1);
            end
        end
        if (adder_errors != 0) begin
            $display("FAIL: standalone adder errors=%0d", adder_errors);
            $fatal(1);
        end
        $display("PASS: all 131072 prefix-adder cases matched");

        $display("=== Full-system RUN/HOLD counter/display checks ===");
        // Synchronous active-high reset.
        reset = 1'b1;
        run = 1'b0;
        @(posedge clk);
        check_count(4'h0, "reset sets count to zero");

        // RUN increments once per active edge; prefix-adder output is selected.
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        expected_count = 4'h0;
        for (i = 1; i <= 5; i = i + 1) begin
            @(posedge clk);
            expected_count = expected_count + 4'h1;
            check_count(expected_count, "RUN increment");
        end

        // HOLD preserves current value for several active clock edges.
        @(negedge clk);
        run = 1'b0;
        expected_count = count;
        repeat (3) begin
            @(posedge clk);
            check_count(expected_count, "HOLD preserves current count");
        end

        // Resume from the held value and check it increments again.
        @(negedge clk);
        run = 1'b1;
        @(posedge clk);
        expected_count = expected_count + 4'h1;
        check_count(expected_count, "RUN resumes from held value");

        // Reset and test the complete 0..15 then 0 wrap sequence.
        @(negedge clk);
        reset = 1'b1;
        run = 1'b0;
        @(posedge clk);
        check_count(4'h0, "reset before wrap test");
        @(negedge clk);
        reset = 1'b0;
        run = 1'b1;
        expected_count = 4'h0;
        for (i = 1; i <= 16; i = i + 1) begin
            @(posedge clk);
            expected_count = expected_count + 4'h1;
            check_count(expected_count, "wraparound sequence");
        end
        if (expected_count !== 4'h0) begin
            $display("FAIL: reference counter did not wrap to zero");
            errors = errors + 1;
        end

        // Reset takes priority even with RUN asserted.
        @(negedge clk);
        reset = 1'b1;
        run = 1'b1;
        @(posedge clk);
        check_count(4'h0, "reset priority over RUN");

        if ((errors == 0) && (adder_errors == 0)) begin
            $display("ALL FULL-SYSTEM AND PREFIX-ADDER TESTS PASSED");
            $finish;
        end else begin
            $display("FAIL: system errors=%0d adder errors=%0d", errors, adder_errors);
            $fatal(1);
        end
    end

    // Guard against a broken/stalled simulation.
    initial begin
        #2000000;
        $display("FAIL: testbench timeout");
        $fatal(1);
    end
endmodule
