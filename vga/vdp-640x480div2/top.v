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

    wire pxclk;
    wire vga_vid;
    wire vga_bdr;
    wire vga_hsync, vdp_hsync;
    wire vga_vsync, vdp_vsync;
    wire [$clog2(800)-1:0] vga_col;    // big enough to hold the counter value
    wire [$clog2(525)-1:0] vga_row;     // big enough to hold the counter value

    // use a PLL to generate ithe pixel clock
    pll pllpx (.clock_in(hwclk), .clock_out(pxclk));

    localparam HLB  = 64;      // horizontal left border here to use below
    localparam VTB  = 48;      // vertical top border here to use below

    vgasync #( .HLB(HLB), .VTB(VTB) ) vga (
        .clk(pxclk),
        .reset(~s1_n),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .col(vga_col),
        .row(vga_row),
        .vid_active(vga_vid),
        .bdr_active(vga_bdr)
    );

    wire [9:0]  name_raddr;
    wire [10:0] pattern_raddr;
    wire [4:0]  color_raddr;

    reg [7:0]  name_rdata;
    reg [7:0]  pattern_rdata;
    reg [7:0]  color_rdata;

	reg [7:0] name_mem [0:767];
	reg [7:0] pattern_mem [0:2047];
	reg [7:0] color_mem [0:31];

	initial begin
		$readmemh("rom_name.hex", name_mem);
		//$readmemh("rom_pattern.hex", pattern_mem);
		$readmemh("rom_binnacle.hex", pattern_mem);     // https://damieng.com/typography/zx-origins/binnacle/
		$readmemh("rom_color.hex", color_mem);
	end
	always @(posedge pxclk) begin
		name_rdata      <= name_mem[name_raddr];
		pattern_rdata   <= pattern_mem[pattern_raddr];
		color_rdata     <= color_mem[color_raddr];
	end

    vdp_table_test vdp (
        .pxclk(pxclk),
        .reset(~s1_n),
        .hsync_in(vga_hsync),
        .vsync_in(vga_vsync),
        .col_in(vga_col-HLB),           // may not be most efficient way to do this :-/
        .row_in(vga_row-VTB),
        .active_in(vga_vid),
        .border_in(vga_bdr),
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

    assign hsync = ~vdp_hsync;      // Polarity of horizontal sync pulse is negative.
    assign vsync = ~vdp_vsync;      // Polarity of vertical sync pulse is negative.

    assign led = ~0;                // turn off the LEDs

endmodule
