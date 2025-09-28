module noise_gate #(
    parameter integer THRESH_Q15      = 16'd1000, // ~0.03
    parameter integer SOFT_KNEE_RANGE = 16'd2000, // knee width
    parameter integer FLOOR_GAIN_Q15  = 16'd0     // 0 -> hard gate; or e.g. 3277 (~-20 dB) for soft gate
)(
    input  wire               clk,
    input  wire               rst,
    input  wire signed [15:0] x_in,     // Q1.15
    input  wire        [15:0] rms_in,   // Q1.15 (unsigned)
    output reg  signed [15:0] x_out     // Q1.15
);

    // Gain = 0 below threshold; ramp to 1 across soft knee
    reg [15:0] gain;

    // temporary registers (declared outside procedural blocks)
    reg [31:0] num, div, g32;
    reg signed [31:0] mult, y;

    always @(posedge clk) begin
        if (rst) begin
            x_out <= 16'sd0;
            gain  <= 16'd0;
        end else begin
            if (rms_in <= THRESH_Q15) begin
                gain <= FLOOR_GAIN_Q15; // hard/soft floor
            end else if (rms_in >= (THRESH_Q15 + SOFT_KNEE_RANGE)) begin
                gain <= 16'd32767; // unity
            end else begin
                // linear ramp across knee
                num = (rms_in - THRESH_Q15) * (16'd32767 - FLOOR_GAIN_Q15);
                div = num / SOFT_KNEE_RANGE;
                g32 = FLOOR_GAIN_Q15 + div[15:0];
                gain <= g32[15:0];
            end

            // apply gain: Q1.15 * Q1.15 -> Q2.30 -> back to Q1.15
            mult = $signed(x_in) * $signed({1'b0, gain});
            y = (mult + 32'sd16384) >>> 15; // round
            if (y > 32'sd32767)       x_out <= 16'sd32767;
            else if (y < -32'sd32768) x_out <= -16'sd32768;
            else                      x_out <= y[15:0];
        end
    end
endmodule