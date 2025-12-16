module sa_axi_top #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter DEPTH = SIZE * 2,
    parameter AXI_ADDR_WIDTH = 32
)(
    input  logic                      clk,
    input  logic                      rst_n,
    
    // Control signals
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

logic vld_axi2sa;
logic rdy_sa2axi;

logic vld_sa2axi;
logic rdy_axi2sa;

logic [SIZE-1:0][WIDTH-1:0] ab_line_axi2sa;
logic [SIZE-1:0][WIDTH-1:0] c_line_sa2axi;
    
addr_gen_axi #(
    .WIDTH(WIDTH),
    .SIZE(SIZE),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
) addr_gen_axi_inst (
    .clk       (clk),
    .rst_n     (rst_n),
        
    .i_start   (i_start),
    .i_ab_addr (i_ab_addr),
    .i_c_addr  (i_c_addr),
        
    // AXI4 AR
    .araddr    (m_axi_araddr),
    .arlen     (m_axi_arlen),
    .arsize    (m_axi_arsize),
    .arburst   (m_axi_arburst),
    .arvalid   (m_axi_arvalid),
    .arready   (m_axi_arready),
        
    // AXI4 AW
    .awaddr    (m_axi_awaddr),
    .awlen     (m_axi_awlen),
    .awsize    (m_axi_awsize),
    .awburst   (m_axi_awburst),
    .awvalid   (m_axi_awvalid),
    .awready   (m_axi_awready),

    // AXI4 B
    .bvalid(m_axi_bvalid),
    .bready(m_axi_bready)
);
    
sa_ctrl_axi #(
    .WIDTH(WIDTH),
    .SIZE(SIZE)
) sa_ctrl_axi_inst (
    .clk            (clk),
    .rst_n          (rst_n),
        
    // AXI4 R
    .rdata          (m_axi_rdata),
    .rvalid         (m_axi_rvalid),
    .rready         (m_axi_rready),
    .rlast          (m_axi_rlast),

    // AXI4 W
    .wdata          (m_axi_wdata),
    .wvalid         (m_axi_wvalid),
    .wready         (m_axi_wready),
    .wlast          (m_axi_wlast),
        
    // A-B matrices handshake
    .vld_axi2sa     (vld_axi2sa),
    .rdy_sa2axi     (rdy_sa2axi),

    // C matrix handshake
    .rdy_axi2sa     (rdy_axi2sa),
    .vld_sa2axi     (vld_sa2axi),

    .ab_line_axi2sa (ab_line_axi2sa),
    .c_line_sa2axi  (c_line_sa2axi)
);
    
sa_credit_top #(
    .WIDTH(WIDTH),
    .SIZE(SIZE),
    .DEPTH(DEPTH)
) sa_credit_top_inst (
    .clk       (clk),
    .rst_n     (rst_n),
        
    // A-B matrices handshake
    .i_vld     (vld_axi2sa),
    .o_rdy     (rdy_sa2axi),

    // C matrix handshake
    .i_rdy     (rdy_axi2sa),
    .o_vld     (vld_sa2axi),
        
    .i_ab_line (ab_line_axi2sa),
    .o_c_line  (c_line_sa2axi)
);
    
endmodule
