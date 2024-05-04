`include "assert.vh"

module uart_rx
#(
    parameter FREQ = 1e9,
    parameter BAUD = 115200,
    parameter STOP_BIT = 1
)(
    input clk,
    input in,

    output reg [7:0]data = 0,
    output reg is_receiving = 0,
    output reg is_received = 0
);

`define RX_IDLE   0
`define RX_RECV   1
`define RX_STOP1  2
`define RX_STOP15 3
`define RX_STOP2  4

reg reset = 1'b0;
reg [3:0]state = `RX_IDLE;
reg [3:0]bit = 0;

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

    if ( state != `RX_IDLE && ext_strobe )
        strobe_counter <= strobe_counter + 1;

    case (state)
        `RX_IDLE:
            if (in == 0)
            begin
                state <= `RX_RECV;

                is_receiving <= 1;
                is_received <= 0;

                reset <= 1'b1;
                data <= 0;
                bit <= 0;

                strobe_counter <= 0;
            end

        `RX_RECV:
            if ( strobe )
            begin
                if ( bit != 8 )
                begin
                    data[bit] <= in;
                    bit <= bit + 1;
                end
                else
                begin
                    if ( STOP_BIT == 1 )
                        state <= `RX_STOP1;
                    else if ( STOP_BIT == 1.5 )
                        state <= `RX_STOP15; 
                    else
                        state <= `RX_STOP2;

                    is_received <= 1;
                end
            end

        `RX_STOP2:
            if ( strobe )
            begin
                state <= `RX_STOP1;
            end

        `RX_STOP15:
            if ( ext_strobe )
            begin
                state <= `RX_STOP1;
                strobe_counter <= 0;
            end

        `RX_STOP1:
            if ( strobe )
            begin
                state <= `RX_IDLE;

                is_receiving <= 0;
                reset <= 0;
            end
    endcase
end

endmodule // uart_rx
