module fpga_top(
    input  wire CLK,
    input  wire RSTN,

    input  wire RXD,
    output wire TXD,
    output wire [11:0] LED,

    output wire STCP,
    output wire SHCP,
    output wire DS,
    output wire OE
);

localparam RATE = 2_000_000;

assign LED[0] = RXD;
assign LED[4] = TXD;
assign {LED[11:5], LED[3:1]}  = ~10'b0;

// RSTN synchronizer
reg rst_n, RSTN_d;

always @(posedge CLK) begin
    rst_n <= RSTN_d;
    RSTN_d <= RSTN;
end

wire [7:0] rx_data;
wire       rx_vld;

wire  [3:0] anodes;
wire  [7:0] segments;

uart_rx #(
    .FREQ       (50_000_000),
    .RATE       (      RATE)
) u_uart_rx (
    .clk        (CLK       ),
    .rst_n      (rst_n     ),
    .o_data     (rx_data   ),
    .o_vld      (rx_vld    ),
    .i_rx       (RXD       )
);

hex_display hex_display (
    .clk         (CLK       ),
    .rst_n       (rst_n     ),
    .i_data      (rx_data   ),
    .i_we        (rx_vld    ),
    .o_anodes    (anodes    ),
    .o_segments  (segments  )
);

ctrl_74hc595 ctrl_74hc595 (
    .clk        (CLK                ),
    .rst_n      (rst_n              ),
    .i_data     ({segments, anodes} ),
    .o_stcp     (STCP               ),
    .o_shcp     (SHCP               ),
    .o_ds       (DS                 ),
    .o_oe       (OE                 )
);

endmodule
