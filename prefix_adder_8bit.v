// 8-bit parallel-prefix adder (Kogge-Stone style), Verilog-2001.
module prefix_adder_8bit (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire       cin,
    output wire [7:0] sum,
    output wire       cout
);
    wire [7:0] p0, g0, p1, g1, p2, g2, p3, g3;
    wire [7:0] carry;

    assign p0 = A ^ B;
    assign g0 = A & B;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : PREFIX_1
            if (i >= 1) begin
                assign g1[i] = g0[i] | (p0[i] & g0[i-1]);
                assign p1[i] = p0[i] & p0[i-1];
            end else begin
                assign g1[i] = g0[i];
                assign p1[i] = p0[i];
            end
        end
        for (i = 0; i < 8; i = i + 1) begin : PREFIX_2
            if (i >= 2) begin
                assign g2[i] = g1[i] | (p1[i] & g1[i-2]);
                assign p2[i] = p1[i] & p1[i-2];
            end else begin
                assign g2[i] = g1[i];
                assign p2[i] = p1[i];
            end
        end
        for (i = 0; i < 8; i = i + 1) begin : PREFIX_4
            if (i >= 4) begin
                assign g3[i] = g2[i] | (p2[i] & g2[i-4]);
                assign p3[i] = p2[i] & p2[i-4];
            end else begin
                assign g3[i] = g2[i];
                assign p3[i] = p2[i];
            end
        end
    endgenerate

    // Group carry outputs including carry-in.
    assign carry[0] = g0[0] | (p0[0] & cin);
    assign carry[1] = g1[1] | (p1[1] & cin);
    assign carry[2] = g2[2] | (p2[2] & cin);
    assign carry[3] = g2[3] | (p2[3] & cin);
    assign carry[4] = g3[4] | (p3[4] & cin);
    assign carry[5] = g3[5] | (p3[5] & cin);
    assign carry[6] = g3[6] | (p3[6] & cin);
    assign carry[7] = g3[7] | (p3[7] & cin);

    assign sum[0] = p0[0] ^ cin;
    assign sum[7:1] = p0[7:1] ^ carry[6:0];
    assign cout = carry[7];
endmodule
