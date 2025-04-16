`include "wb_sel.mac.vh"
`include "alu_a_sel.mac.vh"
`include "alu_b_sel.mac.vh"

module core (
    input wire  clk,
    input wire  rst_n,

    input  wire [31:0] i_instr_data,
    output wire [29:0] o_instr_addr,

    output wire [29:0] o_mem_addr,
    output wire [31:0] o_mem_data,
    output wire        o_mem_we,
    output wire  [3:0] o_mem_mask,
    input  wire [31:0] i_mem_data
);

// F0 stage specific
reg [29:0] pc;
wire [31:0] inst = i_instr_data;
assign o_instr_addr = pc_next;

wire [4:0] rs1 = inst[19:15];
wire [4:0] rs2 = inst[24:20];
wire [4:0] rd_f0 = inst[11:7];

wire [31:0] imm_f0;
wire [2:0]  imm_type;

wire [31:0] src1;
wire [31:0] src2;
reg  [31:0] dst;
wire        rf_we_f0;

reg [31:0] alu_a;
reg [31:0] alu_b;
wire [31:0] alu_res_f0;
wire  [3:0] alu_op;

wire  [2:0] cmp_op;

wire [1:0] wb_sel_f0;
wire       alu_a_sel;
wire [1:0] alu_b_sel;
wire       pc_sel;

wire        is_store;
wire [31:0] lsu_rd_data;
wire  [3:0] mem_size;

wire taken;

wire [31:0] pc32         = {pc, 2'b0};
wire [31:0] pc32_inc_f0  = pc32 + 4;
wire [31:0] pc32_target  = pc_sel ? (pc32 + imm_f0) : (src1 + imm_f0);
wire [31:0] pc32_next    = taken ? pc32_target : pc32_inc_f0;

wire [29:0] pc_next = pc32_next[31:2];

decoder_rv32i decoder_rv32i_inst (
    .i_inst(inst),

    .o_alu_op(alu_op),
    .o_alu_a_sel(alu_a_sel),
    .o_alu_b_sel(alu_b_sel),

    .o_imm_type(imm_type),

    .o_cmp_op(cmp_op),

    .o_wb_sel(wb_sel_f0),
    .o_is_store(is_store),
    .o_mem_size(mem_size),
    .o_rf_we(rf_we_f0),

    .o_pc_sel(pc_sel)
);

decoder_imm decoder_imm_inst (
    .i_inst(inst),
    .i_imm_type(imm_type),

    .o_imm(imm_f0)
);

rf_2r1w rf_2r1w_inst (
    .clk(clk),

    .i_rd_addr1(rs1),
    .o_rd_data1(src1),

    .i_rd_addr2(rs2),
    .o_rd_data2(src2),

    .i_wr_addr(rd_f1),
    .i_wr_data(dst),
    .i_wr_en(rf_we_f1)
);

alu alu_inst (
    .i_a(alu_a),
    .i_b(alu_b),
    .i_op(alu_op),
    
    .o_res(alu_res_f0)
);

bu bu_inst (
    .i_a(src1),
    .i_b(src2),
    .i_cmp_op(cmp_op),
    
    .o_taken(taken)
);

lsu lsu (
    .i_base(src1),
    .i_offset(imm_f0),
    .i_size(mem_size),
    .i_wr_data(src2),
    .i_is_store(is_store),
    .o_rd_data(lsu_rd_data),

    .o_addr_to_dmem(o_mem_addr),
    .o_wr_data_to_dmem(o_mem_data),
    .i_rd_data_from_dmem(i_mem_data),
    .o_mask_to_dmem(o_mem_mask),
    .o_mem_we(o_mem_we)
);

always @( * ) begin
    case ( alu_a_sel )
        `ALU_A_SEL_REG: alu_a = src1;
        `ALU_A_SEL_IMM: alu_a = imm_f0;

        default: alu_a = 32'hFFFFFFFF;
    endcase

    case ( alu_b_sel )
        `ALU_B_SEL_REG:  alu_b = src2;
        `ALU_B_SEL_IMM:  alu_b = imm_f0;
        `ALU_B_SEL_PC32: alu_b = pc32;

        default: alu_b = 32'hFFFFFFFF;
    endcase
end

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )
        pc <= 0;
    else
        pc <= pc_next;
end

// F1 stage specific
reg [31:0] pc32_inc_f1 = 0;
reg  [1:0] wb_sel_f1   = 0;
reg  [4:0] rd_f1       = 0;
reg [31:0] alu_res_f1  = 0;
reg [31:0] imm_f1      = 0;
reg        rf_we_f1    = 0;

always @( * ) begin
    case ( wb_sel_f1 )
        `WB_SEL_ALU:      dst = alu_res_f1;
        `WB_SEL_LSU:      dst = lsu_rd_data;
        `WB_SEL_PC32_INC: dst = pc32_inc_f1;
        `WB_SEL_IMM:      dst = imm_f1;

        default: dst = 32'hFFFFFFFF;
    endcase
end

always @( posedge clk ) begin
    pc32_inc_f1 <= pc32_inc_f0;
    wb_sel_f1 <= wb_sel_f0;
    rd_f1 <= rd_f0;
    alu_res_f1 <= alu_res_f0;
    imm_f1 <= imm_f0;
    rf_we_f1 <= rf_we_f0;
end

endmodule
