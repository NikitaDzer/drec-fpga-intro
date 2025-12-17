module delay_line #(
    parameter WIDTH = 16,
    parameter SIZE = 4
) (
    input  logic                       clk,
    input  logic                       rst_n,

    input  logic [SIZE-1:0][WIDTH-1:0] i_data,
    output logic [SIZE-1:0][WIDTH-1:0] o_data
);

generate

assign o_data[0] = i_data[0];

for (genvar i = 1; i < SIZE; i++) begin : sr_gen
    sr #(.WIDTH(WIDTH), .SIZE(i)) sr_inst (
        .clk   (clk),
        .rst_n (rst_n),
        .i_data(i_data[i]),
        .o_data(o_data[i])
    );
end
endgenerate

endmodule
