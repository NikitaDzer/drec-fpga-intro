module sign_ext_beh #(
    parameter N = 12,
    parameter M = 32
)(
    input  [N-1:0]i_imm,
    output [M-1:0]o_ext_imm
);

wire [M-N-1:0]msb = {(M-N){i_imm[N-1]}};
assign o_ext_imm = {msb, i_imm};

endmodule
