module mem_xbar #(
    parameter DATA_START = 0,
    parameter DATA_LIMIT = 0,
    parameter MMIO_START = 0,
    parameter MMIO_LIMIT = 0
)(
    input  wire        clk,

    input  wire [29:0] i_addr,
    input  wire [31:0] i_data,
    input  wire        i_wren,
    input  wire  [3:0] i_mask,
    output reg  [31:0] o_data,

    output reg  [29:0] o_dmem_addr,
    output wire [31:0] o_dmem_data,
    output reg         o_dmem_wren,
    output wire  [3:0] o_dmem_mask,
    input  wire [31:0] i_dmem_data,

    output reg  [29:0] o_mmio_addr,
    output wire [31:0] o_mmio_data,
    output reg         o_mmio_wren,
    output wire  [3:0] o_mmio_mask,
    input  wire [31:0] i_mmio_data
);

assign o_dmem_data = i_data;
assign o_dmem_mask = i_mask;

assign o_mmio_data = i_data;
assign o_mmio_mask = i_mask;

reg [29:0] addr;

always @( posedge clk ) begin
    addr <= i_addr;
end

always @( * ) begin
    if ( DATA_START <= i_addr && i_addr < DATA_LIMIT ) begin
        o_dmem_addr = i_addr - DATA_START;
        o_dmem_wren = i_wren;

        o_mmio_wren = 1'b0;
        o_mmio_addr = 0;
    end
    else if ( MMIO_START <= i_addr && i_addr < MMIO_LIMIT ) begin
        o_dmem_addr = 0;
        o_dmem_wren = 1'b0;

        o_mmio_addr = i_addr - MMIO_START;
        o_mmio_wren = i_wren;
    end else begin
        o_dmem_wren = 1'b0;
        o_dmem_addr = 0;

        o_mmio_wren = 1'b0;
        o_mmio_addr = 0;
    end

    if ( DATA_START <= addr && addr < DATA_LIMIT )
        o_data      = i_dmem_data;
    else if ( MMIO_START <= addr && addr < MMIO_LIMIT )
        o_data      = i_mmio_data;
    else
        o_data      = 0;
end

endmodule
