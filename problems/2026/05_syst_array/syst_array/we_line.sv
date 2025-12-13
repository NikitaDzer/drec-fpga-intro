module we_line #(
    parameter SIZE = 4
) (
    input  logic            clk,
    input  logic            rst_n,

    input  logic            i_we,
    output logic [SIZE-1:0] o_we_line
);

/**
 * Implementation of delay line with custom input generation.
 *
 * clk ->
 * we        |     1 |     0 |     1
 * we_gen    | 2'b10 | 2'b00 | 2'b01
 * o_we_line | 2'b00 | 2'b10 | 2'b01
 */
logic [SIZE-1:0] we_shift = 1 << (SIZE-1);
logic [SIZE-1:0] we_gen;

// Input signal for delay line
assign we_gen = i_we ? we_shift : 0;

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        we_shift <= 1 << (SIZE-1);
    else if (i_we)
        we_shift <= {we_shift[0], we_shift[SIZE-1:1]};
end

delay_line #(.WIDTH(1), .SIZE(SIZE)) dl_inst (
    .clk   (clk),
    .rst_n (rst_n),

    .i_data(we_gen),
    .o_data(o_we_line)
);

endmodule
