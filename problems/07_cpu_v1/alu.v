`include "alu.mac.vh"

module alu(
    input [31:0]src_a,
    input [31:0]src_b,
    input [2:0]op,

    output reg [31:0]res
);

wire signed [31:0]signed_src_a = src_a;
wire signed [31:0]signed_src_b = src_b;

always @(*) begin
/**
 * Problem 1:
 * Write operations execution logic here.
 */
    case ( op )
        `ALU_ADD:  res = src_a + src_b; 
        `ALU_SUB:  res = src_a - src_b;
        `ALU_XOR:  res = src_a ^ src_b;
        `ALU_OR:   res = src_a | src_b;
        `ALU_AND:  res = src_a & src_b;
        `ALU_SLT:  res = signed_src_a < signed_src_b;
        `ALU_SLTU: res = src_a < src_b;
        `ALU_SLL:  res = src_a << src_b;

        default: res = 0;
    endcase

    $strobe("a> alu_op: %h, src_a: %h, src_b: %h", op, src_a, src_b);

end

endmodule
