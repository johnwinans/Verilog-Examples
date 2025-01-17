// Generate VGA sync signals
// Default parameters = 512x384, centered, with borders, on 640x480@60 VGA w/25MHZ px clock
//


module vgasync #(
    parameter   HVID = 512,     // horizontal video width px clocks
    parameter   HRB  = 64,      // horizontal right border width px clocks
    parameter   HFP  = 16,      // horizontal front porch px clocks
    parameter   HS   = 96,      // horizontal hsync pulse width px clocks
    parameter   HBP  = 48,      // horizontal back porch px clocks
    parameter   HLB  = 64,      // horizontal left border width px clocks
    parameter   VVID = 384,     // vertical video video lines
    parameter   VBB  = 48,      // vertical bottom border video lines
    parameter   VFP  = 10,      // vertical front porch video lines
    parameter   VS   = 2,       // vertical vsync pulse width video lines
    parameter   VBP  = 29,      // vertical back porch video lines
    parameter   VTB  = 48,      // vertical top border video lines

    // these are not localparams because they are used in col and row
    parameter  HC_MAX = HVID+HRB+HFP+HS+HBP+HLB,    // one more than the max horizontal count value
    parameter  VC_MAX = VVID+VTB+VFP+VS+VBP+VBB,    // one more than the max vertical count value
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

    localparam  HRB_BEGIN   = HVID;             // first col of the right border
    localparam  HFP_BEGIN   = HRB_BEGIN+HRB;    // first col of the horiz front porch
    localparam  HS_BEGIN    = HFP_BEGIN+HFP;    // first col of the horiz sync pulse
    localparam  HBP_BEGIN   = HS_BEGIN+HS;      // first col of the horiz back porch
    localparam  HLB_BEGIN   = HBP_BEGIN+HBP;    // first col of the horiz left border

    localparam  VBB_BEGIN   = VVID;             // first row of the bottom border
    localparam  VFP_BEGIN   = VBB_BEGIN+VBB;    // first row of the vert front porch
    localparam  VS_BEGIN    = VFP_BEGIN+VFP;    // first row of the vert sync pulse
    localparam  VBP_BEGIN   = VS_BEGIN+VS;      // first row of the vert back porch
    localparam  VTB_BEGIN   = VBP_BEGIN+VBP;    // first row of the vert top border

    localparam  HS_END      = HBP_BEGIN;        // first col that hsync should be off
    localparam  VS_END      = VBP_BEGIN;        // first row that vsync should be off

    localparam  HRB_END     = HFP_BEGIN;        // first col past end of right border
    localparam  HLB_END     = HC_MAX;           // first col past end left border
    localparam  VBB_END     = VFP_BEGIN;        // first row past end of bottom border
    localparam  VTB_END     = VC_MAX;           // first row past end top border

    reg [HC_BITS-1:0]   hctr_reg, hctr_next;    // pixel counter
    reg [VC_BITS-1:0]   vctr_reg, vctr_next;    // line counter
    reg                 vid_active_reg, vid_active_next;
    reg                 hsync_reg, hsync_next;
    reg                 vsync_reg, vsync_next;
    reg                 border_reg, border_next;

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
        hctr_next = ( hctr_reg >= HC_MAX-1 ) ? 0 : hctr_reg + 1;

        if ( hctr_next == 0 )
            vctr_next = ( vctr_reg >= VC_MAX-1 ) ? 0 : vctr_reg + 1;
        else
            vctr_next = vctr_reg;

        vid_active_next = ( hctr_next < HVID && vctr_next < VVID ) ? 1 : 0;

        visible_next = ( hctr_next < HRB_END || hctr_next >= HLB_BEGIN ) && ( vctr_next < VBB_END || vctr_next >= VTB_START );
        border_next = visible_next && !vid_active_next;

        hsync_next = ( hctr_next >= HS_BEGIN && hctr_next < HS_END ) ? 1 : 0;
        vsync_next = ( vctr_next >= VS_BEGIN && vctr_next < VS_END ) ? 1 : 0;

/*
        border_next = ( ( hctr_next >= HRB_BEGIN && hctr_next < HRB_END ) || ( hctr_next >= HLB_BEGIN && hctr_next < HLB_END ) ) ||
                      ( ( vctr_next >= VBB_BEGIN && vctr_next < VBB_END ) || ( vctr_next >= VTB_BEGIN && vctr_next < VTB_END ) );

        // can't have a border outside a visible region
        if ( vctr_next >= VBB_END && vctr_next < VTB_BEGIN )
            border_next = 0;
        if ( hctr_next >= HRB_END && hctr_next < HLB_BEGIN )
            border_next = 0;
*/
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
