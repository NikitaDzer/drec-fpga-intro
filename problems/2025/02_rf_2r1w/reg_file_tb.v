`timescale 1ns/1ps
`include "assert.vh"

module testbench;

reg clk   = 1'b0;
reg rst_n = 1'b1;

always begin
    #1 clk <= ~clk;
end

reg   [4:0] rd_addr1;
wire [31:0] rd_data1;

reg   [4:0] rd_addr2;
wire [31:0] rd_data2;

reg  [4:0] wr_addr = 0;
reg [31:0] wr_data = 0;
reg wr_en = 0;

rf_2r1w rf_2r1w (
    .clk(clk),
    .i_rd_addr1(rd_addr1),
    .o_rd_data1(rd_data1),
    .i_rd_addr2(rd_addr2),
    .o_rd_data2(rd_data2),
    .i_wr_addr(wr_addr),
    .i_wr_data(wr_data),
    .i_wr_en(wr_en)
);

initial begin
    $dumpvars;
    $display("[rf_2r1w] Test started.");

    #1 wr_addr <= 5'd16; wr_data <= 32'hAB; wr_en <= 1;
    #1 wr_en <= 0;

    #1 wr_addr <= 5'd31; wr_data <= 32'hCD; wr_en <= 1; 
    #1 wr_en <= 0;

    #1 wr_addr <= 5'd1; wr_data <= 32'hEF; wr_en <= 1; 
    rd_addr1 <= 5'd16; rd_addr2 <= 5'd31;
    #1 wr_en <= 0;

    `assert(rd_data1 == 32'hAB);
    `assert(rd_data2 == 32'hCD);

    #1 rd_addr1 <= 5'd1; rd_addr2 <= 5'd1;
    #1

    `assert(rd_data1 == 32'hEF);
    `assert(rd_data2 == 32'hEF);

    $display("[rf_2r1w] Test done.");
    $finish;
end

endmodule

