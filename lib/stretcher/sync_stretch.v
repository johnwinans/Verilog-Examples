//**************************************************************************
//
//    Copyright (C) 2025  John Winans
//
//    This library is free software; you can redistribute it and/or
//    modify it under the terms of the GNU Lesser General Public
//    License as published by the Free Software Foundation; either
//    version 2.1 of the License, or (at your option) any later version.
//
//    This library is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//    Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public
//    License along with this library; if not, write to the Free Software
//    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
//    USA
//
//**************************************************************************

// It is assumed that 'in' is a clean one-clk1-period tick signal.
// 1) Stretch in to 2^STRETCH_BITS clk1 periods.
// 2) Sync the stretched signal to clk2 domain using a SYNC_LEN fifo.
// 3) Generate a one-clk2-period tick on 'out'.

module stretch_sync
    #(
        parameter STRETCH_BITS = 1, // 2^STRETCH_BITS clk1 periods to stretch to
        parameter SYNC_LEN = 2      // num of bits in clk2 sync fifo >= 2
    ) (
        input wire  reset,
        input wire  clk1,   // source clock
        input wire  clk2,   // target clock
        input wire  in,     // async input
        output wire out     // sync output
    );

    reg [STRETCH_BITS-1:0] clk1_ctr_reg, clk1_ctr_next;
    reg in_wide;

    always @(negedge clk1) begin
        if (reset)
            clk1_ctr_reg <= 0;
        else
            clk1_ctr_reg <= clk1_ctr_next;
    end

    // start the stretch counter if in is true or if
    // the counter has already started
    always @(*) begin
        clk1_ctr_next = clk1_ctr_reg;
        in_wide = 0;
        if (in || clk1_ctr_reg != 0) begin
            in_wide = 1;
            clk1_ctr_next = clk1_ctr_reg + 1;
        end
    end

    // use a synchronizer to transfer the stretched signal into clk2 domain
    reg [SYNC_LEN:0]  sync_fifo;            // note this is SYNC_LEN+1 total bits

    always @(posedge clk2)
        if (reset)
            sync_fifo <= 0;
        else
            sync_fifo <= {in_wide, sync_fifo[SYNC_LEN:1]};     // shift right, discard fifo lsb

    assign out = sync_fifo[1] & ~sync_fifo[0];

endmodule
