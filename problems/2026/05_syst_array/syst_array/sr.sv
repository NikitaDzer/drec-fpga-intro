module sr #(
    parameter int WIDTH = 16,
    parameter int SIZE = 1
) (
    input  logic             clk,
    input  logic             rst_n,

    input  logic [WIDTH-1:0] i_data,
    output logic [WIDTH-1:0] o_data
);

logic [WIDTH-1:0] reg_data[SIZE-1:0];
assign o_data = reg_data[SIZE-1];

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        for (int i = 0; i < SIZE; i++)
            reg_data[i] <= 0;
    else begin
        reg_data[0] <= i_data;
        for (int i = 1; i < SIZE; i++) begin
            reg_data[i] <= reg_data[i - 1];
        end
    end
end

endmodule
