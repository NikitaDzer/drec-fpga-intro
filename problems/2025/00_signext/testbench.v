`timescale 1 ns / 100 ps
`include "assert.vh"

module sign_ext_tb;

localparam N = 12;
localparam M = 32;

reg  [N-1:0]imm = -10;
wire [M-1:0]ext_imm_beh;
wire [M-1:0]ext_imm_structural;

always begin
    #1
    `assert(imm[N-1:0] == ext_imm_beh[N-1:0]);
    `assert({(M-N){imm[N-1]}} == ext_imm_beh[M-1:N]);

    `assert(imm[N-1:0] == ext_imm_structural[N-1:0]);
    `assert({(M-N){imm[N-1]}} == ext_imm_structural[M-1:N]);

    #1 imm = imm + 1;
end

sign_ext_beh #(
    .N(N),
    .M(M)
) sign_ext_beh_inst(
    .i_imm(imm),
    .o_ext_imm(ext_imm_beh)
);

sign_ext_structural #(
    .N(N),
    .M(M)
) sign_ext_structural_inst (
    .i_imm(imm),
    .o_ext_imm(ext_imm_structural)
);

initial begin
    $dumpvars;
    $display("[sign_ext] Test started (N = %d, M = %d).", N, M);

    #5000

    $display("[sign_ext] Test done!");
    $finish;
end

endmodule
