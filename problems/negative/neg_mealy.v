module neg_mealy
(
    input clk,
    input R,
    input A,
    output Q 
);

reg reg_Q = 0;
reg S = 0;

assign Q = reg_Q;

always @( posedge clk ) begin
    if ( R == 1 )
        S <= 0;
    else 
        S <= S | A;

    reg_Q <= S ^ A;
end

endmodule
