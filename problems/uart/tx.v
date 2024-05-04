`include "assert.vh"

module uart_tx
#(
    parameter FREQ = 1e9,
    parameter BAUD = 115200,
    parameter STOP_BIT = 1
)(
    input [7:0]data,
    input clk,
    input enable,

    output reg out = 1
);

`define TX_IDLE   0
`define TX_TRNS   1
`define TX_STOP1  2
`define TX_STOP15 3
`define TX_STOP2  4

reg reset = 1'b0;
reg [3:0]state = `TX_IDLE;
reg [3:0]bit = 0;
reg [7:0]buffer = 0;

wire ext_strobe;
strober 
#( .FACTOR( STOP_BIT == 1.5 ? (FREQ / (2*BAUD)) : (FREQ / BAUD)))
strober(
    .clk( clk),
    .reset( reset),
    .strobe( ext_strobe)
);

reg strobe_counter = 0;
wire strobe = STOP_BIT == 1.5 ? (ext_strobe && strobe_counter == 1) : ext_strobe;

always @( posedge clk )
begin
    `assert( STOP_BIT == 1 || STOP_BIT == 1.5 || STOP_BIT == 2 );

    if ( state != `TX_IDLE && ext_strobe )
        strobe_counter <= strobe_counter + 1;

    case ( state )
        `TX_IDLE:
            if ( enable )
            begin
                state <= `TX_TRNS;

                out <= 1'b0;
                reset <= 1'b1;
                buffer <= data;
                bit <= 0;

                strobe_counter <= 0;
            end

        `TX_TRNS:
            if ( strobe )
            begin
                if ( bit != 8 )
                begin
                    out <= buffer[bit];
                    bit <= bit + 1;
                end
                else 
                begin
                    if ( STOP_BIT == 1 )
                        state <= `TX_STOP1;
                    else if ( STOP_BIT == 1.5 )
                        state <= `TX_STOP15;
                    else
                        state <= `TX_STOP2;

                    out <= 1'b1;
                end
            end

        `TX_STOP2:
            if ( strobe )
            begin
                state <= `TX_STOP1;
            end

        `TX_STOP15:
            if ( ext_strobe )
            begin
                state <= `TX_STOP1;
                strobe_counter <= 0;
            end

        `TX_STOP1:
            if ( strobe )
            begin
                state <= `TX_IDLE;
                reset <= 1'b0;
            end
    endcase
end

endmodule // uart_tx
