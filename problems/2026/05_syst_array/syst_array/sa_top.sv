module sa_top #(
    parameter WIDTH = 16,
    parameter SIZE = 4
)(
    input  logic                       clk,
    input  logic                       rst_n,

    input  logic                       i_we,
    input  logic                       i_a_vld,
    input  logic                       i_c_vld,
    input  logic [SIZE-1:0][WIDTH-1:0] i_a_line,

    output logic                       o_c_vld,
    output logic [SIZE-1:0][WIDTH-1:0] o_c_line
);


// Delayed input data and valid lines
logic [SIZE-1:0]            we_line;
logic [SIZE-1:0]            a_vld_line;
logic [SIZE-1:0]            c_vld_line_top2core;
logic [SIZE-1:0][WIDTH-1:0] a_line;

// Delay input write-enable line
we_line #(.SIZE(SIZE)) we_line_inst (
    .clk       (clk),
    .rst_n     (rst_n),

    .i_we      (i_we),
    .o_we_line (we_line)
);

// Delay input A-vld line
delay_line #(.WIDTH(1), .SIZE(SIZE)) dl_a_vld_inst (
    .clk    (clk),
    .rst_n  (rst_n),

    .i_data ({SIZE{i_a_vld}}),
    .o_data (a_vld_line)
);

// Delay input C-vld line
delay_line #(.WIDTH(1), .SIZE(SIZE)) dl_c_vld_top2core_inst (
    .clk    (clk),
    .rst_n  (rst_n),

    .i_data ({SIZE{i_c_vld}}),
    .o_data (c_vld_line_top2core)
);

// Delay input A line
delay_line #(.WIDTH(WIDTH), .SIZE(SIZE)) dl_a_inst (
    .clk    (clk),
    .rst_n  (rst_n),

    .i_data (i_a_line),
    .o_data (a_line)
);


// Delayed output data and valid lines
logic [SIZE-1:0]            c_vld_line_core2top;
logic [SIZE-1:0]            c_vld_line_delayed_core2top;
logic [SIZE-1:0][WIDTH-1:0] c_line_core2top;
assign o_c_vld = &c_vld_line_delayed_core2top;

// Delay output C-vld line
delay_line_rev #(.WIDTH(1), .SIZE(SIZE)) dl_c_vld_core2top_inst (
    .clk    (clk),
    .rst_n  (rst_n),

    .i_data (c_vld_line_core2top),
    .o_data (c_vld_line_delayed_core2top)
);

// Delay output C line
delay_line_rev #(.WIDTH(WIDTH), .SIZE(SIZE)) dl_c_core2top_inst (
    .clk    (clk),
    .rst_n  (rst_n),

    .i_data (c_line_core2top),
    .o_data (o_c_line)
);


// Systolic array core
sa_core #(.WIDTH(WIDTH), .SIZE(SIZE)) sa_core_inst(
    .clk          (clk),
    .rst_n        (rst_n),

    .i_we_line    (we_line),
    .i_a_vld_line (a_vld_line),
    .i_c_vld_line (c_vld_line_top2core),
    .i_a_line     (a_line),

    .o_c_vld_line (c_vld_line_core2top),
    .o_c_line     (c_line_core2top)
);

endmodule
