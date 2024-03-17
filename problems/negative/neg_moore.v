module neg_moore
(
    input clk,
    input R,
    input A,
    output Q 
);

reg [1:0]S = 0;

assign Q = ~S[0];

always @( posedge clk ) begin
    if ( R == 1 ) begin
        S[0] <= 0;
        S[1] <= 0;
    end 
    else begin
        S[0] <= ~(A ^ S[1]);
        S[1] <= A | S[1];
    end
end

endmodule
