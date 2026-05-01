module sa_ctrl_axi #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter AXI_DATA_WIDTH = WIDTH * SIZE
)(
    input  logic                       clk,
    input  logic                       rst_n,
    
    // AXI4 R
    input  logic  [AXI_DATA_WIDTH-1:0] rdata,
    input  logic                       rvalid,
    output logic                       rready,
    input  logic                       rlast,
    
    // AXI4 W
    output logic  [AXI_DATA_WIDTH-1:0] wdata,
    output logic                       wvalid,
    input  logic                       wready,
    output logic                       wlast,
    
    // A-B matrices handshake
    output logic                       vld_axi2sa,
    input  logic                       rdy_sa2axi,

    // C matrix handshake
    output logic                       rdy_axi2sa,
    input  logic                       vld_sa2axi,

    output logic [SIZE-1:0][WIDTH-1:0] ab_line_axi2sa,
    input  logic [SIZE-1:0][WIDTH-1:0] c_line_sa2axi
);


 // Load A-B matrices
assign ab_line_axi2sa = rdata;
assign vld_axi2sa     = rvalid;
assign rready         = rdy_sa2axi;

// Store C matrix
assign wdata      = c_line_sa2axi;
assign wvalid     = vld_sa2axi;
assign rdy_axi2sa = wready;

// Count stored C lines and signal WLAST
logic [$clog2(SIZE):0] c_lines_count = 0;
assign wlast = (c_lines_count == SIZE-1) & vld_sa2axi;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        c_lines_count <= 0;
    else begin
        if (vld_sa2axi)
            c_lines_count <= (c_lines_count == SIZE-1) ? 0 : c_lines_count + 1;
    end
end

endmodule
