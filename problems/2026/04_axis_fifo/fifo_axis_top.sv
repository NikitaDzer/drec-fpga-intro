module fifo_axis_top #(
    parameter DATA_WIDTH  = 32,
    parameter DEPTH       = 8,
    parameter TID_WIDTH   = 8,
    parameter TDEST_WIDTH = 4,
    parameter TUSER_WIDTH = 4
) (
    input  logic                      clk,
    input  logic                      rst_n,
    
    // Slave interface
    input  logic                      s_axis_tvalid,
    output logic                      s_axis_tready,
    input  logic [DATA_WIDTH-1:0]     s_axis_tdata,
    input  logic [(DATA_WIDTH/8)-1:0] s_axis_tstrb,
    input  logic [(DATA_WIDTH/8)-1:0] s_axis_tkeep,
    input  logic                      s_axis_tlast,
    input  logic [TID_WIDTH-1:0]      s_axis_tid,
    input  logic [TDEST_WIDTH-1:0]    s_axis_tdest,
    input  logic [TUSER_WIDTH-1:0]    s_axis_tuser,
    
    // Master interface
    output logic                      m_axis_tvalid,
    input  logic                      m_axis_tready,
    output logic [DATA_WIDTH-1:0]     m_axis_tdata,
    output logic [(DATA_WIDTH/8)-1:0] m_axis_tstrb,
    output logic [(DATA_WIDTH/8)-1:0] m_axis_tkeep,
    output logic                      m_axis_tlast,
    output logic [TID_WIDTH-1:0]      m_axis_tid,
    output logic [TDEST_WIDTH-1:0]    m_axis_tdest,
    output logic [TUSER_WIDTH-1:0]    m_axis_tuser
);

localparam ADDR_WIDTH = $clog2(DEPTH);
localparam TSTRB_WIDTH = DATA_WIDTH/8;

logic full;
logic empty;

logic                  rd_en;
logic [DATA_WIDTH-1:0] rd_data;
logic                  wr_en;
logic [DATA_WIDTH-1:0] wr_data;

fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) fifo_inst (
    .clk      (clk),
    .rst_n    (rst_n),
    
    .i_rd_en   (rd_en),
    .o_rd_data (rd_data),

    .i_wr_en    (wr_en),
    .i_wr_data  (wr_data),

    .o_full     (full),
    .o_empty    (empty)
);

fifo_axis #(
    .DATA_WIDTH(DATA_WIDTH)
) fifo_axis_inst (
    .clk           (clk),
    .rst_n         (rst_n),

    .s_axis_tvalid (s_axis_tvalid),
    .s_axis_tready (s_axis_tready),
    .s_axis_tdata  (s_axis_tdata),
    
    .m_axis_tvalid (m_axis_tvalid),
    .m_axis_tready (m_axis_tready),
    .m_axis_tdata  (m_axis_tdata),
    
    .i_full        (full),
    .i_empty       (empty),

    .o_rd_en       (rd_en),
    .i_rd_data     (rd_data),

    .o_wr_en       (wr_en),
    .o_wr_data     (wr_data)
);

endmodule
