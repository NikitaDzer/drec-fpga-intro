`timescale 1 ns / 100 ps

/*
*   Introduction to FPGA and Verilog
*
*   Viktor Prutyanov, 2019
*
*   Testbench for problem set #02
*/

module testbench();

reg clk = 1'b0;

always begin
    #1 clk = ~clk;
end

/*
*   Problem 2/3:
*   Make an instance of your new module clk_div.
*   Create approprite wires to test it.
*/
wire clk_out;
clk_div clk_div( .clk_in( clk), .clk_out( clk_out));

initial begin
    $dumpvars;      /* Open for dump of signals */
    /*
    *   Problem 2/3:
    *   Stop simulation after several cycles of your (divided) clock.
    */
    #70
    $finish;
end

endmodule
