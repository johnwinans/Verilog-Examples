// Generate VGA sync signals
// Default parameters = 512x384, centered, with borders, on 640x480@60 VGA w/25MHZ px clock
//


module vgasync #(
    parameter   HLB  = 64,      // horizontal left border width px clocks
    parameter   HVID = 512,     // horizontal video width px clocks
    parameter   HRB  = 64,      // horizontal right border width px clocks
    parameter   HFP  = 16,      // horizontal front porch px clocks
    parameter   HS   = 96,      // horizontal hsync pulse width px clocks
    parameter   HBP  = 48,      // horizontal back porch px clocks
    parameter   VTB  = 48,      // vertical top border video lines
    parameter   VVID = 384,     // vertical video video lines
    parameter   VBB  = 48,      // vertical bottom border video lines
    parameter   VFP  = 10,      // vertical front porch video lines
    parameter   VS   = 2,       // vertical vsync pulse width video lines
    parameter   VBP  = 33,      // vertical back porch video lines

    // these are not localparams because they are used in col and row
    parameter  HC_MAX = HLB+HVID+HRB+HFP+HS+HBP,    // one more than the max horizontal count value
    parameter  VC_MAX = VTB+VVID+VBB+VFP+VS+VBP,    // one more than the max vertical count value
    parameter  HC_BITS = $clog2(HC_MAX),            // how many bits do we need to count this high?
    parameter  VC_BITS = $clog2(VC_MAX)             // how many bits do we need to count this high?
    ) (
    input wire                  clk,       // px clock
    input wire                  reset,
    output wire                 hsync,
    output wire                 vsync,
    output wire [HC_BITS-1:0]   col,        // current px column
    output wire                 col_last,   // col == max value 
    output wire [VC_BITS-1:0]   row,        // current pixel row
    output wire                 row_last,   // col == max value 
    output wire                 vid_active, // true when video is active (not including borders)
    output wire                 bdr_active  // true when border video is active 
    );

    localparam  HLB_BEGIN   = 0;                // first col of the horiz left border
    localparam  HVID_BEGIN  = HLB_BEGIN+HLB;    // first col of the horiz active video region
    localparam  HRB_BEGIN   = HVID_BEGIN+HVID;  // first col of the horiz right border
    localparam  HFP_BEGIN   = HRB_BEGIN+HRB;    // first col of the horiz front porch
    localparam  HS_BEGIN    = HFP_BEGIN+HFP;    // first col of the horiz sync pulse
    localparam  HBP_BEGIN   = HS_BEGIN+HS;      // first col of the horiz back porch

    localparam  VTB_BEGIN   = 0;                // first row of the vertical top border
    localparam  VVID_BEGIN  = VTB_BEGIN+VTB;    // first row of the vertical active video region
    localparam  VBB_BEGIN   = VVID_BEGIN+VVID;  // first row of the vertical bottom border
    localparam  VFP_BEGIN   = VBB_BEGIN+VBB;    // first row of the vertical front porch
    localparam  VS_BEGIN    = VFP_BEGIN+VFP;    // first row of the vertical sync pulse
    localparam  VBP_BEGIN   = VS_BEGIN+VS;      // first row of the vertical back porch

    localparam  HS_END      = HBP_BEGIN;        // first col that hsync should be off
    localparam  VS_END      = VBP_BEGIN;        // first row that vsync should be off

    localparam  HLB_END     = HVID_BEGIN;       // first col past end left border
    localparam  HVID_END    = HRB_BEGIN;        // first col past end horiz active video
    localparam  HRB_END     = HFP_BEGIN;        // first col past end of right border
    localparam  VTB_END     = VVID_BEGIN;       // first row past end top border
    localparam  VVID_END    = VBB_BEGIN;        // first col past end vertical active video
    localparam  VBB_END     = VFP_BEGIN;        // first row past end of bottom border

    localparam  HVIS_BEGIN  = HLB_BEGIN;        // first col of the horiz visible video
    localparam  HVIS_END    = HRB_END;          // first col past end of the horiz visible video
    localparam  VVIS_BEGIN  = VTB_BEGIN;        // first row of the vertical visible video
    localparam  VVIS_END    = VBB_END;          // first row past end of the vertical visible video

    reg [HC_BITS-1:0]   hctr_reg, hctr_next;    // pixel counter
    reg [VC_BITS-1:0]   vctr_reg, vctr_next;    // line counter
    reg                 vid_active_reg, vid_active_next;
    reg                 hsync_reg, hsync_next;
    reg                 vsync_reg, vsync_next;
    reg                 border_reg, border_next;
    reg                 visible_next;

    always @ (posedge clk) 
    begin
        if (reset) begin
            hctr_reg <= 0;
            vctr_reg <= 0;
            vid_active_reg <= 0;
            hsync_reg <= 0;
            vsync_reg <= 0;
            border_reg <= 0;
        end else begin
            hctr_reg <= hctr_next;
            vctr_reg <= vctr_next;
            vid_active_reg <= vid_active_next;
            hsync_reg <= hsync_next;
            vsync_reg <= vsync_next;
            border_reg <= border_next;
        end
    end

    // NOTE: OK to start with junk hctr_reg and/or vctr_reg values after a hard reset.
    always @ (*)
    begin
        vctr_next = vctr_reg;

        hctr_next = ( hctr_reg >= HC_MAX-1 ) ? 0 : hctr_reg + 1;

        if ( hctr_next == 0 )
            vctr_next = ( vctr_reg >= VC_MAX-1 ) ? 0 : vctr_reg + 1;

        vid_active_next = hctr_next >= HVID_BEGIN && hctr_next < HVID_END && vctr_next >= VVID_BEGIN && vctr_next < VVID_END;
        visible_next = hctr_next >= HVIS_BEGIN && hctr_next < HVIS_END && vctr_next >= VVIS_BEGIN && vctr_next < VVIS_END;

        border_next = visible_next && !vid_active_next;

        hsync_next = hctr_next >= HS_BEGIN && hctr_next < HS_END;
        vsync_next = vctr_next >= VS_BEGIN && vctr_next < VS_END;

    end

    assign vid_active = vid_active_reg;
    assign hsync = hsync_reg;
    assign vsync = vsync_reg;
    assign col = hctr_reg;
    assign row = vctr_reg;
    assign bdr_active = border_reg;

    assign col_last = hctr_next == 0;                   // true for one tick before changes to zero
    assign row_last = hctr_next == 0 && vctr_next == 0; // true for one tick before changes to zero

endmodule
