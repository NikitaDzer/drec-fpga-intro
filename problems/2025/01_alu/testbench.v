`timescale 1 ns / 100 ps
`include "assert.vh"
`include "alu.mac.vh"

module alu_tb;

reg [31:0]a;
reg [31:0]b;
reg [3:0]op;
wire [31:0]res;

alu alu_inst (
    .i_a(a),
    .i_b(b),
    .i_op(op),
    .o_res(res)
);

initial begin
    $dumpvars;
    $display("[alu] Test started.");

    a = 4;
    b = 10;

    #1 op = `ALU_ADD;
    #1 `assert(res == 14);

    #1 op = `ALU_SUB;
    #1 `assert(res == -6);

    #1 op = `ALU_SLL;
    #1 `assert(res == (4 << 10));

    #1 op = `ALU_SLT; a = -10; b = 4;
    #1 `assert(res == 1);

    #1 op = `ALU_SLTU;
    #1 `assert(res == 0);

    #1 op = `ALU_XOR; a = 32'b0010; b = 32'b1001;
    #1 `assert(res == 32'b1011);

    #1 op = `ALU_SRL; a = -1; b = 30;
    #1 `assert(res == 3);

    #1 op = `ALU_SRA; a = -4; b = 2;
    #1 `assert(res == -1);

    #1 op = `ALU_OR; a = 32'b0101; b = 32'b1010;
    #1 `assert(res == 32'b1111);

    #1 op = `ALU_AND;
    #1 `assert(res == 0);

    $display("[alu] Test done!");
    $finish;
end

endmodule
