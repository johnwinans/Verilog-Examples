`default_nettype none

module top (
    input   wire        clk25,
    input   wire        s1_n,
    input   wire        s2_n,
    output  wire        clk1,
    output  wire        clk2,
    output  wire [7:0]  led
    );

    localparam COUNTER_WIDTH = 26;

    wire [COUNTER_WIDTH-1:0] c1_out;
    wire [COUNTER_WIDTH-1:0] c2_out;

    // use one PLL to generate 65MHZ from 25MHZ
    pll_25_65 pll65 (.clock_in(clk25), .clock_out(clk1));

    // use a second PLL to generate 18.432MHZ from 25MHZ
    pll_25_18432 pll_18432 (.clock_in(clk25), .clock_out(clk2));

    // divide clk1 down to human scale so can see it on an LED
    counter #( .WIDTH(COUNTER_WIDTH) ) c1 (
        .clk(clk1),
        .reset(~s1_n),
        .out(c1_out)
        );

    // divide clk2 down to human scale so can see it on an LED
    counter #( .WIDTH(COUNTER_WIDTH) ) c2 (
        .clk(clk2),
        .reset(~s1_n),
        .out(c2_out)
        );

    assign led[0] = c2_out[COUNTER_WIDTH-1];
    assign led[1] = c1_out[COUNTER_WIDTH-1];

    assign led[7:2] = ~0;       // turn off the rest of the LEDs

endmodule
