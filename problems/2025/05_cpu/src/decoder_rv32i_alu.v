`include "rv32i_alu_r.mac.vh"
`include "rv32i_alu_i.mac.vh"
`include "imm_type.mac.vh"
`include "alu_a_sel.mac.vh"
`include "alu_b_sel.mac.vh"

module decoder_rv32i_alu (
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
    if ( i_opcode == `RV32I_ALU_R_OPCODE ) begin
        o_imm_type = `IMM_TYPE_NONE;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_REG;

        case ( {i_f3, i_f7} )
            {`RV32I_ALU_R_F3_ADD,  `RV32I_ALU_R_F7_ADD}:  o_alu_op = `ALU_ADD;
            {`RV32I_ALU_R_F3_SUB,  `RV32I_ALU_R_F7_SUB}:  o_alu_op = `ALU_SUB; 
            {`RV32I_ALU_R_F3_XOR,  `RV32I_ALU_R_F7_XOR}:  o_alu_op = `ALU_XOR;
            {`RV32I_ALU_R_F3_OR,   `RV32I_ALU_R_F7_OR}:   o_alu_op = `ALU_OR;
            {`RV32I_ALU_R_F3_AND,  `RV32I_ALU_R_F7_AND}:  o_alu_op = `ALU_AND;
            {`RV32I_ALU_R_F3_SLL,  `RV32I_ALU_R_F7_SLL}:  o_alu_op = `ALU_SLL;
            {`RV32I_ALU_R_F3_SRL,  `RV32I_ALU_R_F7_SRL}:  o_alu_op = `ALU_SRL;
            {`RV32I_ALU_R_F3_SRA,  `RV32I_ALU_R_F7_SRA}:  o_alu_op = `ALU_SRA;
            {`RV32I_ALU_R_F3_SLT,  `RV32I_ALU_R_F7_SLT}:  o_alu_op = `ALU_SLT;
            {`RV32I_ALU_R_F3_SLTU, `RV32I_ALU_R_F7_SLTU}: o_alu_op = `ALU_SLTU;
            default: o_alu_op = 4'hF;
        endcase
    end
    else if ( i_opcode == `RV32I_ALU_I_OPCODE ) begin
        o_imm_type = `IMM_TYPE_I;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_IMM;

        // TODO: SLLI, SRLI, SRAI imm.
        case ( i_f3 )
            `RV32I_ALU_I_F3_ADDI  : o_alu_op = `ALU_ADD;
            `RV32I_ALU_I_F3_XORI  : o_alu_op = `ALU_XOR;
            `RV32I_ALU_I_F3_ORI   : o_alu_op = `ALU_OR;
            `RV32I_ALU_I_F3_ANDI  : o_alu_op = `ALU_AND;
            `RV32I_ALU_I_F3_SLLI  : o_alu_op = `ALU_SLL;
            `RV32I_ALU_I_F3_SRLI  : o_alu_op = `ALU_SRL;
            `RV32I_ALU_I_F3_SRAI  : o_alu_op = `ALU_SRA;
            `RV32I_ALU_I_F3_SLTI  : o_alu_op = `ALU_SLT;
            `RV32I_ALU_I_F3_SLTIU : o_alu_op = `ALU_SLTU;
            default: o_alu_op = 4'hF;
        endcase
    end
end

endmodule
