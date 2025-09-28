// rms_meter.v : approximate running RMS via IIR on |x| and |x|^2 (Q1.15 in/out)
module rms_meter #(
    parameter integer ALPHA_SHIFT = 12 // alpha = 1/2^12 ~ 0.000244
)(
    input  wire               clk,
    input  wire               rst,
    input  wire signed [15:0] x_in,     // Q1.15
    output reg  [15:0]        rms_out   // unsigned Q1.15 (approx sqrt)
);
    // We estimate power with IIR: P = (1-alpha)*P + alpha*x^2
    // Then sqrt via rough Newton step or LUT; here use piecewise via shift (cheap approx).

    reg [31:0] pwr; // Q2.30
    wire [31:0] xin2 = $signed(x_in) * $signed(x_in); // Q2.30

    always @(posedge clk) begin
        if (rst) begin
            pwr <= 0;
            rms_out <= 0;
        end else begin
            // pwr += alpha*(xin2 - pwr)
            pwr <= pwr + ((xin2 - pwr) >>> ALPHA_SHIFT);

            // crude sqrt: take top bits as magnitude approx
            // pwr is Q2.30, so rms ~ sqrt(pwr) ~ Q1.15 -> take bits [29:15] as rough sqrt
            rms_out <= pwr[29:14]; // cheap magnitude proxy; good enough for gating threshold
        end
    end
endmodule