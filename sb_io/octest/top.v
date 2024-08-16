`default_nettype none

module top (
    input   wire        clk25,
    inout   wire        s1_n,
    inout   wire        s2_n,
    output  wire [7:0]  led
    );


    // explicitly configure the PS2 IO pins (to make yosys happy)
    // See FPGA-TN-02026-3.2 (iCE40 Technology Library), page 83
    SB_IO #(
        .PIN_TYPE(6'b101001),
        .PULLUP(1'b1)
    ) sbtest (
        .PACKAGE_PIN(s1_n),
        .OUTPUT_ENABLE(~sb_out), // turn on the output driver when low else float
        .D_OUT_0(sb_out),        // when low, drive pin to zero
        .D_IN_0(sb_in)           // this lets us look at the pin input
    );


    wire    sb_out;
    wire    sb_in;

    reg [23:0] ctr_reg; // should count a bit over 2HZ

    always @(posedge clk25) begin
        ctr_reg <= ctr_reg + 1;
    end

    assign sb_out = ctr_reg[23];

    assign led = ~{ 5'b0, sb_out, sb_in };

endmodule
