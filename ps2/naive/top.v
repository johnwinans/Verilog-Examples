`default_nettype none

module top (
    input   wire        clk25,
    input   wire        s1_n,
    input   wire        s2_n,
    input   wire        kbclk,
    input   wire        kbdata,
    output  wire [7:0]  led
    );

    wire [7:0] data;

    ps2 kbd (
        .reset(~s1_n),
        .ps2_data(kbdata),
        .ps2_clk(kbclk),
        .rx_data(data)       // note the MSB is pruned
        );

        assign led = ~data;

endmodule
