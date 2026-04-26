module sa_axi_top #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter DEPTH = SIZE * 2,
    parameter AXI_ADDR_WIDTH = 32
)(
    input  wire                       clk,
    input  wire                       rst_n,
    
    // AXI4 AR
    output wire [AXI_ADDR_WIDTH-1:0]  m_axi_araddr,
    output wire                       m_axi_arid,
    output wire [7:0]                 m_axi_arlen,
    output wire [2:0]                 m_axi_arsize,
    output wire [1:0]                 m_axi_arburst,
    output wire [2:0]                 m_axi_arprot,
    output wire                       m_axi_arvalid,
    input  wire                       m_axi_arready,
    
    // AXI4 R
    input  wire [AXI_DATA_WIDTH-1:0]  m_axi_rdata,
    input  wire                       m_axi_rid,
    input  wire [1:0]                 m_axi_rresp,
    input  wire                       m_axi_rlast,
    input  wire                       m_axi_rvalid,
    output wire                       m_axi_rready,
    
    // AXI4 AW
    output wire [AXI_ADDR_WIDTH-1:0]  m_axi_awaddr,
    output wire                       m_axi_awid,
    output wire [7:0]                 m_axi_awlen,
    output wire [2:0]                 m_axi_awsize,
    output wire [1:0]                 m_axi_awburst,
    output wire [2:0]                 m_axi_awprot,
    output wire                       m_axi_awvalid,
    input  wire                       m_axi_awready,
    
    // AXI4 W
    output wire [AXI_DATA_WIDTH-1:0]  m_axi_wdata,
    output wire                       m_axi_wvalid,
    input  wire                       m_axi_wready,
    output wire                       m_axi_wlast,
    
    // AXI4 B
    input  wire [1:0]                 m_axi_bresp,
    input  wire                       m_axi_bid,
    input  wire                       m_axi_bvalid,
    output wire                       m_axi_bready,

    // AXI4L AW
    input  wire [AXIL_ADDR_WIDTH-1:0] s_axil_awaddr,
    input  wire [2:0]                 s_axil_awprot,
    input  wire                       s_axil_awvalid,
    output wire                       s_axil_awready,

    // AXI4L W
    input  wire [AXIL_DATA_WIDTH-1:0] s_axil_wdata,
    input  wire [AXIL_STRB_WIDTH-1:0] s_axil_wstrb,
    input  wire                       s_axil_wvalid,
    output wire                       s_axil_wready,

    // AXI4L B
    output wire [1:0]                 s_axil_bresp,
    output wire                       s_axil_bvalid,
    input  wire                       s_axil_bready,

    // AXI4L AR
    input  wire [AXIL_ADDR_WIDTH-1:0] s_axil_araddr,
    input  wire [2:0]                 s_axil_arprot,
    input  wire                       s_axil_arvalid,
    output wire                       s_axil_arready,

    // AXI4L R
    output wire [AXIL_DATA_WIDTH-1:0] s_axil_rdata,
    output wire [1:0]                 s_axil_rresp,
    output wire                       s_axil_rvalid,
    input  wire                       s_axil_rready  
);

localparam AXI_DATA_WIDTH = SIZE * WIDTH;
localparam AXIL_ADDR_WIDTH = 32;
localparam AXIL_DATA_WIDTH = 32;
localparam AXIL_STRB_WIDTH = AXIL_DATA_WIDTH/8;

wire vld_axi2sa;
wire rdy_sa2axi;

wire vld_sa2axi;
wire rdy_axi2sa;

wire [(SIZE*WIDTH)-1:0] ab_line_axi2sa;
wire [(SIZE*WIDTH)-1:0] c_line_sa2axi;
    
wire                       wr_en_axil2csr;
wire [AXIL_ADDR_WIDTH-1:0] wr_addr_axil2csr;
wire [AXIL_ADDR_WIDTH-1:0] wr_data_axil2csr;
wire                       csr_invalid_addr;
wire                       csr_ok;
assign                     csr_ok = !csr_invalid_addr;

wire                       start;
wire [AXIL_ADDR_WIDTH-1:0] ab_addr;
wire [AXIL_ADDR_WIDTH-1:0] c_addr;

addr_gen_axi #(
    .WIDTH(WIDTH),
    .SIZE(SIZE),
    .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
) addr_gen_axi_inst (
    .clk       (clk),
    .rst_n     (rst_n),
        
    .i_start   (start),
    .i_ab_addr (ab_addr),
    .i_c_addr  (c_addr),
        
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
    .bvalid    (m_axi_bvalid),
    .bready    (m_axi_bready)
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
    
axil2reg #(
    .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH)
) axil2reg_inst (
    .clk            (clk),
    .rst_n          (rst_n),
        
    .s_axil_awaddr  (s_axil_awaddr),
    .s_axil_awprot  (s_axil_awprot),
    .s_axil_awvalid (s_axil_awvalid),
    .s_axil_awready (s_axil_awready),

    .s_axil_wdata   (s_axil_wdata),
    .s_axil_wstrb   (s_axil_wstrb),
    .s_axil_wvalid  (s_axil_wvalid),
    .s_axil_wready  (s_axil_wready),

    .s_axil_bresp   (s_axil_bresp),
    .s_axil_bvalid  (s_axil_bvalid),
    .s_axil_bready  (s_axil_bready),

    .o_wr_en        (wr_en_axil2csr),
    .o_wr_addr      (wr_addr_axil2csr),
    .o_wr_data      (wr_data_axil2csr),
    .i_csr_ok       (csr_ok)
);

sa_csr #(
  .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH)
) sa_csr_inst (
    .clk            (clk),
    .rst_n          (rst_n),

    .i_wr_en        (wr_en_axil2csr),
    .i_wr_addr      (wr_addr_axil2csr),
    .i_wr_data      (wr_data_axil2csr),

    .o_start        (start),
    .o_ab_addr      (ab_addr),
    .o_c_addr       (c_addr),
    .o_invalid_addr (csr_invalid_addr)
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
