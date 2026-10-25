`timescale 1ns/1ps

module tb_seven_segment_hex_decoder;
    reg  [3:0] count;
    wire [6:0] seg;
    integer i;
    reg [6:0] expected;

    seven_segment_hex_decoder dut (
        .count(count),
        .seg(seg)
    );

    function [6:0] expected_pattern(input [3:0] value);
        begin
            case (value)
                4'h0: expected_pattern = 7'b1111110;
                4'h1: expected_pattern = 7'b0110000;
                4'h2: expected_pattern = 7'b1101101;
                4'h3: expected_pattern = 7'b1111001;
                4'h4: expected_pattern = 7'b0110011;
                4'h5: expected_pattern = 7'b1011011;
                4'h6: expected_pattern = 7'b1011111;
                4'h7: expected_pattern = 7'b1110000;
                4'h8: expected_pattern = 7'b1111111;
                4'h9: expected_pattern = 7'b1111011;
                4'hA: expected_pattern = 7'b1110111;
                4'hB: expected_pattern = 7'b0011111;
                4'hC: expected_pattern = 7'b1001110;
                4'hD: expected_pattern = 7'b0111101;
                4'hE: expected_pattern = 7'b1001111;
                4'hF: expected_pattern = 7'b1000111;
                default: expected_pattern = 7'b0000000;
            endcase
        end
    endfunction

    initial begin
        $dumpfile("seven_segment_hex_decoder.vcd");
        $dumpvars(0, tb_seven_segment_hex_decoder);

        for (i = 0; i < 16; i = i + 1) begin
            count = i[3:0];
            expected = expected_pattern(i[3:0]);
            #1;
            if (seg !== expected) begin
                $display("FAIL: hex=%h expected seg=%b actual seg=%b",
                         count, expected, seg);
                $fatal(1);
            end else begin
                $display("PASS: hex=%h seg=%b", count, seg);
            end
        end

        $display("ALL 16 HEX DECODER TESTS PASSED");
        $finish;
    end
endmodule
