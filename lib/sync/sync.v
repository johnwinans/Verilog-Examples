// out = in, synchronized to "clk"

// See:
// https://youtu.be/egwMrrQBfLI
// http://www.sunburst-design.com/papers/CummingsSNUG2008Boston_CDC.pdf

module sync
    #(
        parameter SYNC_LEN = 2   // num of bits in sync fifo >= 2
    ) (
        input wire  clk,    // target clock domain
        input wire  in,     // async input
        output wire out     // sync output
    );

    reg [SYNC_LEN-1:0] sync_fifo;

    always @(posedge clk)
        sync_fifo <= {in, sync_fifo[SYNC_LEN-1:1]};     // shift right, discard fifo lsb

    assign out = sync_fifo[0];                          // fifo lsb is the 'oldest' value

endmodule
