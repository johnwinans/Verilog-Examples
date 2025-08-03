// Generate VGA sync signals from a 25MHZ clock.


module vgasync #(
    parameter   HVID = 640,     // horizontal active video width pix clocks
    parameter   HFP  = 16,      // horizontal front porch pix clocks
    parameter   HS   = 96,      // horizontal hsync pulse width pix clocks
    parameter   HBP  = 48,      // horizontal back porch pix clocks
    parameter   VVID = 480,     // vertical active video lines
    parameter   VFP  = 10,      // vertical front porch video lines
    parameter   VS   = 2,       // vertical vsync pulse width video lines
    parameter   VBP  = 33       // vertical back porch video lines
    ) (
    input wire clk,             // 25mhz
    input wire reset,
    output wire hsync,
    output wire vsync,
    output wire vid_active      // true when video is active
    );

    localparam  HC_MAX = HVID+HFP+HS+HBP;   // one more than the max horizontal count value
    localparam  VC_MAX = VVID+VFP+VS+VBP;   // one more than the max vertical count value

    localparam  HSYNC_BEGIN = HVID+HFP;         // first pix clock hsync should go on
    localparam  HSYNC_END   = HSYNC_BEGIN+HS;   // first pix clock that hsync should go off

    localparam  VSYNC_BEGIN = VVID+VFP;
    localparam  VSYNC_END   = VSYNC_BEGIN+VS;

    localparam  HC_BITS = $clog2(HC_MAX);   // how many bits do we need to count this high?
    localparam  VC_BITS = $clog2(VC_MAX);   // how many bits do we need to count this high?

    reg [HC_BITS-1:0]   hctr_reg, hctr_next;    // pixel counter
    reg [VC_BITS-1:0]   vctr_reg, vctr_next;    // line counter
    reg                 vid_active_reg, vid_active_next;
    reg                 hsync_reg, hsync_next;
    reg                 vsync_reg, vsync_next;

    always @ (posedge clk) 
    begin
        if (reset) begin
            hctr_reg <= 0;
            vctr_reg <= 0;
            vid_active_reg <= 0;
            hsync_reg <= 0;
            vsync_reg <= 0;
        end else begin
            hctr_reg <= hctr_next;
            vctr_reg <= vctr_next;
            vid_active_reg <= vid_active_next;
            hsync_reg <= hsync_next;
            vsync_reg <= vsync_next;
        end
    end

    // NOTE: OK to start with junk hctr_reg and/or vctr_reg values after a hard reset.
    always @ (*)
    begin
        hctr_next = ( hctr_reg >= HC_MAX-1 ) ? 0 : hctr_reg + 1;

        if ( hctr_next == 0 )
            vctr_next = ( vctr_reg >= VC_MAX-1 ) ? 0 : vctr_reg + 1;
        else
            vctr_next = vctr_reg;

        vid_active_next = ( hctr_next < HVID && vctr_next < VVID ) ? 1 : 0;

        hsync_next = ( hctr_next >= HSYNC_BEGIN && hctr_next < HSYNC_END ) ? 1 : 0;
        vsync_next = ( vctr_next >= VSYNC_BEGIN && vctr_next < VSYNC_END ) ? 1 : 0;
    end

    assign vid_active = vid_active_reg;
    assign hsync = hsync_reg;
    assign vsync = vsync_reg;

endmodule
