`include "rv32i_alu_r.mac.vh"
`include "rv32i_alu_i.mac.vh"
`include "rv32i_alu_u.mac.vh"
`include "rv32i_lsu_i.mac.vh"
`include "rv32i_lsu_s.mac.vh"
`include "rv32i_cbu_b.mac.vh"
`include "rv32i_cbu_j.mac.vh"
`include "rv32i_cbu_i.mac.vh"

`include "alu.mac.vh"
`include "bu.mac.vh"
`include "imm_type.mac.vh"
`include "wb_sel.mac.vh"

module decoder_rv32i (
    input  wire [31:0] i_inst,

    output reg   [3:0] o_alu_op,
    output reg         o_alu_a_sel,
    output reg   [1:0] o_alu_b_sel,

    output reg   [2:0] o_imm_type,

    output reg   [2:0] o_cmp_op,

    output reg   [1:0] o_wb_sel,
    output reg         o_is_store,
    output reg   [3:0] o_mem_size,
    output reg         o_rf_we,

    output reg   [3:0] o_stall
);

wire [6:0] opcode = i_inst[6:0];
wire [2:0] f3     = i_inst[14:12];
wire [6:0] f7     = i_inst[31:25];

/**
 * RV32I ALU
 */
always @( * ) begin
    if ( opcode == `RV32I_ALU_R_OPCODE ) begin
        o_imm_type = `IMM_TYPE_NONE;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_REG;
        o_wb_sel = `WB_SEL_ALU;
        o_is_store = 0;
        o_rf_we = 1;
        o_cmp_op = `BU_NONE;
        o_mem_size  = 0;
        o_stall = 0;

        case ( {f3, f7} )
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
    else if ( opcode == `RV32I_ALU_I_OPCODE ) begin
        o_imm_type = `IMM_TYPE_I;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_IMM;
        o_wb_sel = `WB_SEL_ALU;
        o_is_store = 0;
        o_rf_we = 1;
        o_cmp_op = `BU_NONE;
        o_mem_size  = 0;
        o_stall = 0;

        // TODO: SLLI, SRLI, SRAI imm.
        case ( f3 )
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
    else if ( opcode == `RV32I_ALU_U_OPCODE_LUI ) begin
        o_imm_type = `IMM_TYPE_U;
        o_alu_a_sel = `ALU_A_SEL_IMM;
        o_alu_b_sel = `ALU_B_SEL_REG;
        o_wb_sel = `WB_SEL_IMM;
        o_is_store = 0;
        o_rf_we = 1;
        o_cmp_op = `BU_NONE;
        o_alu_op = `ALU_ADD;
        o_mem_size  = 0;
        o_stall = 0;
    end
    else if ( opcode == `RV32I_ALU_U_OPCODE_AUIPC ) begin
        o_imm_type = `IMM_TYPE_U;
        o_alu_a_sel = `ALU_A_SEL_IMM;
        o_alu_b_sel = `ALU_B_SEL_PC32;
        o_wb_sel = `WB_SEL_ALU;
        o_is_store = 0;
        o_rf_we = 1;
        o_cmp_op = `BU_NONE;
        o_alu_op = `ALU_ADD;
        o_mem_size  = 0;
        o_stall = 0;
    end
    else if ( opcode == `RV32I_CBU_B_OPCODE ) begin
        o_imm_type  = `IMM_TYPE_B;
        o_alu_a_sel = `ALU_A_SEL_IMM;
        o_alu_b_sel = `ALU_B_SEL_PC32;
        o_alu_op    = `ALU_ADD; 
        o_wb_sel    = `WB_SEL_ALU;
        o_is_store = 0;
        o_rf_we = 0;
        o_cmp_op = `BU_NONE;
        o_mem_size  = 0;
        o_stall = 0;

        case ( f3 )
            `RV32I_CBU_B_F3_BEQ:  o_cmp_op = `BU_BEQ;
            `RV32I_CBU_B_F3_BNE:  o_cmp_op = `BU_BNE;
            `RV32I_CBU_B_F3_BLT:  o_cmp_op = `BU_BLT;
            `RV32I_CBU_B_F3_BGE:  o_cmp_op = `BU_BGE;
            `RV32I_CBU_B_F3_BLTU: o_cmp_op = `BU_BLTU;
            `RV32I_CBU_B_F3_BGEU: o_cmp_op = `BU_BGEU;
            default: o_cmp_op = 3'h7;
        endcase
    end
    else if ( opcode == `RV32I_CBU_J_OPCODE_JAL ) begin
        o_imm_type  = `IMM_TYPE_J;
        o_alu_a_sel = `ALU_A_SEL_IMM;
        o_alu_b_sel = `ALU_B_SEL_PC32;
        o_alu_op    = `ALU_ADD; 
        o_wb_sel    = `WB_SEL_PC32_INC;
        o_is_store  = 0;
        o_rf_we     = 1;
        o_cmp_op    = `BU_PT;
        o_mem_size  = 0;
        o_stall     = 0;
    end
    else if ( opcode == `RV32I_CBU_I_OPCODE_JALR ) begin
        o_imm_type  = `IMM_TYPE_I;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_IMM;
        o_alu_op    = `ALU_ADD; 
        o_wb_sel    = `WB_SEL_PC32_INC;
        o_is_store  = 0;
        o_rf_we     = 1;
        o_cmp_op    = `BU_PT;
        o_mem_size  = 0;
        o_stall     = 0;
    end
    else if ( opcode == `RV32I_LSU_I_OPCODE ) begin
        o_imm_type  = `IMM_TYPE_I;
        o_alu_op = `ALU_ADD;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_IMM;
        o_wb_sel = `WB_SEL_LSU;
        o_is_store = 0;
        o_rf_we = 1;
        o_cmp_op = `BU_NONE;
        o_stall = 1;

        case ( f3 )
            `RV32I_LSU_I_F3_LB:  o_mem_size = 1;
            `RV32I_LSU_I_F3_LH:  o_mem_size = 2;
            `RV32I_LSU_I_F3_LW:  o_mem_size = 4;
            `RV32I_LSU_I_F3_LBU: o_mem_size = 1;
            `RV32I_LSU_I_F3_LHU: o_mem_size = 2;
            default: o_mem_size = 0;
        endcase
    end
    else if ( opcode == `RV32I_LSU_S_OPCODE ) begin
        o_imm_type  = `IMM_TYPE_S;
        o_alu_op = `ALU_ADD;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_IMM;
        o_is_store = 1;
        o_rf_we = 0;
        o_wb_sel = `WB_SEL_ALU;
        o_cmp_op = `BU_NONE;
        o_stall = 0;

        case ( f3 )
            `RV32I_LSU_S_F3_SB: o_mem_size = 1;
            `RV32I_LSU_S_F3_SH: o_mem_size = 2;
            `RV32I_LSU_S_F3_SW: o_mem_size = 4;
            default: o_mem_size = 0;
        endcase
    end
    else begin
        o_imm_type  = `IMM_TYPE_NONE;
        o_alu_op    = `ALU_ADD;
        o_alu_a_sel = `ALU_A_SEL_REG;
        o_alu_b_sel = `ALU_B_SEL_REG;
        o_wb_sel    = `WB_SEL_ALU;
        o_is_store  = 0;
        o_rf_we     = 0;
        o_cmp_op    = `BU_NONE;
        o_mem_size  = 0;
        o_stall     = 0; 
    end
end

endmodule
