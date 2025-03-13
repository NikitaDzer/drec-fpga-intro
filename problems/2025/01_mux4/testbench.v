`timescale 1 ns / 100 ps
`include "assert.vh"

module mux_tb;

localparam W = 32;

reg [W-1:0]i0;
reg [W-1:0]i1;
reg [W-1:0]i2;
reg [W-1:0]i3;

reg [1:0]sel;

wire [W-1:0]out;

mux4 #(
    .WIDTH(W)
) mux4_inst (
    .i_i0(i0),
    .i_i1(i1),
    .i_i2(i2),
    .i_i3(i3),
    .i_sel(sel),
    .o_out(out)
);

always begin
    #1
    `assert((sel == 0 && out == i0) ||
            (sel == 1 && out == i1) ||
            (sel == 2 && out == i2) ||
            (sel == 3 && out == i3));

    #1 sel = sel + 1;
end

initial begin
    $dumpvars;
    $display("[mux] Test started (W = %d).", W);

    i0 = 10;
    i1 = 20;
    i2 = 30;
    i3 = 40;
    sel = 0;

    #40

    $display("[mux] Test done!");
    $finish;
end

endmodule
