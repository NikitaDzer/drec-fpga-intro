module shift_reg (
    input wire clk,
    input wire rst_n,
    input wire [7:0] i_wr_data,
    input wire i_wr_data_en,
    input wire i_wr_bit,
    output wire o_out
);

reg [7:0] shift_register;
assign o_out = shift_register[7];

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) 
        shift_register <= 8'b0;
    else if ( i_wr_data_en )
        shift_register <= i_wr_data;
    else
        shift_register <= {shift_register[6:0], i_wr_bit};
end

endmodule
