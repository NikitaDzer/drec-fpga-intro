module shift_reg (
    input wire clk,
    input wire rst_n,
    input wire [15:0] i_wr_data,
    input wire i_wr_data_en,
    input wire i_wr_bit,
    output wire o_out,
    output wire [15:0] o_whole_reg
);

reg [15:0] shift_register = 16'b0;
assign o_out = shift_register[15];
assign o_whole_reg = shift_register;

wire need_shift;

clkdiv #(
    .F0(50_000_000),
    .F1(2)
) clkdiv (
    .clk(clk),
    .rst_n(rst_n),
    .out(need_shift)
);

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) 
        shift_register <= 16'b0;
    else if ( i_wr_data_en )
        shift_register <= i_wr_data;
    else if ( need_shift )
        shift_register <= {shift_register[14:0], i_wr_bit};
end

endmodule
