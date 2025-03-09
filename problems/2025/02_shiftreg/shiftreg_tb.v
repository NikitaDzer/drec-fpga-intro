`timescale 1ns/1ps
`include "assert.vh"

module testbench;

reg clk   = 1'b0;
reg rst_n = 1'b1;

always begin
    #1 clk <= ~clk;
end

reg [7:0] wr_data = 0;
reg wr_data_en = 0;
reg wr_bit = 0;
wire out;

shift_reg shift_reg (
    .clk(clk),
    .i_wr_data(wr_data),
    .i_wr_data_en(wr_data_en),
    .i_wr_bit(wr_bit),
    .o_out(out)
);

initial begin
    $dumpvars;
    $display("[shift_reg] Test started.");

    #1 wr_data <= 8'b10100110; wr_data_en <= 1;
    #1 wr_data_en <= 0; 
    `assert(out == 1);
    #2 `assert(out == 0);
    #2 `assert(out == 1);
    #2 `assert(out == 0);
    #2 `assert(out == 0);
    #2 `assert(out == 1);
    #2 `assert(out == 1);
    #2 `assert(out == 0);
    #2 `assert(out == 0);

    #1 wr_data <= 8'b10100110; wr_data_en <= 1; wr_bit <= 1;
    #1 wr_data_en <= 0; 
    `assert(out == 1);
    #2 `assert(out == 0);
    #2 `assert(out == 1);
    #2 `assert(out == 0);
    #2 `assert(out == 0);
    #2 `assert(out == 1);
    #2 `assert(out == 1);
    #2 `assert(out == 0);
    #2 `assert(out == 1);

    $display("[shift_reg] Test done.");
    $finish;
end

endmodule

