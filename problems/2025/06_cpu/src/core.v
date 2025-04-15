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
    output wire [31:0] i_mem_data
);

reg [29:0] pc;
wire [31:0] inst = i_instr_data;
assign o_instr_addr = pc_next;

wire [4:0] rs1 = inst[19:15];
wire [4:0] rs2 = inst[24:20];
wire [4:0] rd  = inst[11:7];

wire [31:0] imm;
wire [2:0]  imm_type;

wire [31:0] src1;
wire [31:0] src2;
reg  [31:0] dst;
wire        rf_we;
wire        wr_en = rf_we && !is_stalled;

reg [31:0] alu_a;
reg [31:0] alu_b;
wire [31:0] alu_res;
wire  [3:0] alu_op;

wire  [2:0] cmp_op;

wire [1:0] wb_sel;
wire       alu_a_sel;
wire [1:0] alu_b_sel;

wire        is_store;
wire [31:0] lsu_rd_data;
wire  [3:0] mem_size;

wire taken;

reg  [3:0] stall = 0;
wire [3:0] stall_dec = stall - 1;
wire [3:0] stall_inst;
wire       can_decode = stall == 0;
wire [3:0] stall_next = can_decode ? stall_inst : stall_dec;
wire       is_stalled = stall_next != 0;

wire [31:0] pc32      = {pc, 2'b0};
wire [31:0] pc32_inc  = pc32 + 4;
wire [31:0] pc32_next = is_stalled
    ? pc32
    : taken ? alu_res : pc32_inc;

wire [29:0] pc_inc  = pc32_inc[31:2];
wire [29:0] pc_next = pc32_next[31:2];

decoder_rv32i decoder_rv32i_inst (
    .i_inst(inst),

    .o_alu_op(alu_op),
    .o_alu_a_sel(alu_a_sel),
    .o_alu_b_sel(alu_b_sel),

    .o_imm_type(imm_type),

    .o_cmp_op(cmp_op),

    .o_wb_sel(wb_sel),
    .o_is_store(is_store),
    .o_mem_size(mem_size),
    .o_rf_we(rf_we),

    .o_stall(stall_inst)
);

decoder_imm decoder_imm_inst (
    .i_inst(inst),
    .i_imm_type(imm_type),

    .o_imm(imm)
);

rf_2r1w rf_2r1w_inst (
    .clk(clk),

    .i_rd_addr1(rs1),
    .o_rd_data1(src1),

    .i_rd_addr2(rs2),
    .o_rd_data2(src2),

    .i_wr_addr(rd),
    .i_wr_data(dst),
    .i_wr_en(wr_en)
);

alu alu_inst (
    .i_a(alu_a),
    .i_b(alu_b),
    .i_op(alu_op),
    
    .o_res(alu_res)
);

bu bu_inst (
    .i_a(src1),
    .i_b(src2),
    .i_cmp_op(cmp_op),
    
    .o_taken(taken)
);

lsu lsu (
    .i_addr(alu_res),
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

// TODO: plug
wire [31:0] dmem_data_out;

always @( * ) begin
    case ( wb_sel )
        `WB_SEL_ALU:      dst = alu_res;
        `WB_SEL_LSU:      dst = lsu_rd_data;
        `WB_SEL_PC32_INC: dst = pc32_inc;
        `WB_SEL_IMM:      dst = imm;

        default: dst = 32'hFFFFFFFF;
    endcase

    case ( alu_a_sel )
        `ALU_A_SEL_REG: alu_a = src1;
        `ALU_A_SEL_IMM: alu_a = imm;

        default: alu_a = 32'hFFFFFFFF;
    endcase

    case ( alu_b_sel )
        `ALU_B_SEL_REG:  alu_b = src2;
        `ALU_B_SEL_IMM:  alu_b = imm;
        `ALU_B_SEL_PC32: alu_b = pc32;

        default: alu_b = 32'hFFFFFFFF;
    endcase
end

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        pc <= 0;
        stall <= 0;
    end else begin
        pc <= pc_next;
        stall <= stall_next;
    end
end

endmodule
