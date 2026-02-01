/*
*    Copyright (C) 2026 John Winans
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

module uart_rx(
    input wire          clk,
    input wire          reset,
    input wire          brg_tick,                   // 16X bit-rate clock tick (in clk domain)
    input wire          rx,                         // serial input bits (sync'd to clk domain)
    input wire          rx_read_tick,               // true when RX reg is being read
    output wire [7:0]   d,                          // RX data (valid during d_tick)
    output wire         rx_done_tick,               // byte-completion tick 
    output wire         rx_ready                    // RX buffer is full
    );

    reg [7:0]   sr_reg, sr_next;                    // the shift register (only need 8 + 1 start bit)
    reg [7:0]   rx_reg, rx_next;                    // 1-byte RX buffer
    reg [3:0]   bit_ctr_reg, bit_ctr_next;          // bit-shift counter
    reg [3:0]   brg_ctr_reg, brg_ctr_next;          // %16 counter
    reg         rx_done_reg, rx_done_next;          // tick-flag last bit has been received
    reg         rx_full_reg, rx_full_next;          // level-flag RX buf fill (ok to read)
    reg         fe_reg, fe_next;                    // frame error flag

    // state enumerators
    localparam IDLE     = 0;                        // waiting for a start bit
    localparam START    = 1;                        // reading start bit
    localparam READING  = 2;                        // reading 8 data bits
    localparam STOP     = 3;                        // reading stop bit
    localparam FERR     = 4;                        // wait for marking after frame error

    // one-hot state
    reg [4:0] state_reg, state_next;

    always @( posedge clk ) begin
        if ( reset ) begin
            sr_reg          <= 0;                   // does not really matter
            rx_reg          <= 0;
            bit_ctr_reg     <= 0;
            brg_ctr_reg     <= 0;
            rx_done_reg     <= 0;
            rx_full_reg     <= 0;
            state_reg       <= 1'b1<<IDLE;          // state = IDLE
        end else begin
            sr_reg          <= sr_next;
            rx_reg          <= rx_next;
            bit_ctr_reg     <= bit_ctr_next;
            brg_ctr_reg     <= brg_ctr_next;
            rx_done_reg     <= rx_done_next;
            rx_full_reg     <= rx_full_next;
            state_reg       <= state_next;
        end
    end

    always @( * ) begin
        state_next      = state_reg;
        sr_next         = sr_reg;
        rx_next         = rx_reg;
        bit_ctr_next    = bit_ctr_reg;
        rx_done_next    = 0;
        state_next      = state_reg;
        brg_ctr_next    = brg_ctr_reg;

        // XXX assert state_reg has only 1 bit set here for testing


        // if the holding register is read, clear the ready status flag
        rx_full_next    = rx_read_tick ? 0 : rx_full_reg;
            
        if ( brg_tick ) begin
            brg_ctr_next = brg_ctr_reg + 1;

            // A one-hot case construct
            case ( 1'b1 )
            state_reg[IDLE]: begin
                if ( rx == 0 ) begin
                    state_next[IDLE] = 0;
                    state_next[START] = 1;
                    brg_ctr_next = 9;               // 1/2 bit-width
                end
            end

            state_reg[START]: begin
                if ( rx != 0 ) begin
                    state_next[START] = 0;       // invalid start bit
                    state_next[IDLE] = 1;
                end else if ( brg_ctr_reg == 0 ) begin
                    state_next[START] = 0;
                    state_next[READING] = 1;
                    bit_ctr_next = 0;
                end 
            end
            state_reg[READING]: begin
                if ( brg_ctr_reg == 0 ) begin
                    bit_ctr_next = bit_ctr_reg + 1;
                    sr_next = { rx, sr_reg[7:1] };  // shift into the MSB-end
                    if ( bit_ctr_reg == 7 ) begin
                        state_next[READING] = 0;
                        state_next[STOP] = 1;
                    end
                end
            end
            state_reg[STOP]: begin
                if ( brg_ctr_reg == 0 ) begin
                    rx_next = sr_reg;           // latch the received data byte
                    rx_done_next = 1;
                    rx_full_next = 1;
                    fe_next = ~rx;              // frame error if rx is spacing here
                    state_next[STOP] = 0;
                    state_next[rx ? IDLE : FERR] = 1;   // go IDLE if done
                end
            end
            state_reg[FERR]: begin
                // wait here until rx is marking so not mess up the next character
                if ( rx == 1 ) begin
                    state_next[FERR] = 0;
                    state_next[IDLE] = 1;
                end
            end
            endcase
        end
    end

    assign d = rx_reg;
    assign rx_done_tick = rx_done_next;
    assign rx_ready = rx_full_reg;

endmodule
