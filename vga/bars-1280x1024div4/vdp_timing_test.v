/**
* Generate color & sync values using a pipeline.
***************************************************************************/
module vdp_timing_test (
    input wire          pxclk,          // 65MHZ clock
    input wire          reset,
    input wire          hsync_in,
    input wire          vsync_in,
    input wire [10:0]   col_in,         // pixel column
    input wire [9:0]    row_in,         // pixel row
    input wire          active_in,      // true when video is active

    output wire         hsync_out,
    output wire         vsync_out,
    output wire         active_out,
    output wire         red,
    output wire         grn,
    output wire         blu
    );

    wire [4:0] CCCCC;       // the tile column (in the "pattern plane")
    wire [2:0] ccc;         // the character column
    wire [1:0] mm;
    wire [4:0] RRRRR;       // the tile row (in the "pattern plane")
    wire [2:0] rrr;         // the character row
    wire [1:0] nn;

    // horiz counter
    //assign {CCCCC, ccc, mm} = col_in[9:0];
    assign {CCCCC, ccc} = col_in[7:0];

    // vert counter
    assign {RRRRR, rrr, nn} = row_in[9:0];
    //assign {RRRRR, rrr} = row_in[7:0];

    // tile name table address: RRRRRCCCCC
    // tile px col: ccc
    // tile px row: rrr

    // nametable (1K)

    // pattern table (2K)
    // @: { name[RRRRRCCCCC], rrr}

    // color table  (32 bytes)
    // Q: name[RRRRRCCCCC][7:2]

    // video character row shifter loads for each ccc==0
    // pattern[{name[RRRRRCCCCC], rrr}]

    reg hsync_reg, hsync_next;
    reg vsync_reg, vsync_next;
    reg [2:0] color_reg, color_next;
    reg active_reg, active_next;

    always @(posedge pxclk) begin
        if (reset) begin
            color_reg <= 0;
            active_reg <= 0;
            hsync_reg <= 0;
            vsync_reg <= 0;
        end else begin
            color_reg <= color_next;
            active_reg <= active_next;
            hsync_reg <= hsync_next;
            vsync_reg <= vsync_next;
        end
    end

    always @(*) begin
        color_next = 0;
        active_next = active_in;
        hsync_next = hsync_in;
        vsync_next = vsync_in;

        if ( active_next ) begin
            color_next = CCCCC[2:0];
            if ( CCCCC == RRRRR ) begin
                color_next = ccc + rrr;
            end
        end
    end

    assign hsync_out = hsync_reg;
    assign vsync_out = vsync_reg;
    assign active_out = active_reg;

    assign {red,grn,blu} = color_reg;

endmodule
