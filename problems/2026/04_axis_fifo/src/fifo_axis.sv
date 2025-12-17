module fifo_axis #(
    parameter DATA_WIDTH  = 32
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Slave interface
    input  logic                  s_axis_tvalid,
    output logic                  s_axis_tready,
    input  logic [DATA_WIDTH-1:0] s_axis_tdata,
    
    // Master interface
    output logic                  m_axis_tvalid,
    input  logic                  m_axis_tready,
    output logic [DATA_WIDTH-1:0] m_axis_tdata,

    // FIFO interface
    input  logic                  i_full,
    input  logic                  i_empty,

    output logic                  o_rd_en,
    input  logic [DATA_WIDTH-1:0] i_rd_data,

    output logic                  o_wr_en,
    output logic [DATA_WIDTH-1:0] o_wr_data
);

assign s_axis_tready = !i_full;
assign m_axis_tvalid = !i_empty;

// Permit writing in/reading from FIFO
assign o_wr_en = s_axis_tvalid & s_axis_tready & !i_full;
assign o_rd_en = m_axis_tvalid & m_axis_tready & !i_empty;

assign m_axis_tdata = i_rd_data;
assign o_wr_data    = s_axis_tdata;

endmodule
