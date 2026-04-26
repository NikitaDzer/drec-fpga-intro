module sa_csr #(
   parameter AXIL_ADDR_WIDTH = 32
)(
    input  logic                       clk,
    input  logic                       rst_n,

    input  logic                       i_wr_en,
    input  logic [AXIL_ADDR_WIDTH-1:0] i_wr_addr,
    input  logic [AXIL_ADDR_WIDTH-1:0] i_wr_data,

    output logic                       o_start,
    output logic [AXIL_ADDR_WIDTH-1:0] o_ab_addr,
    output logic [AXIL_ADDR_WIDTH-1:0] o_c_addr,

    // Indicate invalid address
    output logic                       o_invalid_addr
);

localparam MATRIX_ADDR_MAPPED_ADDR = 32'h0000_0000;

typedef enum logic [1:0] {
    WAIT_B,
    WAIT_A,
    WAIT_C
} state_t;
state_t state;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= WAIT_B;
        o_start <= 0;
        o_ab_addr <= 0;
        o_c_addr <= 0;
    end else begin
        o_start <= 0;

        if (i_wr_en) begin
            case (state)
                WAIT_B: begin
                    o_ab_addr <= i_wr_data;
                    o_start <= 1;
                    state <= WAIT_A;
                end

                WAIT_A: begin
                    o_ab_addr <= i_wr_data;
                    state <= WAIT_C;
                end

                WAIT_C: begin
                    o_c_addr <= i_wr_data;
                    o_start <= 1;
                    state <= WAIT_B;
                end

                default: state <= state;
            endcase
        end
    end
end

always_comb begin
    case (i_wr_addr)
        MATRIX_ADDR_MAPPED_ADDR: o_invalid_addr = 0;
        default:                 o_invalid_addr = 1;
    endcase
end

endmodule
