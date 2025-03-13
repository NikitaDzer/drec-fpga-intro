`include "alu.mac.vh"

module alu(
    input wire [31:0]i_a,
    input wire [31:0]i_b,
    input wire [3:0]i_op,

    output reg [31:0]o_res
);

wire signed [31:0]signed_i_a = i_a;
wire signed [31:0]signed_i_b = i_b;
wire [4:0]shift = i_b;

always @(*) begin
    case ( i_op )
        `ALU_ADD:  o_res = i_a + i_b; 
        `ALU_SUB:  o_res = i_a - i_b;
        `ALU_SLL:  o_res = i_a << shift;
        `ALU_SLT:  o_res = signed_i_a < signed_i_b;
        `ALU_SLTU: o_res = i_a < i_b;
        `ALU_XOR:  o_res = i_a ^ i_b;
        `ALU_SRL:  o_res = i_a >> shift;
        `ALU_SRA:  o_res = signed_i_a >>> shift;
        `ALU_OR:   o_res = i_a | i_b;
        `ALU_AND:  o_res = i_a & i_b;

        default: o_res = 0;
    endcase
end

endmodule
