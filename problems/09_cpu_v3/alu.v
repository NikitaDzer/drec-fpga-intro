`include "alu.mac.vh"

module alu(
    input [31:0]src_a,
    input [31:0]src_b,
    input [2:0]op,
    output reg [31:0]res
);

wire signed [31:0]signed_src_a = src_a;
wire signed [31:0]signed_src_b = src_b;

always @(*) begin
    case (op)
        `ALU_ADD:
        begin
            res = src_a + src_b;
            $strobe("%-4d aloo> %s res = %h, a = %h, b = %h",
                $time, "ADD", res, src_a, src_b);
        end

        `ALU_SUB:
        begin
            res = src_a - src_b;
            $strobe("%-4d aloo> %s res = %h, a = %h, b = %h",
                $time, "SUB", res, src_a, src_b);
        end

        `ALU_XOR:
        begin
            res = src_a ^ src_b;
            $strobe("%-4d aloo> %s res = %h, a = %h, b = %h",
                $time, "XOR", res, src_a, src_b);
        end

        `ALU_OR:
        begin
            res = src_a | src_b;
            $strobe("%-4d aloo> %s res = %h, a = %h, b = %h",
                $time, "OR", res, src_a, src_b);
        end

        `ALU_AND:
        begin
            res = src_a & src_b;
            $strobe("%-4d aloo> %s res = %h, a = %h, b = %h",
                $time, "AND", res, src_a, src_b);
        end

        `ALU_SLT:
        begin
            res = signed_src_a < signed_src_b;
            $strobe("%-4d aloo> %s res = %h, a = %h, b = %h",
                $time, "SLT", res, src_a, src_b);
        end

        `ALU_SLTU:
        begin
            res = src_a < src_b;
            $strobe("%-4d aloo> %s res = %h, a = %h, b = %h",
                $time, "SLTU", res, src_a, src_b);
        end

        `ALU_MUL:
        begin 
            res = src_a * src_b;
            $strobe("%-4d aloo> %s res = %h, a = %h, b = %h",
                $time, "MUL", res, src_a, src_b);
        end

        default: res = 0;
    endcase
end

endmodule
