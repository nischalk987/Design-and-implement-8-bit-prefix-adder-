`timescale 1ns/1ps

module tb_prefix_adder_8bit;
    reg  [7:0] A, B;
    reg        cin;
    wire [7:0] sum;
    wire       cout;
    reg [8:0] expected;
    integer errors, test_count;
    integer i, j, k;

    prefix_adder_8bit dut (
        .A(A), .B(B), .cin(cin), .sum(sum), .cout(cout)
    );

    task check_case;
        input [7:0] a_in;
        input [7:0] b_in;
        input       cin_in;
        reg [8:0] exp;
        begin
            A = a_in;
            B = b_in;
            cin = cin_in;
            exp = {1'b0, a_in} + {1'b0, b_in} + cin_in;
            #1;
            test_count = test_count + 1;
            if ({cout, sum} !== exp) begin
                $display("FAIL #%0d: A=%h B=%h cin=%b got={%b,%h} expected=%h",
                         test_count, A, B, cin, cout, sum, exp);
                errors = errors + 1;
            end else begin
                $display("PASS #%0d: A=%h B=%h cin=%b result=%h",
                         test_count, A, B, cin, {cout, sum});
            end
        end
    endtask

    initial begin
        errors = 0;
        test_count = 0;
        $dumpfile("prefix_adder_8bit.vcd");
        $dumpvars(0, tb_prefix_adder_8bit);

        // Directed tests required by Issue #2.
        check_case(8'h00, 8'h00, 1'b0);
        check_case(8'h00, 8'h00, 1'b1);
        check_case(8'h01, 8'h01, 1'b0);
        check_case(8'h02, 8'h03, 1'b0);
        check_case(8'h0F, 8'h01, 1'b0);
        check_case(8'h1F, 8'h01, 1'b0);
        check_case(8'h7F, 8'h01, 1'b0);
        check_case(8'hFF, 8'h01, 1'b0);
        check_case(8'hFF, 8'hFF, 1'b0);
        check_case(8'hFF, 8'hFF, 1'b1);
        check_case(8'hAA, 8'h55, 1'b0);
        check_case(8'h55, 8'hAA, 1'b1);
        check_case(8'hF0, 8'h0F, 1'b0);
        check_case(8'h80, 8'h80, 1'b0);
        check_case(8'h42, 8'h19, 1'b1);
        check_case(8'hFE, 8'h01, 1'b1);

        // Exhaustively check every 8-bit pair for both values of cin.
        // This is 256 * 256 * 2 = 131,072 combinations.
        for (i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 256; j = j + 1) begin
                for (k = 0; k < 2; k = k + 1) begin
                    A = i[7:0];
                    B = j[7:0];
                    cin = k[0];
                    expected = {1'b0, A} + {1'b0, B} + cin;
                    #1;
                    test_count = test_count + 1;
                    if ({cout, sum} !== expected) begin
                        if (errors < 20)
                            $display("FAIL: A=%h B=%h cin=%b got={%b,%h} expected=%h",
                                     A, B, cin, cout, sum, expected);
                        errors = errors + 1;
                    end
                end
            end
        end

        if (errors == 0)
            $display("ALL TESTS PASSED: %0d checks", test_count);
        else
            $display("TESTS FAILED: %0d mismatches across %0d checks",
                     errors, test_count);
        $finish;
    end
endmodule
