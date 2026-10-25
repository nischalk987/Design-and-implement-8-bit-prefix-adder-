`timescale 1ns/1ps
// Common-cathode, active-high hexadecimal seven-segment decoder.
//
// Segment bit ordering: seg[6:0] = {a,b,c,d,e,f,g}
//   a is the top segment
//   b is the upper-right segment
//   c is the lower-right segment
//   d is the bottom segment
//   e is the lower-left segment
//   f is the upper-left segment
//   g is the middle segment
//
// A logic 1 turns a segment ON. Patterns are for hexadecimal 0-F.
module seven_segment_hex_decoder (
    input  wire [3:0] count,
    output reg  [6:0] seg
);
    always @* begin
        case (count)
            4'h0: seg = 7'b1111110;
            4'h1: seg = 7'b0110000;
            4'h2: seg = 7'b1101101;
            4'h3: seg = 7'b1111001;
            4'h4: seg = 7'b0110011;
            4'h5: seg = 7'b1011011;
            4'h6: seg = 7'b1011111;
            4'h7: seg = 7'b1110000;
            4'h8: seg = 7'b1111111;
            4'h9: seg = 7'b1111011;
            4'hA: seg = 7'b1110111;
            4'hB: seg = 7'b0011111; // lowercase b
            4'hC: seg = 7'b1001110; // uppercase C
            4'hD: seg = 7'b0111101; // lowercase d
            4'hE: seg = 7'b1001111;
            4'hF: seg = 7'b1000111;
            default: seg = 7'b0000000;
        endcase
    end
endmodule
