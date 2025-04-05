`ifndef FP16CONST_H
`define FP16CONST_H

localparam FP16_INFINITY = 16'h7c00;
localparam FP16_NAN      = 16'h7e00;

localparam FP16_INFINITY_NO_SIGN = 15'h7c00;
localparam FP16_NAN_NO_SIGN      = 15'h7e00;

localparam FP16_BIAS = 15;

`endif
