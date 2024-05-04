`include "assert.vh"

module strober
#( parameter FACTOR = 1 )
(
    input clk,
    input reset,

    output wire strobe
);

assign strobe = (counter == FACTOR - 1);
reg [7:0]counter = 0;

always @( posedge clk )
begin
    `assert( 1 <= FACTOR && FACTOR <= 256 );

    if ( reset == 1'b0 || counter == FACTOR - 1 )
        counter <= 0;
    else
        counter <= counter + 1;
end

endmodule // strober
