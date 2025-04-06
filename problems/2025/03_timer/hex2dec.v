module hex2dec (
    input  wire [15:0] i_hex,
    output wire [15:0] o_dec
);

assign o_dec[ 3:0 ] = (i_hex / 1)    % 10;
assign o_dec[ 7:4 ] = (i_hex / 10)   % 10;
assign o_dec[11:8 ] = (i_hex / 100)  % 10;
assign o_dec[15:12] = (i_hex / 1000) % 10;

endmodule
