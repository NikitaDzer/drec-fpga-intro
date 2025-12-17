module sa_csr #(
   parameter AXI_ADDR_WIDTH = 32
)(
    input  logic                      clk,
    input  logic                      rst_n,

    input  logic                      i_wr_en,
    input  logic [AXI_ADDR_WIDTH-1:0] i_wr_addr,
    input  logic [AXI_ADDR_WIDTH-1:0] i_wr_data,

    output logic                      o_start,
    output logic [AXI_ADDR_WIDTH-1:0] o_ab_addr,
    output logic [AXI_ADDR_WIDTH-1:0] o_c_addr,

    // Indicate invalid address
    output logic                      o_invalid_addr
);

localparam AB_ADDR_MAPPED_ADDR = AXI_ADDR_WIDTH'h0000_0000;
localparam C_ADDR_MAPPED_ADDR  = AXI_ADDR_WIDTH'h0000_0008;

typedef enum logic [1:0] {
    WAIT_B,
    WAIT_A,
    WAIT_C
} state_t;
state_t state;
logic new_state;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 0;
        o_start <= 0;
        o_ab_addr <= 0;
        o_c_addr <= 0;
    end else begin
        if (i_wr_en) begin
            case (i_wr_addr) begin
                AB_ADDR_MAPPED_ADDR: begin
                    if (state == WAIT_C) begin
                        o_invalid_addr <= 1;
                    end else begin
                        o_ab_addr <= i_data;
                        state <= state == WAIT_B ? WAIT_A : WAIT_C;
                    end
                end

                C_ADDR_MAPPED_ADDR: begin
                    if (state != WAIT_C) begin
                        o_invalid_addr <= 1;
                    end
                    o_c_addr  <= i_data;
                default: o_invalid_addr <= 0;
            endcase

            case (state) begin
                WAIT_B: 
            end
        end
    end
end

always_comb begin
    if (i_wr_en) begin
        case (i_wr_addr)
            AB_ADDR_MAPPED_ADDR: begin
                if (state == WAIT_C) begin
                    new_state = state;
                end
        end, C_ADDR_MAPPED_ADDR: o_invalid_addr = 0;
            default:                                 o_invalid_addr = state_changed;
        endcase
    end
end

endmodule
