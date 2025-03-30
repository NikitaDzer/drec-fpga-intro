`include "assert.vh"

module uart_rx #(
    parameter FREQ = 50_000_000,
    parameter RATE =  2_000_000
) (
    input  wire clk,
    input  wire rst_n,

    output reg  [7:0] o_data,
    output wire       o_vld,
    input  wire       i_rx
);

// Enabling counter
wire en;

// FSM
reg [3:0] state, next_state;

// RX sync
reg rx_sync;

// RX fall
reg rx_sync_d;
wire rx_fall = rx_sync_d && !rx_sync;

// Start receiving
wire start = rx_fall && state == IDLE;

// Shifting register
wire shift_en = en
    && state != IDLE
    && state != START
    && state != STOP;

// Check start bit
localparam START_BIT = 0;
wire is_start_bit = rx_sync == START_BIT;

// Check stop bit
localparam STOP_BIT = 1;
assign o_vld = en && state == STOP && rx_sync == STOP_BIT;

localparam [3:0] IDLE  = {1'b0, 3'd0},
                 START = {1'b0, 3'd1},
                 STOP  = {1'b0, 3'd2},
                 BIT0  = {1'b1, 3'd0},
                 BIT1  = {1'b1, 3'd1},
                 BIT2  = {1'b1, 3'd2},
                 BIT3  = {1'b1, 3'd3},
                 BIT4  = {1'b1, 3'd4},
                 BIT5  = {1'b1, 3'd5},
                 BIT6  = {1'b1, 3'd6},
                 BIT7  = {1'b1, 3'd7};

counter #(
    .CNT_WIDTH  ($clog2(FREQ/RATE)),
    .CNT_LOAD   (FREQ/RATE/2      ),
    .CNT_MAX    (FREQ/RATE-1      )
) cnt (
    .clk        (clk  ),
    .rst_n      (rst_n),
    .i_load     (rx_fall),
    .o_en       (en   )
);

always @( posedge clk ) begin
    rx_sync <= i_rx;
    rx_sync_d <= rx_sync;

    if ( shift_en )
        o_data <= {rx_sync, o_data[7:1]};
end

always @( posedge clk or negedge rst_n ) begin
    if ( !rst_n )
        state <= IDLE;
    else
        state <= !rst_n ? IDLE : next_state;
end

always @( * ) begin
    case ( state )
        IDLE:    next_state = start ? START : state;
        START:   next_state = en
                    ? (is_start_bit ? BIT0 : IDLE)
                    : state;
        BIT0:    next_state = en    ? BIT1  : state;
        BIT1:    next_state = en    ? BIT2  : state;
        BIT2:    next_state = en    ? BIT3  : state;
        BIT3:    next_state = en    ? BIT4  : state;
        BIT4:    next_state = en    ? BIT5  : state;
        BIT5:    next_state = en    ? BIT6  : state;
        BIT6:    next_state = en    ? BIT7  : state;
        BIT7:    next_state = en    ? STOP  : state;
        STOP:    next_state = en    ? IDLE  : state;
        default: next_state = state;
    endcase
end

endmodule
