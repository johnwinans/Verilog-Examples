/*
*    Copyright (C) 2024,2025,2026  John Winans
*
*    This library is free software; you can redistribute it and/or
*    modify it under the terms of the GNU Lesser General Public
*    License as published by the Free Software Foundation; either
*    version 2.1 of the License, or (at your option) any later version.
*
*    This library is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*    Lesser General Public License for more details.
*
*    You should have received a copy of the GNU Lesser General Public
*    License along with this library; if not, write to the Free Software
*    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
*    USA
*
* A naive UART.
*/

`default_nettype none

module uart_tx(
    input wire          clk,
    input wire          reset,
    input wire          brg16_tick,                 // 16X bit-rate clock tick
    input wire          d_tick,                     // start transmiting a new byte
    input wire [7:0]    d,                          // TX data (valid during d_tick)
    output wire         tx_done_tick,               // byte-completion tick 
    output wire         tx_empty,                   // TX buffer is empty
    output wire         tx                          // serial output bits
    );

    localparam  MSG_LEN = 10;                       // start + 8 data + 1 stop

    reg [3:0]   brg_mod16_reg, brg_mod16_next;      // /16 brg counter
    reg         brg_tick_reg, brg_tick_next;        // /16 brg tick signal

    reg [8:0]   sr_reg, sr_next;                    // the shift register (only need 8 + 1 start bit)
    reg [$clog2(MSG_LEN)-1:0]   ctr_reg, ctr_next;  // bit counter (for tx_done_tick)
    reg         start_reg, start_next;              // flag start on next brg_tick
    reg         tx_done_reg, tx_done_next;          // tick-flag last bit has been transmitted (ok to send next)
    reg         tx_empty_reg, tx_empty_next;        // level-flag TX buf empty (ok to send next)

    always @( posedge clk ) begin
        if ( reset ) begin
            sr_reg <= ~0;                           // all ones (marking)
            ctr_reg <= 0;                           // send several 1s then a tx_done_tick (will flush any char in flight)
            start_reg <= 0;
            tx_done_reg <= 0;
            tx_empty_reg <= 0;
            brg_mod16_reg <= 0;
            brg_tick_reg <= 0;
        end else begin
            sr_reg <= sr_next;
            ctr_reg <= ctr_next;
            start_reg <= start_next;
            tx_done_reg <= tx_done_next;
            tx_empty_reg <= tx_empty_next;
            brg_mod16_reg <= brg_mod16_next;
            brg_tick_reg <= brg_tick_next;
        end
    end

    // bit rate clock generator
    always @( * ) begin
        brg_tick_next = 0;
        brg_mod16_next = brg_mod16_reg;
        if ( brg16_tick ) begin
            brg_mod16_next = brg_mod16_reg + 1;
            brg_tick_next = brg_mod16_reg == 0;         // set brg_tick_next once per 16 counts
        end
    end

    // Note that this concerns itself with both clk and brg_tick when changing states.
    // the state is represented by sr_reg[0], ctr_reg, and start_reg
    // Might not be the best way to implement this.  But it is short & simple.
    always @( * ) begin
        start_next = start_reg;
        ctr_next = ctr_reg;
        sr_next = sr_reg;
        tx_done_next = 0;
        tx_empty_next = tx_empty_reg;

        // Note that it is illegal to set d_tick before tx_done_tick
        // and tx_done_tick can not coinside with brg_tick_reg
        if ( d_tick ) begin
            tx_empty_next = 0;
            if ( brg_tick_reg ) begin
                // this is an optimization to save a bit period when d_tick coincides with brg_tick_reg
                sr_next = { d, 1'b0 };                      // load & go right away
                ctr_next = 0;
            end else begin
                // The following is subtle, we don't zero the start bit yet for TWO reasons:
                // 1) d_tick can arrive during a stop bit (don't zero the tx output just yet!) 
                // 2) we need to begin the start bit on the next brg_tick_reg for it to have the right period
                sr_next = { d, 1'b1 };                      // the LSB here will be output on next clk!
                start_next = 1;                             // start sending on the next brg_tick_reg
            end
        end else if ( brg_tick_reg ) begin
            if ( start_reg ) begin
                sr_next[0] = 1'b0;                          // zero the start bit
                ctr_next = 0;                               // reset the bit counter
            end else begin
                sr_next = { 1'b1, sr_reg[8:1] };            // shift-in 1 bits for future stop bit(s)
                ctr_next = ctr_reg + (ctr_reg != MSG_LEN);  // seize counter after sending stop bit(s)
                tx_done_next = (ctr_reg == MSG_LEN-2);      // true as the stop bit begins
                tx_empty_next = (ctr_reg >= MSG_LEN-2);     // true when TX is empty/ready
            end
            start_next = 0;
        end
    end

    assign tx = sr_reg[0];                                  // tx = LSB of the tx shift register
    assign tx_done_tick = tx_done_reg;
    assign tx_empty = tx_empty_reg;

endmodule
