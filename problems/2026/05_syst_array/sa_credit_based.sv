module sa_credit_based #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter DEPTH = 2 * SIZE
)(
    input  logic                       clk,
    input  logic                       rst_n,

    input  logic                       i_vld,
    input  logic                       i_rdy,
    output logic                       o_vld,
    output logic                       o_rdy,

    input  logic [SIZE-1:0][WIDTH-1:0] i_ab_line,
    output logic [SIZE-1:0][WIDTH-1:0] o_c
);

localparam CNT_WIDTH = $clog2(SIZE) + 1;
logic [CNT_WIDTH-1:0] count = 0;
logic last_fragment = 0;
logic is_a = 0;

assign last_fragment = count == SIZE-1;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        count <= 0;
    else begin
        if (a_vld) begin
            count <= last_fragment ? 0 : count + 1;

            if (last_fragment)
                is_a <= ~is_a;
        end

    end
end

logic we = 0;
assign we = !is_a;

logic a_vld = 0;
logic c_vld_top2sa = 0;
assign c_vld_top2sa = is_a & a_vld;

logic                            c_vld_sa2top;
logic [SIZE-1:0][WIDTH-1:0] c_line;

sa_top #(.WIDTH(WIDTH), .SIZE(SIZE)) sa_top_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_we(we),
    .i_a_vld(a_vld),
    .i_c_vld(c_vld_top2sa),
    .i_a_line(i_ab_line),
    .o_c_vld(c_vld_sa2top),
    .o_c_line(c_line)
);

logic fifo_full;
logic fifo_empty;
logic fifo_wr_en;
logic fifo_rd_en;

assign fifo_wr_en = !fifo_full & c_vld_sa2top;
assign fifo_rd_en = !fifo_empty & i_rdy;
assign o_vld = !fifo_empty;

fifo #(.DATA_WIDTH(WIDTH * SIZE), .DEPTH(DEPTH)) fifo_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_rd_en(fifo_rd_en),
    .o_rd_data(o_c),
    .i_wr_en(fifo_wr_en),
    .i_wr_data(c_line),
    .o_full(fifo_full),
    .o_empty(fifo_empty)
);

logic  inc;
assign inc = o_vld & i_rdy & is_a;

credit_cnt #(.DEPTH(DEPTH)) credit_cnt_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_inc(inc),
    .i_vld(i_vld),
    .o_vld(a_vld),
    .o_rdy(o_rdy)
);

endmodule
