module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 4,
    parameter ADDR_WIDTH = $clog2(DEPTH)
) (
    input  logic                  clk,
    input  logic                  rst_n, 

    input  logic                  i_wr_en,
    input  logic [DATA_WIDTH-1:0] i_wr_data,

    input  logic                  i_rd_en,
    output logic [DATA_WIDTH-1:0] o_rd_data,

    output logic                  o_full,
    output logic                  o_empty
);


logic [DATA_WIDTH-1:0] fifo_mem [DEPTH-1:0];
    
logic [ADDR_WIDTH-1:0] wr_ptr = 0;
logic [ADDR_WIDTH-1:0] rd_ptr = 0;
logic [ADDR_WIDTH:0]   count = 0;

logic wr_en;
logic rd_en;

assign o_full  = (count == DEPTH[ADDR_WIDTH:0]);
assign o_empty = (count == 0);

assign wr_en = i_wr_en & !o_full;
assign rd_en = i_rd_en & !o_empty;

assign o_rd_data = fifo_mem[rd_ptr];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        count <= 0;
    end else begin
        if (wr_en) begin
            fifo_mem[wr_ptr] <= i_wr_data;
            wr_ptr <= wr_ptr + 1;
        end

        if (rd_en) begin
            rd_ptr <= rd_ptr + 1;
        end

        unique case ({wr_en, rd_en})
            2'b10: count <= count + 1; // Write only
            2'b01: count <= count - 1; // Read only
            default: count <= count;   // Simultaneous read/write or no changes
        endcase
    end
end

endmodule
