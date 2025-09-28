// birdsong_chain.v
module birdsong_chain #(
    parameter integer N_TAPS = 65
)(
    input  wire               clk,
    input  wire               rst,
    input  wire signed [15:0] x_in,     // Q1.15
    output wire signed [15:0] y_out     // Q1.15 loud, band-passed
);
    wire signed [15:0] y_fir;
    wire        [15:0] y_rms;
    wire signed [15:0] y_gated;

    fir_filter #(.N(N_TAPS)) u_fir (
        .clk(clk), .rst(rst), .x_in(x_in), .y_out(y_fir)
    );

    rms_meter u_rms (.clk(clk), .rst(rst), .x_in(y_fir), .rms_out(y_rms));

    // Tune THRESH_Q15 after measuring your noise-only RMS (see notes below)
    noise_gate #(.THRESH_Q15(16'd1200), .SOFT_KNEE_RANGE(16'd2000), .FLOOR_GAIN_Q15(16'd0)) u_gate (
        .clk(clk), .rst(rst), .x_in(y_fir), .rms_in(y_rms), .x_out(y_gated)
    );

    agc_limiter u_agc (
        .clk(clk), .rst(rst), .x_in(y_gated), .x_out(y_out)
    );
endmodule