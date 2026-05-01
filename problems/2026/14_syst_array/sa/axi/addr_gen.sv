module addr_gen_axi #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = WIDTH * SIZE
)(
    input  logic                      clk,
    input  logic                      rst_n,
    
    // Control signal
    input  logic                      i_start,
    output logic                      o_done,
    
    // Base address
    input  logic [AXI_ADDR_WIDTH-1:0] i_ab_addr,
    input  logic [AXI_ADDR_WIDTH-1:0] i_c_addr,
    
    // AXI4 AR
    output logic [AXI_ADDR_WIDTH-1:0] araddr,
    output logic [7:0]                arlen,
    output logic [2:0]                arsize,
    output logic [1:0]                arburst,
    output logic                      arvalid,
    input  logic                      arready,
    
    // AXI4 AW
    output logic [AXI_ADDR_WIDTH-1:0] awaddr,
    output logic [7:0]                awlen,
    output logic [2:0]                awsize,
    output logic [1:0]                awburst,
    output logic                      awvalid,
    input  logic                      awready,

    // AXI4 B
    input  logic                      bvalid,
    output logic                      bready
);


typedef enum logic [1:0] {
    WAIT_B,
    LOAD_B,
    WAIT_A,
    STORE_C
} state_t;
state_t state;
    
assign arsize = $clog2(AXI_DATA_WIDTH/8);
assign awsize = $clog2(AXI_DATA_WIDTH/8);

// INCR burst
assign arburst = 1;
assign awburst = 1;

assign arlen = state == WAIT_A ? SIZE-1 : 0;
assign awlen = SIZE-1;

// Always accept B channel from slave.
assign bready = 1;

// Load matrix B from the last line to the first
// Load matrix A from the first line to the last (burst)
assign arvalid = i_start | state == LOAD_B;
assign araddr  = state == WAIT_B ? i_ab_addr + (AXI_DATA_WIDTH/8) * (SIZE-1)
               : state == LOAD_B ? b_addr
               : i_ab_addr;

// Store matrix C from the first line (burst)
assign awvalid = i_start & state == WAIT_A;
assign awaddr = state == WAIT_A ? i_c_addr : 0;

logic [$clog2(SIZE):0] b_lines_count = 0;
logic [AXI_ADDR_WIDTH-1:0] b_addr = 0;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= WAIT_B;
        b_lines_count <= 0;
        b_addr <= 0;
        o_done <= 1'b0;
    end else begin
        case (state)
            WAIT_B: begin
                if (arvalid & arready) begin
                    state <= LOAD_B;
                    b_lines_count <= 1;
                    b_addr <= i_ab_addr + (AXI_DATA_WIDTH/8) * (SIZE-2);
                    o_done <= 1'b0;
                end
            end

            LOAD_B: begin
                if (arvalid & arready) begin
                    if (b_lines_count == SIZE-1) begin
                        state <= WAIT_A;
                        b_lines_count <= 0;
                        b_addr <= 0;
                    end else begin
                        b_lines_count <= b_lines_count + 1;
                        b_addr <= b_addr - (AXI_DATA_WIDTH/8);
                    end
                end
            end
                
            WAIT_A: begin
                if (arvalid & arready & awvalid & awready) begin
                    state <= STORE_C;
                end
            end

            STORE_C: begin
                if (bvalid & bready) begin
                    state <= WAIT_B;
                    o_done <= 1'b1;
                end
            end

            default: state <= state;
        endcase
    end
end
    
endmodule
