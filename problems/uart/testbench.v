`timescale 1 ns / 100 ps

module testbench;

reg clk = 1'b0;

always begin
    #1 clk = ~clk;
end


// Transmitter
reg [7:0]tx_data = 0;
reg tx_enable = 0;
wire tx_out;

uart_tx
#( .FREQ(200), .BAUD(25))
uart_tx(
    .clk( clk),
    .data( tx_data),
    .enable( tx_enable),

    .out( tx_out)
);


// Receiver
wire [7:0]rx_data;
wire rx_is_receiving;
wire rx_is_received;

uart_rx
#( .FREQ(200), .BAUD(25))
uart_rx(
    .clk( clk),
    .in( tx_out),

    .data( rx_data),
    .is_receiving( rx_is_receiving),
    .is_received( rx_is_completed)
);


// Test
initial begin
    $dumpvars;
    #2
    tx_data = 8'hA;
    tx_enable = 1'b1;
    #2
    tx_data = 0;
    tx_enable = 0;
    #2
    tx_data = 8'h0;
    tx_enable = 1'b1;
    #200
    tx_data = 0;
    tx_enable = 0;
    #400 $finish;
end

endmodule
