// tb_birdsong_chain.v
`timescale 1ns/1ps
module tb_birdsong_chain;
    parameter integer SAMPLE_COUNT = 144000;
    parameter integer N_TAPS = 65;

    reg clk, rst;
    reg  signed [15:0] x;
    wire signed [15:0] y;

    reg [15:0]  mem_in  [0:SAMPLE_COUNT-1];
    reg signed [15:0]  mem_out [0:SAMPLE_COUNT-1];

    integer i, fh;

    birdsong_chain #(.N_TAPS(N_TAPS)) dut (
        .clk(clk), .rst(rst), .x_in(x), .y_out(y)
    );

    // 100 MHz
    initial begin clk = 0; forever #5 clk = ~clk; end

    initial begin
        rst = 1; x = 0;
        repeat (10) @(posedge clk);
        rst = 0;

        $readmemh("birdsong.hex", mem_in);

        // feed samples, capture output
        for (i = 0; i < SAMPLE_COUNT; i = i + 1) begin
            x = $signed(mem_in[i]);
            @(posedge clk);
            mem_out[i] = y;
        end

        // write output
        fh = $fopen("output.hex","w");
        if (fh == 0) begin $display("Cannot open output.hex"); $stop; end
        for (i = 0; i < SAMPLE_COUNT; i = i + 1)
            $fwrite(fh, "%04X\n", mem_out[i][15:0]);
        $fclose(fh);
        $display("? output.hex written");
        $stop;
    end
endmodule