// fir_filter.v
`timescale 1ns/1ps
module fir_filter #(
    parameter integer N = 65 // 65 taps for order 64
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire signed [15:0]    x_in,    // Q1.15
    output reg  signed [15:0]    y_out    // Q1.15
);
    // Coefficients from coeffs.hex
    reg signed [15:0] coeff [0:N-1];      // Q1.15
    reg signed [15:0] shift_reg [0:N-1];  // Q1.15

    // Accumulators
    reg signed [47:0] acc;                // MAC accumulator
    reg signed [31:0] acc_s;              // scaled/saturated value

    integer i;

    // Load coefficients from file (simulation only)
    initial $readmemh("coeffs.hex", coeff);

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < N; i = i + 1)
                shift_reg[i] <= 16'sd0;
            y_out <= 16'sd0;
            acc   <= 48'sd0;
            acc_s <= 32'sd0;
        end else begin
            // Shift register for input samples
            for (i = N-1; i > 0; i = i - 1)
                shift_reg[i] <= shift_reg[i-1];
            shift_reg[0] <= x_in;

            // Multiply-Accumulate
            acc = 48'sd0;
            for (i = 0; i < N; i = i + 1)
                acc = acc + $signed(shift_reg[i]) * $signed(coeff[i]); // Q2.30

            // Rounding before shifting back to Q1.15
            acc = acc + 48'sd16384; // add 0.5 LSB

            // Scale back from Q2.30 ? Q1.15
            acc_s = acc >>> 15;

            // Saturation
            if (acc_s > 32'sd32767)
                y_out <= 16'sd32767;
            else if (acc_s < -32'sd32768)
                y_out <= -16'sd32768;
            else
                y_out <= acc_s[15:0];
        end
    end
endmodule