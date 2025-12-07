module sa_core #(
    parameter WIDTH = 16,
    parameter SIZE = 4
)(
    input  logic                       clk,
    input  logic                       rst_n,

    input  logic [SIZE-1:0]            i_we_line,
    input  logic [SIZE-1:0]            i_a_vld_line,
    input  logic [SIZE-1:0]            i_c_vld_line,
    input  logic [SIZE-1:0][WIDTH-1:0] i_a_line,

    output logic [SIZE-1:0]            o_c_vld_line,
    output logic [SIZE-1:0][WIDTH-1:0] o_c_line
);

logic               we   [SIZE:0][SIZE:0];
logic               a_vld[SIZE:0][SIZE:0];
logic               c_vld[SIZE:0][SIZE:0];
logic [WIDTH - 1:0] a    [SIZE:0][SIZE:0];
logic [WIDTH - 1:0] c    [SIZE:0][SIZE:0];

generate

// Top boundary
for (genvar j = 0; j < SIZE; j++) begin : top_boundary
    assign     c[0][j] = 0;
    assign c_vld[0][j] = i_c_vld_line[j];
    assign    we[0][j] = i_we_line[j];
end

// Bottom boundary
for (genvar j = 0; j < SIZE; j++) begin : bottom_boundary
    assign     o_c_line[j] = c[SIZE][j];
    assign o_c_vld_line[j] = c_vld[SIZE][j];
end

// Left boundary
for (genvar i = 0; i < SIZE; i++) begin : left_boundary
    assign     a[i][0] = i_a_line[i];
    assign a_vld[i][0] = i_a_vld_line[i];
end

for (genvar i = 0; i < SIZE; i++) begin : pe_outer
    for (genvar j = 0; j < SIZE; j++) begin : pe_inner
        pe #(.WIDTH(WIDTH)) pe_inst (
            .clk      (clk),
            .rst_n    (rst_n),

            .i_we     (   we[i][j]),
            .i_a_vld  (a_vld[i][j]),
            .i_c_vld  (c_vld[i][j]),

            .i_a      (    a[i][j]),
            .i_c      (    c[i][j]),

            .o_we     (   we[i+1][j  ]),
            .o_a_vld  (a_vld[i  ][j+1]),
            .o_c_vld  (c_vld[i+1][j  ]),

            .o_a      (a[i  ][j+1]),
            .o_c      (c[i+1][j  ])
        );
    end
end

endgenerate
endmodule
