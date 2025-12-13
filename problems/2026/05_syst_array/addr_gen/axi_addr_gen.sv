module axi_addr_gen_fixed #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter AXI_ADDR_WIDTH = 32
)(
    input  logic                      clk,
    input  logic                      rst_n,
    
    // Start signal
    input  logic                      i_start,
    
    // Base addresses
    input  logic [AXI_ADDR_WIDTH-1:0] base_addr_a,
    input  logic [AXI_ADDR_WIDTH-1:0] base_addr_b,
    input  logic [AXI_ADDR_WIDTH-1:0] base_addr_c,
    
    // AXI4 Master Read Address Channel
    output logic [AXI_ADDR_WIDTH-1:0] araddr,
    output logic [7:0]                arlen,
    output logic [2:0]                arsize,
    output logic [1:0]                arburst,
    output logic                      arvalid,
    input  logic                      arready,
    
    // AXI4 Master Write Address Channel
    output logic [AXI_ADDR_WIDTH-1:0] awaddr,
    output logic [7:0]                awlen,
    output logic [2:0]                awsize,
    output logic [1:0]                awburst,
    output logic                      awvalid,
    input  logic                      awready
);

localparam AXI_DATA_WIDTH = WIDTH * SIZE;
localparam BURST_LEN = SIZE;

typedef enum logic [1:0] {
    WAIT_B,
    LOAD_B,
    WAIT_A
} state_t;
    
state_t state;

logic [AXI_ADDR_WIDTH-1:0] b_addr;
logic [$clog2(AXI_DATA_WIDTH):0] b_rows_count;

assign arsize = $clog2(AXI_DATA_WIDTH/8)[2:0];
assign awsize = $clog2(AXI_DATA_WIDTH/8)[2:0];

// INCR Burst
assign arburst = 2'b01;
assign awburst = 2'b01;

// AXI4 uses len-1
assign arlen = state == WAIT_A ? BURST_LEN - 1 : 0;
assign awlen = BURST_LEN - 1;

// Matrix B is loaded starting from last  row
// Matrix A is loaded starting from first row (burst load)
assign araddr  = state == WAIT_B ? base_addr_b + (SIZE - 1) * AXI_DATA_WIDTH/8 
               : state == LOAD_B ? b_addr
                                 : base_addr_a;
assign arvalid = i_start;

// Matrix C address is stored during matrix
assign awvalid = i_start & state == WAIT_A;
assign awaddr = state == WAIT_A ? base_addr_c : 0;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= WAIT_B;
        b_rows_count <= 0;
    end else begin
        case (state)
            WAIT_B: begin
                if (arvalid & arready) begin
                    b_addr <= base_addr_b + (SIZE - 2) * AXI_DATA_WIDTH/8;
                    b_rows_count <= 1;
                    state <= LOAD_B;
                end
            end

            LOAD_B: begin
                if (arvalid & arready) begin
                    b_addr <= b_addr - AXI_DATA_WIDTH/8;
                    b_rows_count <= b_rows_count + 1;

                    if (b_rows_count == SIZE-1)
                        state <= WAIT_A;
                end
            end
                
            WAIT_A: begin
                if (arvalid & arready & awvalid & awready) begin
                    b_rows_count <= 0;
                    state <= WAIT_B;
                end
            end

            default: state <= state;
        endcase
    end
end
    
endmodule
