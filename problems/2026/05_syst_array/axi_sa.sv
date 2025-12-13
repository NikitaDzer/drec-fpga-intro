module sa_axi #(
    parameter WIDTH = 16,
    parameter SIZE = 4
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

    // SA ports
    output logic                       vld_axi2sa,
    output logic                       rdy_axi2sa,
    input  logic                       vld_sa2axi,
    input  logic                       rdy_sa2axi,

    output logic [SIZE-1:0][WIDTH-1:0] ab_line,
    input  logic [SIZE-1:0][WIDTH-1:0] c_line
);

localparam AXI_DATA_WIDTH = WIDTH * SIZE;

assign ab_line    = rdata;
assign vld_axi2sa = rvalid;
assign rready     = rdy_sa2axi;

assign wdata      = c_line; 
assign wvalid     = vld_sa2axi;
assign rdy_axi2sa = wready;

logic [$clog2(SIZE):0] c_rows_count = 0;
assign wlast = (c_rows_count == SIZE-1) & vld_sa2axi;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        c_rows_count <= 0;
    else begin
        if (vld_sa2axi)
            c_rows_count <= (c_rows_count == SIZE-1) ? 0 : c_rows_count + 1;
    end
end

endmodule
