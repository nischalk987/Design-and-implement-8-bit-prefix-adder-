`timescale 1ns/1ps
module tb_prefix_adder_8bit;
    reg [7:0] A, B;
    reg cin;
    wire [7:0] sum;
    wire cout;
    reg [8:0] expected;
    integer i, j, k, errors;

    prefix_adder_8bit dut(.A(A), .B(B), .cin(cin), .sum(sum), .cout(cout));

    task check_case;
        input [7:0] a_in;
        input [7:0] b_in;
        input cin_in;
        reg [8:0] exp;
        begin
            A = a_in; B = b_in; cin = cin_in;
            exp = {1'b0, a_in} + {1'b0, b_in} + cin_in;
            #1;
            if ({cout, sum} !== exp) begin
                $display("FAIL A=%h B=%h cin=%b got=%b_%h expected=%h",
                         A, B, cin, cout, sum, exp);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;
        $dumpfile("prefix_adder_8bit.vcd");
        $dumpvars(0, tb_prefix_adder_8bit);

        check_case(8'h00, 8'h00, 1'b0);
        check_case(8'h01, 8'h01, 1'b0);
        check_case(8'h0F, 8'h01, 1'b0);
        check_case(8'h7F, 8'h01, 1'b0);
        check_case(8'hFF, 8'h01, 1'b0);
        check_case(8'hAA, 8'h55, 1'b0);
        check_case(8'hFF, 8'hFF, 1'b1);
        check_case(8'h42, 8'h19, 1'b1);

        // Exhaustively test all operand pairs and both carry-in values.
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1)
                for (k = 0; k < 2; k = k + 1) begin
                    A = i; B = j; cin = k;
                    expected = {1'b0, A} + {1'b0, B} + cin;
                    #1;
                    if ({cout, sum} !== expected) errors = errors + 1;
                end

        if (errors == 0) $display("ALL TESTS PASSED");
        else $display("TESTS FAILED: %0d mismatches", errors);
        $finish;
    end
endmodule
