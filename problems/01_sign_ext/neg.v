module neg
(
    input [31:0]x,
    output [31:0]minus_x
);

/*
*   Problem 3:
*   Describe sign-inversion logic here.
*/
assign minus_x = ~x + 1;

endmodule
