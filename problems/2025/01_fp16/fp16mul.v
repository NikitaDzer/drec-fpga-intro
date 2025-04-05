`include "fp16const.vh"

/**
 * FP16 multiplier unit.
 *
 * i_a - first FP16 number
 * i_b - second FP16 number
 * i_rmode - rounding mode:
 *   0 - roundTowardZero,
 *   1 - roundTiesToEven
 *
 * o_res - multiplication result
 *
 */
module fp16mul (
    input wire [15:0] i_a,
    input wire [15:0] i_b,
    input wire        i_rmode,

    output reg [15:0] o_res
);

wire        sign_a     = i_a[15];
wire        sign_b     = i_b[15];
wire  [4:0] exp_a      = i_a[14:10];
wire  [4:0] exp_b      = i_b[14:10];
wire [10:0] mantissa_a = {1'b1, i_a[9:0]};
wire [10:0] mantissa_b = {1'b1, i_b[9:0]};

wire [14:0] no_sign_a  = i_a[14:0];
wire [14:0] no_sign_b  = i_b[14:0];

wire is_inf_a      = (no_sign_a == FP16_INFINITY_NO_SIGN);
wire is_inf_b      = (no_sign_b == FP16_INFINITY_NO_SIGN); 
wire is_nan_a      = (no_sign_a  > FP16_INFINITY_NO_SIGN);
wire is_nan_b      = (no_sign_b  > FP16_INFINITY_NO_SIGN);
wire is_denormal_a = (exp_a == 5'h0);
wire is_denormal_b = (exp_b == 5'h0);

reg [21:0] mantissa_product;
reg  [5:0] exp_result;

reg [10:0] mantissa_normalized;
reg  [5:0] exp_final;

wire is_denormal_res = (exp_final == 6'h0);
wire sign_res        = sign_a ^ sign_b;

always @( * ) begin
    if ( is_nan_a || is_nan_b ) begin
        // NAN propogation
        o_res = FP16_NAN;
    end
    else if ( is_denormal_a || is_denormal_b )
        // DAZ
        o_res = 0;
    else if ( is_inf_a || is_inf_b ) begin
        // INF propogation
        o_res = {sign_res, FP16_INFINITY_NO_SIGN};
    end else begin
        // Mantissa multiplication
        mantissa_product = mantissa_a * mantissa_b;

        // Exponent addition
        exp_result = exp_a + exp_b - FP16_BIAS;

        // Mantissa normalization
        if ( mantissa_product[21] ) begin
            // Mantissa from [1, 4) to [1, 2)
            mantissa_normalized = mantissa_product[21:11];
            exp_final = exp_result + 1;
        end else begin
            mantissa_normalized = mantissa_product[20:10];
            exp_final = exp_result;
        end

        // Rounding
        if ( i_rmode ) begin // roundTiesToEven
            // TODO: implement it.
        end else begin // roundTowardZero
            // Do nothing.
        end

        // FTZ
        if ( is_denormal_res )
            mantissa_normalized = 0;

        if ( exp_final >= 31 ) begin
            // Overflow handling
            o_res = {sign_res, FP16_INFINITY_NO_SIGN};
        end else
            o_res = {sign_res, exp_final[4:0], mantissa_normalized[9:0]};
    end
end

endmodule
