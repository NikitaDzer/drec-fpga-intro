module axi_sa_top #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter AXI_ADDR_WIDTH = 32
)(
    input  logic                      clk,
    input  logic                      rst_n,
    
    // Control interface
    input  logic                      i_start,
    input  logic [AXI_ADDR_WIDTH-1:0] i_ab_addr,
    input  logic [AXI_ADDR_WIDTH-1:0] i_c_addr,
    
    // AXI4 AR
    output logic [AXI_ADDR_WIDTH-1:0] m_axi_araddr,
    output logic                      m_axi_arid,
    output logic [7:0]                m_axi_arlen,
    output logic [2:0]                m_axi_arsize,
    output logic [1:0]                m_axi_arburst,
    output logic [2:0]                m_axi_arprot,
    output logic                      m_axi_arvalid,
    input  logic                      m_axi_arready,
    
    // AXI4 R
    input  logic [AXI_DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                      m_axi_rid,
    input  logic [1:0]                m_axi_rresp,
    input  logic                      m_axi_rlast,
    input  logic                      m_axi_rvalid,
    output logic                      m_axi_rready,
    
    // AXI4 AW
    output logic [AXI_ADDR_WIDTH-1:0] m_axi_awaddr,
    output logic                      m_axi_awid,
    output logic [7:0]                m_axi_awlen,
    output logic [2:0]                m_axi_awsize,
    output logic [1:0]                m_axi_awburst,
    output logic [2:0]                m_axi_awprot,
    output logic                      m_axi_awvalid,
    input  logic                      m_axi_awready,
    
    // AXI4 W
    output logic [AXI_DATA_WIDTH-1:0] m_axi_wdata,
    output logic                      m_axi_wvalid,
    input  logic                      m_axi_wready,
    output logic                      m_axi_wlast,
    
    // AXI4 B
    input  logic [1:0]                m_axi_bresp,
    input  logic                      m_axi_bid,
    input  logic                      m_axi_bvalid,
    output logic                      m_axi_bready
);
    
localparam AXI_DATA_WIDTH = SIZE * WIDTH;

logic                       vld_axi2sa;
logic                       rdy_axi2sa;
logic                       vld_sa2axi;
logic                       rdy_sa2axi;
logic [SIZE-1:0][WIDTH-1:0] ab_line;
logic [SIZE-1:0][WIDTH-1:0] c_line;
    
sa_addr_gen #(
    .WIDTH(WIDTH),
    .SIZE(SIZE),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
) sa_addr_gen_inst (
    .clk(clk),
    .rst_n(rst_n),
    
    .i_start(i_start),
    .i_ab_addr(i_ab_addr),
    .i_c_addr(i_c_addr),
    
    .araddr(m_axi_araddr),
    .arlen(m_axi_arlen),
    .arsize(m_axi_arsize),
    .arburst(m_axi_arburst),
    .arvalid(m_axi_arvalid),
    .arready(m_axi_arready),
    
    .awaddr(m_axi_awaddr),
    .awlen(m_axi_awlen),
    .awsize(m_axi_awsize),
    .awburst(m_axi_awburst),
    .awvalid(m_axi_awvalid),
    .awready(m_axi_awready),

    .bvalid(m_axi_bvalid),
    .bready(m_axi_bready)
);
    
sa_axi #(
    .WIDTH(WIDTH),
    .SIZE(SIZE)
) sa_axi_inst (
    .clk(clk),
    .rst_n(rst_n),
    
    .rdata(m_axi_rdata),
    .rvalid(m_axi_rvalid),
    .rready(m_axi_rready),
    .rlast(m_axi_rlast),
    
    .wdata(m_axi_wdata),
    .wvalid(m_axi_wvalid),
    .wready(m_axi_wready),
    .wlast(m_axi_wlast),
    
    .vld_axi2sa(vld_axi2sa),
    .rdy_axi2sa(rdy_axi2sa),
    .vld_sa2axi(vld_sa2axi),
    .rdy_sa2axi(rdy_sa2axi),
    .ab_line(ab_line),
    .c_line(c_line)
);
    
sa_credit_based #(
    .WIDTH(WIDTH),
    .SIZE(SIZE)
) sa_credit_based_inst (
    .clk(clk),
    .rst_n(rst_n),
    
    .i_vld(vld_axi2sa),
    .i_rdy(rdy_axi2sa),
    .o_vld(vld_sa2axi),
    .o_rdy(rdy_sa2axi),
    
    .i_ab_line(ab_line),
    .o_c_line(c_line)
);

endmodule
