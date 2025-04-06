module timer (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [15:0] i_init_count,

    output wire [15:0] o_count_dec
);

reg [15:0] count = 16'b0;
wire ce_mls100;

clkdiv #(
    .F0(50_000_000),
    .F1(10)
) clkdiv (
    .clk(clk),
    .rst_n(rst_n),
    .out(ce_mls100)
);

hex2dec hex2dec (
    .i_hex(count),
    .o_dec(o_count_dec)
);

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )
        count <= i_init_count;
    else if ( ce_mls100 ) begin
        if ( count == 0 )
            count <= i_init_count;
        else
            count <= count - 1;
    end
end

endmodule
