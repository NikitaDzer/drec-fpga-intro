module sa_credit_top #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter DEPTH = 2 * SIZE
)(
    input  logic                       clk,
    input  logic                       rst_n,

    // A-B matrices handshake
    input  logic                       i_vld,
    output logic                       o_rdy,

    // C matrix handshake
    input  logic                       i_rdy,
    output logic                       o_vld,

    input  logic [SIZE-1:0][WIDTH-1:0] i_ab_line,
    output logic [SIZE-1:0][WIDTH-1:0] o_c_line
);


// Count read lines and switch between A and B matrices
logic  [$clog2(SIZE):0] count = 0;
logic  is_a = 0;
logic  last_line = 0;
assign last_line = count == SIZE-1;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 0;
        is_a <= 0;
    end else begin
        if (a_vld) begin
            count <= last_line ? 0 : count + 1;
            if (last_line)
                is_a <= ~is_a;
        end
    end
end


// Signals to/from SA
logic  a_vld = 0;
logic  c_vld_top2sa = 0;
assign c_vld_top2sa = is_a & a_vld;

logic  we = 0;
assign we = a_vld & !is_a;

logic                       c_vld_sa2top;
logic [SIZE-1:0][WIDTH-1:0] c_line_sa2fifo;

sa_top #(.WIDTH(WIDTH), .SIZE(SIZE)) sa_top_inst (
    .clk      (clk),
    .rst_n    (rst_n),

    .i_we     (we),
    .i_a_vld  (a_vld),
    .i_c_vld  (c_vld_top2sa),
    .i_a_line (i_ab_line),

    .o_c_vld  (c_vld_sa2top),
    .o_c_line (c_line_sa2fifo)
);


// Signal to/from FIFO
logic fifo_full;
logic fifo_empty;
logic fifo_wr_en;
logic fifo_rd_en;

assign fifo_wr_en = !fifo_full & c_vld_sa2top;
assign fifo_rd_en = !fifo_empty & i_rdy;
assign o_vld      = !fifo_empty;

fifo #(.DATA_WIDTH(WIDTH * SIZE), .DEPTH(DEPTH)) fifo_inst (
    .clk       (clk),
    .rst_n     (rst_n),

    .i_rd_en   (fifo_rd_en),
    .o_rd_data (o_c_line),

    .i_wr_en   (fifo_wr_en),
    .i_wr_data (c_line_sa2fifo),

    .o_full    (fifo_full),
    .o_empty   (fifo_empty)
);


// Signal to/from credit counter
//
// Reading B matrix and sending C matrix produces INC signal
// Reading any matrix produces DEC signal
logic  inc;
assign inc = (o_vld & i_rdy) || (i_vld & !is_a);

credit #(.DEPTH(DEPTH)) credit_inst (
    .clk   (clk),
    .rst_n (rst_n),

    .i_inc (inc),   // INC signal
    .i_vld (i_vld), // DEC signal

    .o_vld (a_vld),
    .o_rdy (o_rdy)
);

endmodule
