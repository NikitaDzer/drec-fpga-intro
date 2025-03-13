`timescale 1 ns / 100 ps
`include "assert.vh"
`include "bu.mac.vh"

module bu_tb;

reg [31:0]a;
reg [31:0]b;
reg [2:0]cmp_op;
wire taken;

bu bu_inst (
    .i_a(a),
    .i_b(b),
    .i_cmp_op(cmp_op),
    .o_taken(taken)
);

initial begin
    $dumpvars;
    $display("[bu] Test started.");

    a = -4;
    b = 10;

    #1 cmp_op = `BU_BEQ;
    #1 `assert(taken == 0);

    #1 cmp_op = `BU_BNE;
    #1 `assert(taken == 1);

    #1 cmp_op = `BU_BLT;
    #1 `assert(taken == 1);

    #1 cmp_op = `BU_BGE;
    #1 `assert(taken == 0);

    #1 cmp_op = `BU_BLTU;
    #1 `assert(taken == 0);

    #1 cmp_op = `BU_BGEU;
    #1 `assert(taken == 1);

    $display("[bu] Test done!");
    $finish;
end

endmodule
