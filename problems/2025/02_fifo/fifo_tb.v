`timescale 1ns/1ps
`include "assert.vh"

module testbench;

reg clk   = 1'b0;
reg rst_n = 1'b1;

always begin
    #1 clk <= ~clk;
end

reg       wr_data_en = 0;
reg [7:0] wr_data = 0;

reg       rd_data_en = 0;
wire[7:0] rd_data;

wire full;
wire empty;

fifo fifo_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_wr_en(wr_data_en),
    .i_wr_data(wr_data),
    .i_rd_en(rd_data_en),
    .o_rd_data(rd_data),
    .o_full(full),
    .o_empty(empty)
);

initial begin
    $dumpvars;
    $display("[fifo] Test started.");

    #1 wr_data <= 8'h5; wr_data_en <= 1;
    #2 wr_data <= 8'h6;
    #2 wr_data <= 8'h7;
    #2 wr_data <= 8'h8;
    #2 `assert(full == 1); wr_data_en <= 0;

    #2 rd_data_en <= 1;
    #2 `assert(rd_data == 8'h5);
    #2 `assert(rd_data == 8'h6);
    #2 `assert(rd_data == 8'h7);
    #2 `assert(rd_data == 8'h8);
    #2 `assert(empty == 1); rd_data_en <= 0;

    #2 wr_data <= 8'h9; wr_data_en <= 1;
    #2 wr_data <= 8'h10; rd_data_en <= 1;
    #2 wr_data_en <= 0;
    `assert(rd_data == 8'h9);
    #2 `assert(rd_data == 8'h10);
    `assert(empty == 1);

    $display("[fifo] Test done.");
    $finish;
end

endmodule

