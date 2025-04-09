`include "bu.mac.vh"

module bu(
    input wire [31:0] i_a,
    input wire [31:0] i_b,
    input wire [2:0]  i_cmp_op,

    output reg        o_taken
);

wire signed [31:0] signed_i_a = i_a;
wire signed [31:0] signed_i_b = i_b;

always @( * ) begin
    case ( i_cmp_op )
        `BU_BEQ:  o_taken = i_a == i_b; 
        `BU_BNE:  o_taken = i_a != i_b;
        `BU_BLT:  o_taken = signed_i_a < signed_i_b;
        `BU_BGE:  o_taken = signed_i_a >= signed_i_b;
        `BU_BLTU: o_taken = i_a < i_b;
        `BU_BGEU: o_taken = i_a >= i_b;
        `BU_PT:   o_taken = 1;

        default: o_taken = 0;
    endcase
end

endmodule
