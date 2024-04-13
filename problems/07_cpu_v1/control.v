`include "alu.mac.vh"

module control(
    input [31:0]instr,

    output reg [11:0]imm12,
    output reg rf_we,
    output reg [2:0]alu_op,
    output reg is_src_b_imm
);

wire [6:0]opcode = instr[6:0];/* Problem 3: extract field 'opcode' from instruction. */
wire [2:0]funct3 = instr[14:12];/* Problem 3: extract field 'funct3' from instruction. */
wire [1:0]funct2 = instr[26:25];
wire [4:0]funct5 = instr[31:27];

always @(*) begin
    rf_we = 1'b0;
    imm12 = 12'b0;
    alu_op = 3'b0;

    is_src_b_imm = opcode == 7'b0010011;

    casez ({funct5, funct2, funct3, opcode})
        17'b?????_??_000_0?10011: // ADDI, ADD
        begin 
            rf_we = 1'b1;
            imm12 = instr[31:20];
            alu_op = `ALU_ADD;
        end

        17'b01000_??_000_0110011: // SUB
        begin
            rf_we = 1'b1;
            alu_op = `ALU_SUB;
        end

        10'b100_0?10011: // XORI, XOR
        begin
            rf_we = 1'b1;
            imm12 = instr[31:20];
            alu_op = `ALU_XOR;
        end

        10'b110_0?10011: // ORI, OR
        begin
            rf_we = 1'b1;
            imm12 = instr[31:20];
            alu_op = `ALU_OR;
        end

        10'b111_0?10011: // ANDI, AND
        begin
            rf_we = 1'b1;
            imm12 = instr[31:20];
            alu_op = `ALU_AND;
        end

        10'b010_0?10011: // SLTI, SLT,
        begin
            rf_we = 1'b1;
            imm12 = instr[31:20];
            alu_op = `ALU_SLT;
        end

        10'b011_0?10011: // SLTIU, SLTU
        begin
            rf_we = 1'b1;
            imm12 = instr[31:20];
            alu_op = `ALU_SLTU;
        end

        10'b001_0?10011: // SLLI, SLL
        begin
            rf_we = 1'b1;
            imm12 = instr[31:20];
            alu_op = `ALU_SLL;
        end

        default: ;
    endcase

    $strobe("c> alu_op: %h, rf_we: %h", alu_op, rf_we);
end

endmodule
