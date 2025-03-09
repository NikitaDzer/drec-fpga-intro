`timescale 1ns/1ps
`include "assert.vh"

module testbench;

reg clk   = 1'b0;
reg rst_n = 1'b1;

always begin
    #1 clk <= ~clk;
end

wire [7:0] out;

lfsr lfsr_inst (
    .clk(clk),
    .rst_n(rst_n),
    .o_out(out)
);

initial begin
    $dumpvars;
    $display("[lfsr] Test started.");

    #600

    $display("[lfsr] Test done.");
    $finish;
end

endmodule

