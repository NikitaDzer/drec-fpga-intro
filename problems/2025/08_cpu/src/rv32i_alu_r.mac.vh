`ifndef RV32I_ALU_R_MAC_H
`define RV32I_ALU_R_MAC_H

`define RV32I_ALU_R_OPCODE 7'b0110011

`define RV32I_ALU_R_F3_ADD  3'h0
`define RV32I_ALU_R_F3_SUB  3'h0
`define RV32I_ALU_R_F3_XOR  3'h4
`define RV32I_ALU_R_F3_OR   3'h6
`define RV32I_ALU_R_F3_AND  3'h7
`define RV32I_ALU_R_F3_SLL  3'h1
`define RV32I_ALU_R_F3_SRL  3'h5
`define RV32I_ALU_R_F3_SRA  3'h5
`define RV32I_ALU_R_F3_SLT  3'h2
`define RV32I_ALU_R_F3_SLTU 3'h3

`define RV32I_ALU_R_F7_ADD  7'h00
`define RV32I_ALU_R_F7_SUB  7'h20
`define RV32I_ALU_R_F7_XOR  7'h00
`define RV32I_ALU_R_F7_OR   7'h00
`define RV32I_ALU_R_F7_AND  7'h00
`define RV32I_ALU_R_F7_SLL  7'h00
`define RV32I_ALU_R_F7_SRL  7'h00
`define RV32I_ALU_R_F7_SRA  7'h20
`define RV32I_ALU_R_F7_SLT  7'h00
`define RV32I_ALU_R_F7_SLTU 7'h00

`endif
