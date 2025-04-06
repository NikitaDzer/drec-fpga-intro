`include "imm_type.mac.vh"

module decoder_imm (
    input  wire [31:0] i_inst,
    input  wire  [2:0] i_imm_type,

    output reg  [31:0] o_imm
);

wire sign = i_inst[31];

wire [10:0] inst_30_20 = i_inst[30:20];
wire  [5:0] inst_30_25 = i_inst[30:25];
wire  [3:0] inst_24_21 = i_inst[24:21];
wire        inst_20    = i_inst[20];
wire  [7:0] inst_19_12 = i_inst[19:12];
wire  [3:0] inst_11_8  = i_inst[11:8];
wire        inst_7     = i_inst[7];

wire [31:0] imm_i = {{21{sign}}, inst_30_25, inst_24_21, inst_20};
wire [31:0] imm_s = {{21{sign}}, inst_30_25, inst_11_8, inst_7};
wire [31:0] imm_b = {{20{sign}}, inst_7, inst_30_25, inst_11_8, 1'b0};
wire [31:0] imm_u = {sign, inst_30_20, inst_19_12, 12'b0};
wire [31:0] imm_j = {{12{sign}}, inst_19_12, inst_20, inst_30_25, inst_24_21, 1'b0};

always @( * ) begin
    case ( i_imm_type )
        `IMM_TYPE_I: o_imm = imm_i;
        `IMM_TYPE_S: o_imm = imm_s;
        `IMM_TYPE_B: o_imm = imm_b;
        `IMM_TYPE_U: o_imm = imm_u;
        `IMM_TYPE_J: o_imm = imm_j;
        default: o_imm = 32'hFFFFFFFF;
    endcase
end

endmodule
