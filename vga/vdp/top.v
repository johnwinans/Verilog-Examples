`default_nettype none

module top (
    input   wire        hwclk,
    input   wire        s1_n,
    input   wire        s2_n,
    output  wire        red,
    output  wire        grn,
    output  wire        blu,
    output  wire        hsync,
    output  wire        vsync,
    output  wire [7:0]  led
    );

    wire clk65;
    wire vga_vid;
    wire vga_hsync, vdp_hsync;
    wire vga_vsync, vdp_vsync;
    wire [$clog2(1344)-1:0] vga_col;    // big enough to hold the counter value
    wire [$clog2(806)-1:0] vga_row;     // big enough to hold the counter value

    // use a PLL to generate 65MHZ from 25MHZ
    pll pll65 (.clock_in(hwclk), .clock_out(clk65));

    // NOTE:    We could run the sync circuit at 1/4 of the 65MHZ clock speed
    //          as long as all of the horizontal times can be evenly divided
    //          by 4.  THis is because we ultimately ignore the two LSBs of
    //          the col output in the entire design.
    vgasync #(
        .HVID(1024/4),
        .HFP(24/4),
        .HS(136/4),
        .HBP(160/4),
        .VVID(768),
        .VFP(3),
        .VS(6),
        .VBP(29)
    ) vga (
        .clk(clk65),
        .reset(~s1_n),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .col(vga_col),
        .row(vga_row),
        .vid_active(vga_vid)
    );

`ifdef TIMING_TEST
    vdp_timing_test vdp (
        .pxclk(clk65),
        .reset(~s1_n),
        .hsync_in(vga_hsync),
        .vsync_in(vga_vsync),
        .col_in(vga_col),
        .row_in(vga_row),
        .active_in(vga_vid),
        .hsync_out(vdp_hsync),
        .vsync_out(vdp_vsync),
        .red(red),
        .grn(grn),
        .blu(blu),
    );
`else

    wire [9:0]  name_raddr;
    wire [7:0]  name_rdata;
    wire [10:0] pattern_raddr;
    wire [7:0]  pattern_rdata;
    wire [4:0]  color_raddr;
    wire [7:0]  color_rdata;

    //memory #( .SIZE(1024), .IMAGE("rom_name.hex") ) name_mem ( .rd_clk(clk65), .addr(name_raddr), .data(name_rdata) );      // 1024
    //memory #( .SIZE(2048), .IMAGE("rom.hex") ) pattern_mem ( .rd_clk(clk65), .addr(pattern_raddr), .data(pattern_rdata) );  // 2048
    //memory #( .SIZE(512) , .IMAGE("rom.hex") ) color_mem ( .rd_clk(clk65), .addr(color_raddr), .data(color_rdata) );        // 512

	reg [7:0] name_mem [0:767];
	reg [7:0] pattern_mem [0:2047];
	reg [7:0] color_mem [0:31];

	initial begin
		$readmemh("rom_name.hex", name_mem);
		$readmemh("rom_pattern.hex", pattern_mem);
		$readmemh("rom_color.hex", color_mem);
	end
	always @(posedge clk65) begin
		name_rdata      <= name_mem[name_raddr];
		pattern_rdata   <= pattern_mem[pattern_raddr];
		color_rdata     <= color_mem[color_raddr];
	end

    vdp_table_test vdp (
        .pxclk(clk65),
        .reset(~s1_n),
        .hsync_in(vga_hsync),
        .vsync_in(vga_vsync),
        .col_in(vga_col),
        .row_in(vga_row),
        .active_in(vga_vid),
        .hsync_out(vdp_hsync),
        .vsync_out(vdp_vsync),
        .red(red),
        .grn(grn),
        .blu(blu),
        .name_raddr(name_raddr),
        .name_rdata(name_rdata),
        .pattern_raddr(pattern_raddr),
        .pattern_rdata(pattern_rdata),
        .color_raddr(color_raddr),
        .color_rdata(color_rdata),
    );

`endif

    assign hsync = ~vdp_hsync;      // Polarity of horizontal sync pulse is negative.
    assign vsync = ~vdp_vsync;      // Polarity of vertical sync pulse is negative.

    assign led = ~0;                // turn off the LEDs

endmodule
