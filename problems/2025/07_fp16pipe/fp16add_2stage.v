/**
 * FP16 adder unit.
 *
 * i_a - first FP16 number
 * i_b - second FP16 number
 * i_rmode - rounding mode:
 *   0 - roundTowardZero,
 *   1 - roundTiesToEven
 *
 * o_res - addition result
 *
 */
module fp16add_2stage (
    input wire        clk,

    input wire [15:0] i_a,
    input wire [15:0] i_b,
    input wire        i_rmode,

    output reg [15:0] o_res
);

`include "fp16const.vh"

// Stage F0
wire       sign_a     = i_a[15];
wire       sign_b     = i_b[15];
wire [4:0] exp_a      = i_a[14:10];
wire [4:0] exp_b      = i_b[14:10];
wire [9:0] mantissa_a = i_a[9:0];
wire [9:0] mantissa_b = i_b[9:0];

wire [14:0] no_sign_a  = i_a[14:0];
wire [14:0] no_sign_b  = i_b[14:0];

wire is_inf_a      = (no_sign_a == FP16_INFINITY_NO_SIGN);
wire is_inf_b      = (no_sign_b == FP16_INFINITY_NO_SIGN); 
wire is_nan_a      = (no_sign_a  > FP16_INFINITY_NO_SIGN);
wire is_nan_b      = (no_sign_b  > FP16_INFINITY_NO_SIGN);
wire is_denormal_a = (exp_a == 5'h0);
wire is_denormal_b = (exp_b == 5'h0);

reg [4:0]            exp_diff;
reg [(1+1+10)-1:0]   mantissa_extended_a;
reg [(1+1+10)-1:0]   mantissa_extended_b;

reg [15:0]           res_f0;
reg [(1+1+1+10)-1:0] mantissa_extended_sum_f0;
reg [(1+5)-1:0]      exp_result_f0;
reg                  sign_result_f0;
reg                  is_res_special_f0;

always @( * ) begin
    mantissa_extended_a = 0;
    mantissa_extended_b = 0;
    exp_diff = 0;
    mantissa_extended_sum_f0 = 0;
    exp_result_f0 = 0;
    sign_result_f0 = 0;
    is_res_special_f0 = 0;
    res_f0 = 0;

    if ( is_nan_a || is_nan_b ) begin
        res_f0 = FP16_NAN;
        is_res_special_f0 = 1;
    end else if ( is_inf_a && is_inf_b && sign_a != sign_b ) begin
        res_f0 = FP16_NAN;
        is_res_special_f0 = 1;
    end else if ( is_inf_a ) begin 
        res_f0 = {sign_a, FP16_INFINITY_NO_SIGN};
        is_res_special_f0 = 1;
    end else if ( is_inf_b ) begin
        res_f0 = {sign_b, FP16_INFINITY_NO_SIGN};
        is_res_special_f0 = 1;
    end else if ( is_denormal_a && is_denormal_b ) begin
        // DAZ
        res_f0 = {sign_a & sign_b, 15'h0};
        is_res_special_f0 = 1;
    end else begin
        is_res_special_f0 = 0;

        mantissa_extended_a = {1'b1, mantissa_a, 1'b0};
        mantissa_extended_b = {1'b1, mantissa_b, 1'b0};

        if ( exp_a >= exp_b ) begin
            exp_result_f0 = exp_a;
            exp_diff = exp_a - exp_b;
            mantissa_extended_b = mantissa_extended_b >> exp_diff;
        end else begin
            exp_result_f0 = exp_b;
            exp_diff = exp_b - exp_a;
            mantissa_extended_a = mantissa_extended_a >> exp_diff;
        end

        if ( sign_a == sign_b ) begin
            mantissa_extended_sum_f0 = mantissa_extended_a + mantissa_extended_b;
            sign_result_f0 = sign_a;
        end else if ( mantissa_extended_a >= mantissa_extended_b ) begin
            mantissa_extended_sum_f0 = mantissa_extended_a - mantissa_extended_b;
            sign_result_f0 = sign_a;
        end else begin
            mantissa_extended_sum_f0 = mantissa_extended_b - mantissa_extended_a;
            sign_result_f0 = sign_b;
        end
    end
end


// Stage F1
reg [15:0]           res_buf;
reg [(1+1+1+10)-1:0] mantissa_extended_sum_buf;
reg [(1+5)-1:0]      exp_result_buf;
reg                  sign_result_buf;
reg                  is_res_special_buf;
reg                  rmode_buf;

always @( posedge clk ) begin
    res_buf <= res_f0;
    mantissa_extended_sum_buf <= mantissa_extended_sum_f0;
    exp_result_buf <= exp_result_f0;
    sign_result_buf <= sign_result_f0;
    is_res_special_buf <= is_res_special_f0;
    rmode_buf <= i_rmode;
end

reg [5:0]            bit_counter;
reg [15:0]           res_f1;
reg [(1+1+1+10)-1:0] mantissa_extended_sum_f1;
reg [(1+5)-1:0]      exp_result_f1;
reg                  sign_result_f1;
reg                  is_res_special_f1;
reg                  rmode_f1;

always @( * ) begin
    res_f1 = res_buf;
    mantissa_extended_sum_f1 = mantissa_extended_sum_buf;
    exp_result_f1 = exp_result_buf;
    sign_result_f1 = sign_result_buf;
    is_res_special_f1 = is_res_special_buf;
    rmode_f1 = rmode_buf;
    bit_counter = 0;

    if ( is_res_special_f1 )
        o_res = res_f1;
    else begin
        // Normalize
        if ( mantissa_extended_sum_f1[12] ) begin
            mantissa_extended_sum_f1 = mantissa_extended_sum_f1 >> 1;
            exp_result_f1 = exp_result_f1 + 1;
        end else begin
            casex ( mantissa_extended_sum_f1[11:0] )
                12'b1???????????: bit_counter = 0;
                12'b01??????????: bit_counter = 1;
                12'b001?????????: bit_counter = 2;
                12'b0001????????: bit_counter = 3;
                12'b00001???????: bit_counter = 4;
                12'b000001??????: bit_counter = 5;
                12'b0000001?????: bit_counter = 6;
                12'b00000001????: bit_counter = 7;
                12'b000000001???: bit_counter = 8;
                12'b0000000001??: bit_counter = 9;
                12'b00000000001?: bit_counter = 10;
                12'b000000000001: bit_counter = 11;
                default: bit_counter = exp_result_f1;
            endcase
            
            mantissa_extended_sum_f1 = mantissa_extended_sum_f1 << bit_counter;
            exp_result_f1 = exp_result_f1 >= bit_counter ? exp_result_f1 - bit_counter : 0;
        end

        // Rounding
        if ( rmode_f1 ) begin // roundTiesToEven
            // TODO: implement it.
        end else begin // roundTowardZero
            // Do nothing.
        end

        // FTZ
        if ( exp_result_f1 == 0 )
            mantissa_extended_sum_f1 = 0;

        if ( exp_result_f1 >= 31 ) begin
            o_res = {sign_result_f1, FP16_INFINITY_NO_SIGN};
        end else begin
            o_res = {sign_result_f1, exp_result_f1[4:0], mantissa_extended_sum_f1[10:1]};
        end
    end
end

endmodule
