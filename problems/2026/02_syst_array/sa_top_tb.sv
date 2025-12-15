`timescale 1ns / 1ps

module sa_top_tb;

import "DPI-C" function bit  VerifySA();
import "DPI-C" function void SetElemA(shortint Elem, int Pos);
import "DPI-C" function void SetElemB(shortint Elem, int Pos);
import "DPI-C" function void SetElemC(shortint Elem, int Pos);
import "DPI-C" function void SetSize(int Size);

localparam WIDTH = 16;
localparam SIZE  = 4;

logic clk = 1'b0;
logic rst_n = 1'b1;

logic i_we;
logic i_a_vld;
logic i_c_vld;
logic o_c_vld;

logic [SIZE-1:0][WIDTH-1:0] i_a_line;
logic [SIZE-1:0][WIDTH-1:0] o_c_line;

logic c_vld_correct = 1'b1;

sa_top #(.WIDTH(WIDTH), .SIZE(SIZE)) dut (
    .clk       (clk),
    .rst_n     (rst_n),

    .i_we      (i_we),
    .i_a_vld   (i_a_vld),
    .i_c_vld   (i_c_vld),
    .i_a_line  (i_a_line),

    .o_c_vld   (o_c_vld),
    .o_c_line  (o_c_line)
);

always begin
    #1 clk <= ~clk;
end

function void GenMatrices();
    SetSize(SIZE);

    for (shortint i = 0; i < SIZE; i++) begin
        for (shortint j = 0; j < SIZE; j++) begin
            automatic shortint pos = i * SIZE + j;
            automatic shortint a = pos + 1;
            automatic shortint b = -(pos * 2 + 1);
            SetElemA(a, pos);
            SetElemB(b, pos);
        end
    end
endfunction

// Transposed matrix
function void LoadIdleB();
    for (shortint i = SIZE - 1; i >= 0; i--) begin
        if (i % 2 == 0) begin
            i_we = 0;
            i_a_vld = 0;
            i_a_line = 0;
            @(posedge clk);
            @(posedge clk);
            @(posedge clk);
        end
        for (shortint j = 0; j < SIZE; j++) begin
            automatic shortint pos = i * SIZE + j;
            automatic shortint b = -(pos * 2 + 1);
            i_a_line[j] = b;
        end
        i_we = 1;
        i_a_vld = 1;
        @(posedge clk);
    end

    i_we = 0;
endfunction

function void LoadIdleA();
    for (shortint i = 0; i < SIZE; i++) begin
        if (i == SIZE / 2) begin
            i_a_vld = 0;
            i_c_vld = 0;
            @(posedge clk);
        end
        for (shortint j = 0; j < SIZE; j++) begin
            automatic shortint pos = i * SIZE + j;
            automatic shortint a = pos + 1;
            i_a_line[j] = a;
        end
        i_a_vld = 1;
        i_c_vld = 1;
        @(posedge clk);
    end

    i_a_vld = 0;
    i_c_vld = 0;
endfunction

function void WriteC();
    repeat (SIZE - 2) @(posedge clk);

    for (shortint i = 0; i < SIZE; i++) begin
        if (i == SIZE / 2) begin
            if (o_c_vld == 1'b1)
                c_vld_correct = 0;
            @(posedge clk);
        end else begin
            if (!o_c_vld) begin
                c_vld_correct = 0;
            end
        end
        for (shortint j = 0; j < SIZE; j++) begin
            automatic shortint pos = i * SIZE + j;
            automatic shortint c = o_c_line[j];
            SetElemC(c, pos);
        end
        @(posedge clk);
    end
endfunction


initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    rst_n     = 1;
    i_we      = 0;
    i_a_vld   = 0;
    i_c_vld   = 0;

    @(posedge clk);
    rst_n = 0;
    @(posedge clk);
    rst_n = 1;
    @(posedge clk);

    GenMatrices();
    LoadIdleB();
    LoadIdleA();
    WriteC();
    
    if (VerifySA() & c_vld_correct)
        $display("PASSED");
    else
        $display("FAILED");

    #50 $finish;
end

endmodule
