`default_nettype none


/**
* Generate color & sync values using a pipeline.
***************************************************************************/
module vdp_table_test (
    input wire          pxclk,          // 65MHZ clock
    input wire          reset,
    input wire          hsync_in,
    input wire          vsync_in,
    input wire [8:0]    col_in,         // pixel column
    input wire [9:0]    row_in,         // pixel row
    input wire          active_in,      // true when video is active

    output wire         hsync_out,
    output wire         vsync_out,
    output wire         active_out,
    output wire         red,
    output wire         grn,
    output wire         blu,

    output wire [9:0]   name_raddr,         // 1K
    input wire [7:0]    name_rdata,

    output wire [10:0]  pattern_raddr,      // 2K
    input wire [7:0]    pattern_rdata,

    output wire [4:0]   color_raddr,        // 32 bytes
    input wire [7:0]    color_rdata
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

    // tile name table address: RRRRRCCCCC
    assign name_raddr = {RRRRR, CCCCC};

    // tile px col: ccc
    // tile px row: rrr

    // pattern table (2K)
    assign pattern_raddr = {name_rdata, rrr};

    // color table  (32 bytes)
    assign color_raddr = name_rdata[7:3];
    //assign color_raddr = name_rdata[4:0];
    //assign color_raddr = CCCCC;

    reg [4:0] hsync_reg, hsync_next;
    reg [4:0] vsync_reg, vsync_next;
    reg [4:0] active_reg, active_next;
    reg [2:0] color_reg, color_next;
    reg [7:0] px_reg, px_next;

    always @(posedge pxclk) begin
        if (reset) begin
            color_reg <= 0;
            px_reg <= 0;
            active_reg <= 0;
            hsync_reg <= 0;
            vsync_reg <= 0;
        end else begin
            color_reg <= color_next;
            px_reg <= px_next;
            active_reg <= active_next;
            hsync_reg <= hsync_next;
            vsync_reg <= vsync_next;
        end
    end

    always @(*) begin
        color_next = 0;             // assume black

        // advance the pipeline (shifting left)
        active_next = {active_reg, active_in};  // shift left
        hsync_next = {hsync_reg, hsync_in};     // shift left
        vsync_next = {vsync_reg, vsync_in};     // shift left
        px_next = {px_reg, 1'b0};               // shift left

        if ( ccc == 3 ) begin
            px_next = pattern_rdata;            // only load px shift reg on 3rd tile clock
//XXX need to latch the tile-color here too?
        end
        if ( active_reg[3] ) begin              // if visible on next clk
            color_next = px_reg[7] ? color_rdata[6:4] : color_rdata[2:0];   // use 3 lsbs for now
/*
            // override to see hardcode in case above is garbage
            if ( CCCCC == RRRRR ) begin
                color_next = ccc + rrr;
            end
*/
        end
    end

    assign hsync_out = hsync_reg[4];
    assign vsync_out = vsync_reg[4];
    assign active_out = active_reg[4];

    assign {red,grn,blu} = color_reg;

endmodule
