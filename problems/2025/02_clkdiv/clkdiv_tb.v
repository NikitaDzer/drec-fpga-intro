`timescale 1ns/1ps
`include "assert.vh"

module testbench;

reg clk   = 1'b0;
reg rst_n = 1'b0;

always begin
    #1 clk <= ~clk;
end

wire clkdiv9600_out;
wire clkdiv38400_out;
wire clkdiv115200_out;

clkdiv #(
    .F0(50_000_000),
    .F1(9_600)
) clkdiv9600(.clk(clk), .rst_n(rst_n), .out(clkdiv9600_out));

clkdiv #(
    .F0(50_000_000),
    .F1(38_400)
) clkdiv38400(.clk(clk), .rst_n(rst_n), .out(clkdiv38400_out));

clkdiv #(
    .F0(50_000_000),
    .F1(115_200)
) clkdiv115200(.clk(clk), .rst_n(rst_n), .out(clkdiv115200_out));

initial begin
    $dumpvars;      /* Open for dump of signals */
    $display("[clkdiv] Test started.");

    rst_n <= 1'b1;

    #15000

    $display("[clkdiv] Test done.");
    $finish;
end

endmodule

