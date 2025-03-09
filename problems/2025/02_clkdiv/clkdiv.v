module clkdiv #(
    parameter F0 = 50_000_000,
    parameter F1 = 12_500_000
)(
    input  clk,
    input  rst_n,
    output out
);

localparam CNT_WIDTH = $clog2(F0 / F1);
localparam CNT_MAX = (F0 / F1) - 1;

reg [CNT_WIDTH-1:0] cnt = 0;

assign out = (cnt == CNT_MAX);

always @(posedge clk or negedge rst_n) begin
    if ( !rst_n || cnt == CNT_MAX )
        cnt <= {CNT_WIDTH{1'b0}};
    else
        cnt <= cnt + 1'b1;
end

endmodule
