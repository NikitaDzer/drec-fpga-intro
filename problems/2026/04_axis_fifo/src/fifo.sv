module fifo #(
    parameter DATA_WIDTH  = 32,
    parameter DEPTH       = 8
) (
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  i_rd_en,
    output logic [DATA_WIDTH-1:0] o_rd_data,

    input  logic                  i_wr_en,
    input  logic [DATA_WIDTH-1:0] i_wr_data,

    output logic                  o_full,
    output logic                  o_empty
);

localparam DEPTH_1 = DEPTH-1;

logic [DEPTH-1:0][DATA_WIDTH-1:0] mem;

logic [$clog2(DEPTH)-1:0] wr_ptr = 0;
logic [$clog2(DEPTH)-1:0] rd_ptr = 0;
logic [$clog2(DEPTH):0]   count = 0;
 
assign o_full  = (count == DEPTH);
assign o_empty = (count == 0);

assign o_rd_data = mem[ rd_ptr ];

 // Receive entry from master, update write pointer
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 0;
        wr_ptr <= 0;
        rd_ptr <= 0;
    end else begin
        if (i_wr_en) begin
            mem[ wr_ptr ] <= i_wr_data;
            wr_ptr <= wr_ptr == DEPTH_1[$clog2(DEPTH)-1:0] ? 0 : wr_ptr + 1;
        end

        if (i_rd_en) begin
            rd_ptr <= rd_ptr == DEPTH_1[$clog2(DEPTH)-1:0] ? 0 : rd_ptr + 1;
        end

        case ({i_wr_en, i_rd_en})
            2'b10: count <= count + 1; // Write only
            2'b01: count <= count - 1; // Read only
            default: count <= count;   // Simultaneous read/write or no changes
        endcase
    end
end

endmodule
