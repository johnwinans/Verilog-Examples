`timescale 100ns/1ps
`default_nettype none

module tb();

    initial begin
        $dumpfile("vdp_table_test_tb.vcd");
        $dumpvars;
        pxclk = 0;
    end
    
    reg   pxclk;
    reg   s1_n;
    reg   s2_n;
    wire        red;
    wire        grn;
    wire        blu;
    wire        hsync;
    wire        vsync;
    wire [7:0]  led;

    always #1 pxclk = ~pxclk;

    initial begin
        s1_n = 1;
        #4;
        s1_n = 0;
        #10;
        s1_n = 1;


        #1000000;
        $finish;
    end




    wire vga_vid;
    wire vga_hsync, vdp_hsync;
    wire vga_vsync, vdp_vsync;
    wire vga_border;
    wire [$clog2(800)-1:0] vga_col;    // big enough to hold the counter value
    wire [$clog2(525)-1:0] vga_row;     // big enough to hold the counter value

    vgasync 
/*#(
        .HVID(1024/4),
        .HFP(24/4),
        .HS(136/4),
        .HBP(160/4),
        .VVID(768),
        .VFP(3),
        .VS(6),
        .VBP(29)
    ) 
*/
        vga (
        .clk(pxclk),
        .reset(~s1_n),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .col(vga_col),
        .row(vga_row),
        .vid_active(vga_vid),
        .bdr_active(vga_border)
    );

    wire [9:0]  name_raddr;
    reg [7:0]  name_rdata;
    wire [10:0] pattern_raddr;
    reg [7:0]  pattern_rdata;
    wire [4:0]  color_raddr;
    reg [7:0]  color_rdata;

	reg [7:0] name_mem [0:767];
	reg [7:0] pattern_mem [0:2047];
	reg [7:0] color_mem [0:31];

	initial begin
		$readmemh("rom_name.hex", name_mem);
		$readmemh("rom_pattern.hex", pattern_mem);
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
        .col_in(vga_col-64),            // for border offset
        .row_in(vga_row-48),            // for border offset
        .border_in(vga_border),
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
        .color_rdata(color_rdata)
    );

    assign hsync = ~vdp_hsync;      // Polarity of horizontal sync pulse is negative.
    assign vsync = ~vdp_vsync;      // Polarity of vertical sync pulse is negative.

    assign led = ~0;                // turn off the LEDs

endmodule
