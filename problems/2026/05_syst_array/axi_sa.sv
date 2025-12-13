module systolic_data_ctrl_fixed #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter AXI_DATA_WIDTH = WIDTH * SIZE
)(
    // Clock and reset
    input  logic                      clk,
    input  logic                      rst_n,
    
    // AXI4 Master Read Data Channel
    input  logic [AXI_DATA_WIDTH-1:0] rdata,
    input  logic                      rvalid,
    output logic                      rready,
    input  logic                      rlast,
    
    // AXI4 Master Write Data Channel
    output logic [AXI_DATA_WIDTH-1:0] wdata,
    output logic                      wvalid,
    input  logic                      wready,
    output logic                      wlast,
    
    // AXI4 Write Response Channel
    input  logic                      bvalid,
    output logic                      bready,
    
    // Interface to systolic array
    output logic                      sa_i_vld,
    output logic                      sa_i_rdy,
    input  logic                      sa_o_vld,
    input  logic                      sa_o_rdy,
    output logic [SIZE-1:0][WIDTH-1:0] sa_i_ab_line,
    input  logic [SIZE-1:0][WIDTH-1:0] sa_o_c
);

assign sa_i_ab_line = rdata;
assign sa_i_vld = rvalid;
assign rready = sa_o_rdy;

assign wdata  = sa_o_c;
assign wvalid = sa_o_vld;
assign sa_i_rdy = wready;

logic [$clog2(SIZE):0] count = 0;
assign wlast = (count == SIZE-1) & sa_o_vld;

assign bready = 1;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        count <= 0;
    else begin
        if (sa_o_vld)
            count <= (count == SIZE-1) ? 0 : count + 1;
    end
end

endmodule
