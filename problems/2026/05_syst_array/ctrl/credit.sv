module credit_cnt #(
    parameter DEPTH = 4
)(
    input  logic clk,
    input  logic rst_n,

    input  logic i_inc,
    input  logic i_vld,

    output logic o_vld,
    output logic o_rdy
);

localparam WIDTH = $clog2(DEPTH) + 1;
logic [WIDTH-1:0] count = DEPTH[WIDTH-1:0];

assign o_vld = i_vld & (count > 0);
assign o_rdy = (count > 0);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= DEPTH[WIDTH-1:0];
    end else begin
        unique case ({o_vld, i_inc})
            2'b10: count <= count - 1;
            2'b01: count <= count + 1;
            default: count <= count;
        endcase
    end
end

endmodule
