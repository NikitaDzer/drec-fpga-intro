`include "alu.mac.vh"

module control(
    input [31:0]instr,
    input [31:0]alu_result,

    output reg [31:0]imm32,
    output reg rf_we,
    output reg [2:0]alu_op,
    output reg has_imm,
    output reg mem_we,
    output reg branch_taken,
    output reg lr,
    output reg direct_branch
);

wire [6:0]opcode = instr[6:0];
wire [2:0]funct3 = instr[14:12];
wire [1:0]funct2 = instr[26:25];
wire [4:0]funct5 = instr[31:27];

always @(*) begin
    rf_we = 1'b0;
    alu_op = 3'b0;
    imm32 = 32'b0;
    has_imm = 1'b0;
    mem_we = 1'b0;
    branch_taken = 1'b0;
    lr = 1'b0;
    direct_branch = 1'b0;

    casex ({funct5, funct2, funct3, opcode})
        17'b?????_??_000_0010011: // ADDI
        begin
            rf_we = 1'b1;
            has_imm = 1'b1;
            imm32 = {{20{instr[31]}}, instr[31:20]};
            alu_op = `ALU_ADD;

            $monitor("%-4d ctrl> %s", $time, "ADDI");
        end

        17'b00000_00_000_0110011: // ADD
        begin
            rf_we = 1'b1;
            has_imm = 1'b0;
            alu_op = `ALU_ADD;

            $monitor("%-4d ctrl> %s", $time, "ADD");
        end

        17'b01000_??_000_0110011: // SUB
        begin
            rf_we = 1'b1;
            has_imm = 1'b0;
            alu_op = `ALU_SUB;

            $monitor("%-4d ctrl> %s", $time, "SUB");
        end

        17'b?????_??_100_0010011: // XORI
        begin
            rf_we = 1'b1;
            has_imm = 1'b1;
            imm32 = {{20{instr[31]}}, instr[31:20]};
            alu_op = `ALU_XOR;

            $monitor("%-4d ctrl> %s", $time, "XORI");
        end

        17'b00000_00_100_0110011: // XOR
        begin
            rf_we = 1'b1;
            has_imm = 1'b0;
            alu_op = `ALU_XOR;

            $monitor("%-4d ctrl> %s", $time, "XOR");
        end

        17'b?????_??_110_0010011: // ORI
        begin
            rf_we = 1'b1;
            has_imm = 1'b1;
            imm32 = {{20{instr[31]}}, instr[31:20]};
            alu_op = `ALU_OR;

            $monitor("%-4d ctrl> %s", $time, "ORI");
        end

        17'b00000_00_110_0110011: // OR
        begin
            rf_we = 1'b1;
            has_imm = 1'b0;
            alu_op = `ALU_OR;

            $monitor("%-4d ctrl> %s", $time, "OR");
        end

        17'b?????_??_111_0010011: // ANDI
        begin
            rf_we = 1'b1;
            has_imm = 1'b1;
            imm32 = {{20{instr[31]}}, instr[31:20]};
            alu_op = `ALU_AND;

            $monitor("%-4d ctrl> %s", $time, "ANDI");
        end

        17'b00000_00_111_0?10011: // AND
        begin
            rf_we = 1'b1;
            has_imm = 1'b0;
            alu_op = `ALU_AND;

            $monitor("%-4d ctrl> %s", $time, "AND");
        end

        17'b00000_00_011_0110011: // SLTU
        begin
            rf_we = 1'b1;
            has_imm = 1'b0;
            alu_op = `ALU_SLTU;

            $monitor("%-4d ctrl> %s", $time, "SLTU");
        end

        17'b00000_01_000_0110011: // MUL 
        begin
            rf_we = 1'b1;
            has_imm = 1'b0;
            alu_op = `ALU_MUL;

            $monitor("%-4d ctrl> %s", $time, "MUL");
        end

        17'b?????_??_010_0100011: // SW
        begin
            rf_we = 1'b0;
            mem_we = 1'b1;
            has_imm = 1'b1;
            imm32 = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            alu_op = `ALU_ADD;

            $monitor("%-4d ctrl> %s", $time, "SW");
        end

        17'b?????_??_000_1100011: // BEQ
        begin
            rf_we = 1'b0;
            has_imm = 1'b0;
            imm32 = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            alu_op = `ALU_SUB;
            direct_branch = 1'b1;
            branch_taken = alu_result == 0;
            lr = 1'b0;

            $monitor("%-4d ctrl> %s", $time, "BEQ");
        end

        17'b?????_??_001_1100011: // BNE
        begin
            rf_we = 1'b0;
            has_imm = 1'b0; // imm plays role of address offset, not immediate operand.
            imm32 = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            alu_op = `ALU_SUB;
            direct_branch = 1'b1;
            branch_taken = alu_result != 0;
            lr = 1'b0;

            $monitor("%-4d ctrl> %s", $time, "BNE");
        end

        17'b?????_??_???_1101111: // JAL
        begin
            rf_we = 1'b1;
            has_imm = 1'b0;
            imm32 = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            direct_branch = 1'b1;
            branch_taken = 1'b1;
            lr = 1'b1;

            $monitor("%-4d ctrl> %s", $time, "JAL");
        end

        17'b?????_??_000_1100111: // JALR
        begin
            rf_we = 1'b1;
            has_imm = 1'b1;
            imm32 = {{20{instr[31]}}, instr[31:20]};
            alu_op = `ALU_ADD;
            direct_branch = 1'b0;
            branch_taken = 1'b1;
            lr = 1'b1;

            $monitor("%-4d ctrl> %s", $time, "JALR");
        end

        default:
        begin
            $monitor("%-4d ctrl> %s funct5 = %h, funct2 = %h, funct3 = %h, opcode = %h",
                $time, "UNKNOWN INSTRUCTION", funct5, funct2, funct3, opcode);
        end
    endcase
end

endmodule
