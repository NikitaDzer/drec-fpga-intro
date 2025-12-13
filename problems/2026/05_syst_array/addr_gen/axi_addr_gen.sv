module sa_addr_gen #(
    parameter WIDTH = 16,
    parameter SIZE = 4,
    parameter AXI_ADDR_WIDTH = 32
)(
    input  logic                      clk,
    input  logic                      rst_n,
    
    // Start signal
    input  logic                      i_start,
    
    // Base addresses
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

localparam AXI_DATA_WIDTH = WIDTH * SIZE;

typedef enum logic [1:0] {
    WAIT_B,
    LOAD_B,
    WAIT_A
} state_t;
    
state_t state;

logic [AXI_ADDR_WIDTH-1:0]       b_addr;
logic [$clog2(AXI_DATA_WIDTH):0] b_rows_count;

assign bready = 1'b1;

assign arsize = $clog2(AXI_DATA_WIDTH/8)[2:0];
assign awsize = $clog2(AXI_DATA_WIDTH/8)[2:0];

assign arburst = 2'b01;
assign awburst = 2'b01;

// Matrix B: burst size = 1
// Matrix A: burst size = SIZE
assign arlen = SIZE - 1;
assign awlen = SIZE - 1;

// Matrix B is loaded starting from last  row
// Matrix A is loaded starting from first row (burst load)
assign araddr  = i_ab_addr;
assign arvalid = i_start || state == LOAD_B;

assign awvalid = i_start & state == WAIT_A;
assign awaddr = i_c_addr;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= WAIT_B;
        b_addr <= 0;
        b_rows_count <= 0;
    end else begin

        case (state)
            // Load first B row
            WAIT_B: begin
                if (arvalid & arready) begin
                    b_addr <= i_ab_addr + (SIZE - 2) * AXI_DATA_WIDTH/8;
                    b_rows_count <= 1;
                    state <= WAIT_A;
                end
            end

            // Load [1, (SIZE-1)] B rows 
            LOAD_B: begin
                if (arvalid & arready) begin
                    b_addr <= b_addr - AXI_DATA_WIDTH/8;
                    b_rows_count <= b_rows_count + 1;

                    if (b_rows_count == SIZE-1)
                        state <= WAIT_A;
                end
            end
                
            // Load all A rows
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
