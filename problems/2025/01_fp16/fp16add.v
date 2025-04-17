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

reg [(1+1+10)-1:0]   mantissa_extended_a;
reg [(1+1+10)-1:0]   mantissa_extended_b;
reg [(1+1+1+10)-1:0] mantissa_extended_sum;
reg [(1+5)-1:0]      bit_counter;

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
        mantissa_extended_a = {1'b1, mantissa_a, 1'b0};
        mantissa_extended_b = {1'b1, mantissa_b, 1'b0};

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
        if ( mantissa_extended_sum[12] ) begin
            mantissa_extended_sum = mantissa_extended_sum >> 1;
            exp_result = exp_result + 1;
        end else begin
            casex ( mantissa_extended_sum[11:0] )
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
                default: bit_counter = exp_result;
            endcase
            
            mantissa_extended_sum = mantissa_extended_sum << bit_counter;
            exp_result = exp_result >= bit_counter ? exp_result - bit_counter : 0;
        end

        // Rounding
        if ( i_rmode ) begin // roundTiesToEven
            // TODO: implement it.
        end else begin // roundTowardZero
            // Do nothing.
        end

        // FTZ
        if ( exp_result == 0 )
            mantissa_extended_sum = 0;

        if ( exp_result >= 31 ) begin
            o_res = {sign_result, FP16_INFINITY_NO_SIGN};
        end else begin
            o_res = {sign_result, exp_result[4:0], mantissa_extended_sum[10:1]};
        end
    end
end

endmodule
