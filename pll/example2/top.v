`default_nettype none

module top (
    input   wire        clk25,
    input   wire        s1_n,
    input   wire        s2_n,
    output  wire        reset_n,
    output  wire        clk1,
    output  wire        clk2,
    output  wire [7:0]  led
    );

    // use one PLL to generate 65MHZ from 25MHZ
    pll_25_65 pll65 (.clock_in(clk25), .clock_out(clk1));

    // use a second PLL to generate 18.432MHZ from 25MHZ
    pll_25_18432 pll_18432 (.clock_in(clk25), .clock_out(clk2));

    // this is not related but can be useful to prevent an unused
    // 2067-Z8S180 (Nouveau) board from trying to wake up if one
    // happens to be connected when running this test.
    assign reset_n = 0;

endmodule
