`default_nettype none

module top (
    input   wire        clk25,
    input   wire        s1_n,
    input   wire        s2_n,
    output  wire        red,
    output  wire        grn,
    output  wire        blu,
    output  wire        hsync,
    output  wire        vsync,
    output  wire [7:0]  led
    );

    wire vga_vid;
    wire vga_hsync;
    wire vga_vsync;

    vgasync vga (
        .clk(clk25),
        .reset(~s1_n),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .vid_active(vga_vid)
        );

    assign red = vga_vid;
    assign grn = vga_vid;
    assign blu = vga_vid;
    assign hsync = ~vga_hsync;
    assign vsync = ~vga_vsync;

endmodule
