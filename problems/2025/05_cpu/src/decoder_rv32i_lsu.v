`include "rv32i_lsu_i.mac.vh"
`include "rv32i_lsu_s.mac.vh"
`include "imm_type.mac.vh"
`include "alu_a_sel.mac.vh"
`include "alu_b_sel.mac.vh"

module decoder_rv32i_lsu (
    input  wire        clk,

    input  wire  [6:0] i_opcode,
    input  wire  [2:0] i_f3,
    input  wire  [6:0] i_f7,

    output reg   [3:0] o_alu_op,
    output reg         o_alu_a_sel,
    output reg   [1:0] o_alu_b_sel,

    output reg   [2:0] o_imm_type
);

always @( posedge clk ) begin
    if ( i_opcode == `RV32I_LSU_I_OPCODE ) begin
        o_imm_type  = `IMM_TYPE_I;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_IMM;

        case ( i_f3 )
            `RV32I_LSU_I_F3_LB:  o_alu_op = `ALU_ADD;
            `RV32I_LSU_I_F3_LH:  o_alu_op = `ALU_ADD;
            `RV32I_LSU_I_F3_LW:  o_alu_op = `ALU_ADD;
            `RV32I_LSU_I_F3_LBU: o_alu_op = `ALU_ADD;
            `RV32I_LSU_I_F3_LHU: o_alu_op = `ALU_ADD;
            default: o_alu_op = 4'hF;
        endcase
    end
    else if ( i_opcode == `RV32I_LSU_S_OPCODE ) begin
        o_imm_type  = `IMM_TYPE_S;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_IMM;

        case ( i_f3 )
            `RV32I_LSU_S_F3_SB: o_alu_op = `ALU_ADD;
            `RV32I_LSU_S_F3_SH: o_alu_op = `ALU_ADD;
            `RV32I_LSU_S_F3_SW: o_alu_op = `ALU_ADD;
            default: o_alu_op = 4'hF;
        endcase
    end
end

endmodule
