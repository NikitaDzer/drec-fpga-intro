module clk_div
#( parameter X = 2 )
(
    input clk_in,
    output clk_out
);

reg [X-1:0]counter = (16'd1 << X) - 1;

assign clk_out = (counter == 0);

always @( posedge clk_in ) begin
    if ( counter == (16'd1 << X) )
        counter <= 0;
    else
        counter <= counter + 1;
end

endmodule
