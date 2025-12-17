module axil2reg #(
   parameter AXIL_ADDR_WIDTH = 32
) (
   input  logic                       clk,
   input  logic                       rst_n,

   // AXI4L AW
   input  logic [AXIL_ADDR_WIDTH-1:0] s_axil_awaddr,
   input  logic [2:0]                 s_axil_awprot,
   input  logic                       s_axil_awvalid,
   output logic                       s_axil_awready,

   // AXI4L W
   input  logic [AXIL_DATA_WIDTH-1:0] s_axil_wdata,
   input  logic [AXIL_STRB_WIDTH-1:0] s_axil_wstrb,
   input  logic                       s_axil_wvalid,
   output logic                       s_axil_wready,

   // AXI4L B
   output logic [1:0]                 s_axil_bresp,
   output logic                       s_axil_bvalid,
   input  logic                       s_axil_bready,

   // CSR interface
   output logic                       o_wr_en,
   output logic [AXIL_ADDR_WIDTH-1:0] o_wr_addr,
   output logic [AXIL_DATA_WIDTH-1:0] o_wr_data,
   input  logic                       i_csr_ok
);

localparam AXIL_DATA_WIDTH = AXIL_ADDR_WIDTH;
localparam AXIL_STRB_WIDTH = AXIL_ADDR_WIDTH/8;
localparam OKAY = 2'b00, SLVERR = 2'b10;

logic idle, en_d;
logic okay;

assign s_axil_awready = idle && s_axil_wvalid;
assign s_axil_wready  = idle && s_axil_awvalid;

assign s_axil_bresp = (en_d ? i_csr_ok : okay) ? OKAY : SLVERR;
assign s_axil_bvalid = !idle;

assign o_wr_en = idle && s_axil_awvalid && s_axil_wvalid;
assign o_wr_addr = s_axil_awaddr;
assign o_wr_data = s_axil_wdata;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        idle <= 1'b1;
        en_d <= 1'b0;
    end else begin
        idle <= idle ? !(s_axil_awvalid && s_axil_wvalid) : s_axil_bready;
        en_d <= o_wr_en;
    end
end

always_ff @(posedge clk)
    if (en_d) begin
        okay <= i_csr_ok;
    end

endmodule
