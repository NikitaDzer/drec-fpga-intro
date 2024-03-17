`timescale 1 ns / 100 ps

module testbench();

reg clk = 1'b0;

always begin
    #1 clk = ~clk;
end

reg R = 0;
reg A = 0;
wire Q;

negative negative( .clk( clk), .R( R), .A( A), .Q( Q));

initial begin
    $dumpvars;
    #1 R = 1;
    #1 R = 0;

    #1 A = 0; #1
    $display( "A=%d, Q=%d", A, Q);
    #1 A = 1; #1
    $display( "A=%d, Q=%d", A, Q);
    #1 A = 1; #1
    $display( "A=%d, Q=%d", A, Q);
    #1 A = 1; #1
    $display( "A=%d, Q=%d", A, Q);

    $finish;
end

endmodule
