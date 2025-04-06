`include "rv32i_cbu_b.mac.vh"
`include "rv32i_cbu_i.mac.vh"
`include "rv32i_cbu_j.mac.vh"
`include "imm_type.mac.vh"
`include "bu.mac.vh"

module decoder_rv32i_cbu (
    input  wire        clk,

    input  wire  [6:0] i_opcode,
    input  wire  [2:0] i_f3,
    input  wire  [6:0] i_f7,

    output reg   [2:0] o_imm_type,

    output reg   [3:0] o_alu_op,
    output reg         o_alu_a_sel,
    output reg   [1:0] o_alu_b_sel,

    output reg   [2:0] o_cmp_op
);

always @( posedge clk ) begin
    if ( i_opcode == `RV32I_CBU_B_OPCODE ) begin
        o_imm_type = `IMM_TYPE_B;
        o_alu_a_sel = `ALU_A_SEL_IMM;
        o_alu_b_sel = `ALU_B_SEL_PC32;
        o_alu_op = `ALU_ADD; 

        case ( i_f3 )
            `RV32I_CBU_B_F3_BEQ:  o_cmp_op = `BU_BEQ;
            `RV32I_CBU_B_F3_BNE:  o_cmp_op = `BU_BNE;
            `RV32I_CBU_B_F3_BLT:  o_cmp_op = `BU_BLT;
            `RV32I_CBU_B_F3_BGE:  o_cmp_op = `BU_BGE;
            `RV32I_CBU_B_F3_BLTU: o_cmp_op = `BU_BLTU;
            `RV32I_CBU_B_F3_BGEU: o_cmp_op = `BU_BGEU;
            default: o_cmp_op = 3'h7;
        endcase
    end
end

endmodule
