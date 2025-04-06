module lfsr (
    input wire clk,
    input wire rst_n,
    output wire [15:0] o_out 
);

wire [15:0] lfsr_reg;
assign o_out = lfsr_reg;

wire feedback = lfsr_reg[15] ^ lfsr_reg[10] ^ lfsr_reg[7] ^ lfsr_reg[5] ^ lfsr_reg[4] ^ lfsr_reg[3] ^ 1;
reg wr_bit = 1'b1;

wire        wr_data_en = 0;
wire [15:0] wr_data = 0;

shift_reg shift_reg_inst (
    .clk(clk),
    .rst_n(rst_n),
    .i_wr_data_en(wr_data_en),
    .i_wr_data(wr_data),
    .i_wr_bit(wr_bit),
    .o_out(),
    .o_whole_reg(lfsr_reg)
);

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )
        wr_bit <= 1'b1;
    else if ( lfsr_reg != 0 )
        wr_bit <= feedback;
    else 
        wr_bit <= 1'b1;
end

endmodule
