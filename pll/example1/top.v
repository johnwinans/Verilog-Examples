`default_nettype none

module top (
    input wire clk25,
    input wire reset_n,
    output wire [7:0] led
    );

    localparam COUNTER_WIDTH = 30;

    wire [COUNTER_WIDTH-1:0] ctr;
    wire pll_out;

    pll_25_100 upll( .clock_in(clk25), .global_clock(pll_out) );

    counter #( .WIDTH(COUNTER_WIDTH) ) c ( .clk(pll_out), .reset(~reset_n), .out(ctr) );

    assign led = ~ctr[COUNTER_WIDTH-1:COUNTER_WIDTH-8];     // LEDs are active-low

endmodule
