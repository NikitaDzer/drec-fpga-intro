module pe #(
    parameter WIDTH = 16
)(
    input  logic             clk,
    input  logic             rst_n,

    input  logic             i_we,
    input  logic             i_a_vld,
    input  logic             i_c_vld,

    input  logic [WIDTH-1:0] i_a,
    input  logic [WIDTH-1:0] i_c,

    output logic             o_we,
    output logic             o_a_vld,
    output logic             o_c_vld,

    output logic [WIDTH-1:0] o_a,
    output logic [WIDTH-1:0] o_c
);

logic [WIDTH-1:0] b;

// Calculate output C and propagate signals to next PEs
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        b <= 0;
    else begin
        o_we    <= i_we;
        o_a_vld <= i_a_vld;
        o_c_vld <= i_a_vld & i_c_vld;

        o_a     <= i_a;
        o_c     <= i_a * b + i_c;

        // Store element B
        if (i_we)
            b <= i_a;
    end
end

endmodule
