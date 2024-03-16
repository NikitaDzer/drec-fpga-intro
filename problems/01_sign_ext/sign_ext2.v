module sign_ext2
(
    input [11:0]imm,
    output [31:0]ext_imm
);

/*
*   Problem 5:
*   Describe sign extension logic using ternary operator.
*/
wire [19:0]ext = imm[11] ? -20'd1 : 20'd0;
assign ext_imm = {ext, imm};

endmodule
