module axi_sa_top #(
    parameter WIDTH = 16,
    parameter DEPTH = 8,
    parameter AXI_ADDR_WIDTH = 32
)(
    // Clock and reset
    input  logic                      clk,
    input  logic                      rst_n,
    
    // Control interface
    input  logic                      i_start,
    input  logic [AXI_ADDR_WIDTH-1:0] base_addr_a,
    input  logic [AXI_ADDR_WIDTH-1:0] base_addr_b,
    input  logic [AXI_ADDR_WIDTH-1:0] base_addr_c,
    
    // AXI4 Master Interface
    // Read Address Channel
    output logic [AXI_ADDR_WIDTH-1:0] m_axi_araddr,
    output logic                      m_axi_arid,
    output logic [7:0]                m_axi_arlen,
    output logic [2:0]                m_axi_arsize,
    output logic [1:0]                m_axi_arburst,
    output logic [2:0]                m_axi_arprot,
    output logic                      m_axi_arvalid,
    input  logic                      m_axi_arready,
    
    // Read Data Channel
    input  logic [AXI_DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                      m_axi_rid,
    input  logic [1:0]                m_axi_rresp,
    input  logic                      m_axi_rlast,
    input  logic                      m_axi_rvalid,
    output logic                      m_axi_rready,
    
    // Write Address Channel
    output logic [AXI_ADDR_WIDTH-1:0] m_axi_awaddr,
    output logic                      m_axi_awid,
    output logic [7:0]                m_axi_awlen,
    output logic [2:0]                m_axi_awsize,
    output logic [1:0]                m_axi_awburst,
    output logic [2:0]                m_axi_awprot,
    output logic                      m_axi_awvalid,
    input  logic                      m_axi_awready,
    
    // Write Data Channel
    output logic [AXI_DATA_WIDTH-1:0] m_axi_wdata,
    output logic                      m_axi_wvalid,
    input  logic                      m_axi_wready,
    output logic                      m_axi_wlast,
    
    // Write Response Channel
    input  logic [1:0]                   m_axi_bresp,
    input  logic                         m_axi_bid,
    input  logic                         m_axi_bvalid,
    output logic                         m_axi_bready
);
    
localparam SIZE = 4;
localparam AXI_DATA_WIDTH = SIZE * WIDTH;

    logic sa_i_vld;
    logic sa_i_rdy;
    logic sa_o_vld;
    logic sa_o_rdy;
    logic [SIZE-1:0][WIDTH-1:0] sa_i_ab_line;
    logic [SIZE-1:0][WIDTH-1:0] sa_o_c;
    
    // Instantiate address generator
    axi_addr_gen_fixed #(
        .WIDTH(WIDTH),
        .SIZE(SIZE),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) addr_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        .i_start(i_start),
        .base_addr_a(base_addr_a),
        .base_addr_b(base_addr_b),
        .base_addr_c(base_addr_c),
        
        // AXI Read Address
        .araddr(m_axi_araddr),
        .arlen(m_axi_arlen),
        .arsize(m_axi_arsize),
        .arburst(m_axi_arburst),
        .arvalid(m_axi_arvalid),
        .arready(m_axi_arready),
        
        // AXI Write Address
        .awaddr(m_axi_awaddr),
        .awlen(m_axi_awlen),
        .awsize(m_axi_awsize),
        .awburst(m_axi_awburst),
        .awvalid(m_axi_awvalid),
        .awready(m_axi_awready)
    );
    
    // Instantiate data controller
    systolic_data_ctrl_fixed #(
        .WIDTH(WIDTH),
        .SIZE(SIZE),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH)
    ) data_ctrl_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        // AXI Read Data
        .rdata(m_axi_rdata),
        .rvalid(m_axi_rvalid),
        .rready(m_axi_rready),
        .rlast(m_axi_rlast),
        
        // AXI Write Data
        .wdata(m_axi_wdata),
        .wvalid(m_axi_wvalid),
        .wready(m_axi_wready),
        .wlast(m_axi_wlast),
        
        // AXI Write Response
        .bvalid(m_axi_bvalid),
        .bready(m_axi_bready),
        
        // To systolic array
        .sa_i_vld(sa_i_vld),
        .sa_i_rdy(sa_i_rdy),
        .sa_o_vld(sa_o_vld),
        .sa_o_rdy(sa_o_rdy),
        .sa_i_ab_line(sa_i_ab_line),
        .sa_o_c(sa_o_c)
    );
    
    // Instantiate systolic array
    sa_credit_based #(
        .WIDTH(WIDTH),
        .SIZE(SIZE),
        .DEPTH(DEPTH)
    ) systolic_array_inst (
        .clk(clk),
        .rst_n(rst_n),
        
        .i_vld(sa_i_vld),
        .i_rdy(sa_i_rdy),
        .o_vld(sa_o_vld),
        .o_rdy(sa_o_rdy),
        
        .i_ab_line(sa_i_ab_line),
        .o_c(sa_o_c)
    );
    
    // The systolic array internally:
    // 1. Receives B matrix first (SIZE rows)
    // 2. Receives A matrix next (SIZE rows)
    // 3. Produces C matrix outputs
    
    // The data controller ensures:
    // - B matrix is loaded completely before starting A
    // - A matrix loading triggers C matrix saving
    
endmodule
