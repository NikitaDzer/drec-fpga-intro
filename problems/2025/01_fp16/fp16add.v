`include "fp16const.vh"

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
module fp16add (
    input wire [15:0] i_a,
    input wire [15:0] i_b,
    input wire        i_rmode,

    output reg [15:0] o_res
);

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

reg sign_result;

reg [(1+5)-1:0] exp_result;
reg [4:0]       exp_diff;

reg [(1+10+31)-1:0]   mantissa_extended_a;
reg [(1+10+31)-1:0]   mantissa_extended_b;
reg [(1+1+10+31)-1:0] mantissa_extended_sum;
reg [5:0]             mantissa_pos;

always @( * ) begin
    if ( is_nan_a || is_nan_b ) begin
        o_res = FP16_NAN;
    end else if ( is_inf_a && is_inf_b && sign_a != sign_b ) begin
        o_res = FP16_NAN;
    end else if ( is_inf_a ) begin 
        o_res = {sign_a, FP16_INFINITY_NO_SIGN};
    end else if ( is_inf_b ) begin
        o_res = {sign_b, FP16_INFINITY_NO_SIGN};
    end else if ( is_denormal_a && is_denormal_b ) begin
        // DAZ
        o_res = {sign_a & sign_b, 15'h0};
    end else begin
        mantissa_extended_a = {1'b1, mantissa_a, 31'b0};
        mantissa_extended_b = {1'b1, mantissa_b, 31'b0};

        if ( exp_a >= exp_b ) begin
            exp_result = exp_a;
            exp_diff = exp_a - exp_b;
            mantissa_extended_b = mantissa_extended_b >> exp_diff;
        end else begin
            exp_result = exp_b;
            exp_diff = exp_b - exp_a;
            mantissa_extended_a = mantissa_extended_a >> exp_diff;
        end

        if ( sign_a == sign_b ) begin
            mantissa_extended_sum = mantissa_extended_a + mantissa_extended_b;
            sign_result = sign_a;
        end else if ( mantissa_extended_a >= mantissa_extended_b ) begin
            mantissa_extended_sum = mantissa_extended_a - mantissa_extended_b;
            sign_result = sign_a;
        end else begin
            mantissa_extended_sum = mantissa_extended_b - mantissa_extended_a;
            sign_result = sign_b;
        end

        // Normalize
        if ( mantissa_extended_sum[42] ) begin
            mantissa_extended_sum = mantissa_extended_sum >> 1;
            exp_result = exp_result + 1;
        end else begin
            while ( !mantissa_extended_sum[41] && exp_result > 0 ) begin
                mantissa_extended_sum = mantissa_extended_sum << 1;
                exp_result = exp_result - 1;
            end
        end

        // Rounding
        if ( i_rmode ) begin // roundTiesToEven
            // TODO: implement it.
        end else begin // roundTowardZero
            // Do nothing.
        end

        // FTZ
        if ( exp_result == 0)
            mantissa_extended_sum = 0;

        if ( exp_result >= 31 ) begin
            o_res = {sign_result, FP16_INFINITY_NO_SIGN};
        end else begin
            o_res = {sign_result, exp_result[4:0], mantissa_extended_sum[40:31]};
        end
    end
end

endmodule
