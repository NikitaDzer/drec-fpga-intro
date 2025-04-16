`timescale 1ns/1ps

module system_top_tb;

reg clk   = 1'b0;
reg rst_n = 1'b0;

wire [3:0] anodes;
wire [7:0] segments;

always begin
    #1 clk <= ~clk;
end

initial begin
    @(posedge clk)
    @(posedge clk)
    rst_n <= 1'b1;
end

system_top system_top (
    .clk(clk),
    .rst_n(rst_n),

    .anodes(anodes),
    .segments(segments)
);

initial begin
    $dumpvars;
    #1500 $finish;
end

endmodule
