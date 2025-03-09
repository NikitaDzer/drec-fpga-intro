module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 4
) (
    input wire clk,
    input wire rst_n, 

    input wire                  i_wr_en,
    input wire [DATA_WIDTH-1:0] i_wr_data,

    input  wire                  i_rd_en,
    output reg  [DATA_WIDTH-1:0] o_rd_data,

    output wire o_full,
    output wire o_empty
);

localparam ADDR_WIDTH = $clog2(DEPTH);
    
reg [DATA_WIDTH-1:0] fifo_mem [DEPTH-1:0];
    
reg [ADDR_WIDTH-1:0] wr_ptr = 0;
reg [ADDR_WIDTH-1:0] rd_ptr = 0;
reg [ADDR_WIDTH:0] count = 0;

assign o_full = (count == DEPTH);
assign o_empty = (count == 0);

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
        count <= 0;
    end else begin
        if ( i_wr_en && !o_full ) begin
            fifo_mem[wr_ptr] <= i_wr_data;
            wr_ptr <= wr_ptr + 1;
        end

        if ( i_rd_en && !o_empty ) begin
            o_rd_data <= fifo_mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end

        if ( i_wr_en && !o_full && !i_rd_en )
            count <= count + 1;
        else if ( i_rd_en && !o_empty && !i_wr_en )
            count <= count - 1;
    end
end

endmodule
