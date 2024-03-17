`timescale 1 ns / 100 ps

module testbench();

reg clk = 1'b0;

always begin
    #1 clk = ~clk;
end

reg R = 0;
reg A = 0;
wire Q_moore;
wire Q_mealy;

neg_moore neg_moore( .clk( clk), .R( R), .A( A), .Q( Q_moore));
neg_mealy neg_mealy( .clk( clk), .R( R), .A( A), .Q( Q_mealy));

initial begin
    $dumpvars;
    #1 R = 1;
    #1 R = 0;

    #1 A = 0; #1
    $display( "A=%d, Q=%d, Q=%d", A, Q_moore, Q_mealy);
    #1 A = 1; #1
    $display( "A=%d, Q=%d, Q=%d", A, Q_moore, Q_mealy);
    #1 A = 1; #1
    $display( "A=%d, Q=%d, Q=%d", A, Q_moore, Q_mealy);
    #1 A = 1; #1
    $display( "A=%d, Q=%d, Q=%d", A, Q_moore, Q_mealy);

    $finish;
end

endmodule
