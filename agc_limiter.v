// agc_limiter.v
module agc_limiter #(
    parameter integer ATTACK_SHIFT = 9,   // faster (alpha_attack = 1/512)
    parameter integer RELEASE_SHIFT = 13, // slower  (alpha_release = 1/8192)
    parameter integer TARGET_Q15    = 16'd29000, // ~0.885 (-1 dBFS)
    parameter integer MAX_GAIN_Q15  = 16'd32767, // cap
    parameter integer MIN_GAIN_Q15  = 16'd8192   // -12 dB min
)(
    input  wire               clk,
    input  wire               rst,
    input  wire signed [15:0] x_in,   // Q1.15 (post-gate)
    output reg  signed [15:0] x_out   // Q1.15
);

    // Envelope detector
    reg [15:0] env; // Q1.15 peak envelope
    wire [15:0] absx = x_in[15] ? (~x_in + 1'b1) : x_in;

    // Gain calculation
    reg [31:0] g;             // raw gain Q1.15
    reg [15:0] env_safe;
    reg [15:0] g_clamped;
    reg signed [31:0] mult;
    reg signed [31:0] y;

    always @(posedge clk) begin
        if (rst) begin
            env   <= 0;
            x_out <= 0;
        end else begin
            // Attack / Release smoothing
            if (absx > env)
                env <= env + ((absx - env) >>> ATTACK_SHIFT);
            else
                env <= env - (env >>> RELEASE_SHIFT);

            // avoid div by ~0
            env_safe = (env < 16'd64) ? 16'd64 : env;

            // gain = TARGET / env_safe
            g = ( (TARGET_Q15 << 15) / env_safe ); // Q1.15

            // clamp
            if (g[15:0] > MAX_GAIN_Q15)
                g_clamped = MAX_GAIN_Q15;
            else if (g[15:0] < MIN_GAIN_Q15)
                g_clamped = MIN_GAIN_Q15;
            else
                g_clamped = g[15:0];

            // apply gain
            mult = $signed(x_in) * $signed({1'b0, g_clamped}); // Q2.30
            y    = (mult + 32'sd16384) >>> 15; // back to Q1.15 with rounding

            // hard limiter to 16-bit
            if (y > 32'sd32767)
                x_out <= 16'sd32767;
            else if (y < -32'sd32768)
                x_out <= -16'sd32768;
            else
                x_out <= y[15:0];
        end
    end
endmodule