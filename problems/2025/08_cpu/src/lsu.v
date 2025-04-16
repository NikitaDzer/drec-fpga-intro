module lsu (
    input  wire  [31:0] i_base,
    input  wire  [31:0] i_offset,
    input  wire   [3:0] i_size,
    input  wire  [31:0] i_wr_data,
    input  wire         i_is_store,
    output wire  [31:0] o_rd_data,

    output wire  [29:0] o_addr_to_dmem,
    output wire  [31:0] o_wr_data_to_dmem,
    input  wire  [31:0] i_rd_data_from_dmem,
    output wire   [3:0] o_mask_to_dmem,
    output wire         o_mem_we
);

wire [31:0] addr = i_base + i_offset;

assign o_rd_data = 
    i_size == 1 ? {24'b0, i_rd_data_from_dmem[7:0]}  :
    i_size == 2 ? {16'b0, i_rd_data_from_dmem[15:0]} :
                          i_rd_data_from_dmem;

assign o_addr_to_dmem = addr[31:2];
assign o_wr_data_to_dmem = i_wr_data;

assign o_mask_to_dmem =
    i_size == 1 ? 4'b0001 :
    i_size == 2 ? 4'b0011 :
    i_size == 4 ? 4'b1111 :
                  4'b0000;

assign o_mem_we = i_is_store;

endmodule
