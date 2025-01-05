`default_nettype none

module top (
    input wire clk25,
    input wire reset_n,
    output wire [7:0] led
    );

    wire clk100;

    localparam CLOCK_HZ = 100000000;
    pll_25_100 upll(.clock_in(clk25), .global_clock(clk100));

    counter c (
        .clk(clk100),
        .reset(~reset_n),
        .out(led)
        );

endmodule
