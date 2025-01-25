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
    wire [9:0] vga_col;     // up to 639
    wire [8:0] vga_row;     // up to 479

    vgasync vga (
        .clk(clk25),
        .reset(~s1_n),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .col(vga_col),
        .row(vga_row),
        .vid_active(vga_vid)
        );

    // draw different patterns depending on the row
//    assign {red,grn,blu} = vga_vid ? (( vga_row > 300) ? vga_col[8:6] : ( vga_row > 290) ? 0 : ( vga_row > 200) ? vga_col[5:3] : ( vga_row > 190) ? 0 : vga_col[2:0] ) : 0;

    // draw same pattern on every row
    assign {red,grn,blu} = vga_vid ? vga_col[8:6] : 0;

    // draw full screen white
//    assign {red,grn,blu} = vga_vid ? {3{vga_vid}} : 0;    // all three on at same time

//    assign red = vga_vid;
//    assign grn = vga_vid;
//    assign blu = vga_vid;

    assign hsync = ~vga_hsync;
    assign vsync = ~vga_vsync;

endmodule
