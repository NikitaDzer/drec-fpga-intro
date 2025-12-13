module axi_addr_gen_fixed #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter AXI_ADDR_WIDTH = 32
)(
    // Clock and reset
    input  logic                      clk,
    input  logic                      rst_n,
    
    // Control signals
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

// FSM states
typedef enum logic [1:0] {
    WAIT_B,
    WAIT_A,
    SAVE_C
} state_t;
    
state_t state;
    
assign arsize = $clog2(AXI_DATA_WIDTH/8)[2:0];
assign awsize = $clog2(AXI_DATA_WIDTH/8)[2:0];

// INCR Burst
assign arburst = 2'b01;
assign awburst = 2'b01;

// AXI4 uses len-1
assign arlen = BURST_LEN - 1;
assign awlen = BURST_LEN - 1;

assign arvalid = i_start & (state == WAIT_B || state == WAIT_A);
assign araddr  = state == WAIT_B
    ? base_addr_b : state == WAIT_A
    ? base_addr_a
    : 0;

assign awvalid = i_start & state == WAIT_A;
assign awaddr = state == WAIT_A ? base_addr_c : 0;

// FSM
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= WAIT_B;
    end else begin
        case (state)
            WAIT_B: begin
                if (arvalid & arready) begin
                    state <= WAIT_A;
                end
            end
                
            WAIT_A: begin
                if (arvalid & arready & awvalid & awready) begin
                    state <= SAVE_C;
                end
            end
                
            SAVE_C: begin
                state <= WAIT_B;
            end

            default: state <= state;
        endcase
    end
end
    
endmodule
