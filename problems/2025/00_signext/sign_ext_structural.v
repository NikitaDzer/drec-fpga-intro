module sign_ext_structural #(
    parameter N = 12,
    parameter M = 32
)(
    input  [N-1:0]i_imm,
    output [M-1:0]o_ext_imm
);

assign o_ext_imm[N-1:0] = i_imm;

generate
    genvar i;

    for ( i = N; i < M; i = i + 1 ) begin : gen_copy_bit
        copy_bit copy_bit_inst (
            .i_bit(i_imm[N-1]),
            .o_bit(o_ext_imm[i])
        );
    end
endgenerate

endmodule
