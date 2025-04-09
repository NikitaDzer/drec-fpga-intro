`include "assert.vh"

module mux4 #(
    parameter WIDTH = 32
)(
    input wire [WIDTH-1:0] i_i0, i_i1, i_i2, i_i3,
    input wire [1:0]       i_sel,

    output reg [WIDTH-1:0] o_out
);

always @(*) begin
    case ( i_sel )
        2'b00: o_out = i_i0;
        2'b01: o_out = i_i1;
        2'b10: o_out = i_i2;
        2'b11: o_out = i_i3;
    endcase
end

endmodule
