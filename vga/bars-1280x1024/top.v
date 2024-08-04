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

    wire clk108;
    wire vga_vid;
    wire vga_hsync;
    wire vga_vsync;
    wire [$clog2(1688)-1:0] vga_col;     // big enough to hold the counter value
    wire [$clog2(1066)-1:0] vga_row;     // big enough to hold the counter value

    // use a PLL to generate 65MHZ from 25MHZ
    pll pll108 (.clock_in(clk25), .clock_out(clk108));

    vgasync #(
        .HVID(1280),
        .HFP(48),
        .HS(112),
        .HBP(248),
        .VVID(1024),
        .VFP(1),
        .VS(3),
        .VBP(38)
    ) vga (
        .clk(clk108),
        .reset(~s1_n),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .col(vga_col),
        .row(vga_row),
        .vid_active(vga_vid)
    );


    // Note: Because the following logic is combinational, the way 
    // that the compiler choses to implement it can cause glitches 
    // and/or hesitations when the colors transition.


    // draw different patterns depending on the row
    assign {red,grn,blu} = vga_vid ? (( vga_row > 300) ? vga_col[8:6] : ( vga_row > 290) ? 0 : ( vga_row > 200) ? vga_col[5:3] : ( vga_row > 190) ? 0 : vga_col[2:0] ) : 0;

    // draw same pattern on every row
//    assign {red,grn,blu} = vga_vid ? vga_col[8:6] : 0;

    // draw full screen white
//    assign {red,grn,blu} = vga_vid ? {3{vga_vid}} : 0;    // all three on at same time

    assign hsync = ~vga_hsync;
    assign vsync = vga_vsync;       // the sync pulse is positive for VESA Signal 720 x 400 @ 85Hz 

endmodule
