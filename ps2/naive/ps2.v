//**************************************************************************
//
//    Copyright (C) 2024  John Winans
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


// A very naive PS2 keyboard interface.
// If this ever gets out of sync with the ps2 data, it will report garbage.

module ps2 (
    input wire          reset,
    input wire          ps2_data,
    input wire          ps2_clk,
    output wire [8:0]   rx_data,    // data with parity in MSB position
    output wire         rx_ready    // rx_data has valid/stable data
    );

    reg [9:0]   rx_reg, rx_next;                // one less to discard the start bit 
    reg [3:0]   rx_count_reg, rx_count_next;
    reg         rx_ready_reg, rx_ready_next;

    // async reset
    always @ (negedge ps2_clk, posedge reset) begin
        if (reset) begin
            rx_reg <= 0;
            rx_count_reg <= 0;
            rx_ready_reg <= 0;
        end else begin
            rx_reg <= rx_next;
            rx_count_reg <= rx_count_next;
            rx_ready_reg <= rx_ready_next;
        end
    end

    always @(*) begin
        rx_next = { ps2_data, rx_reg[9:1] };        // shift in LSB first
        rx_count_next = ( rx_count_reg + 1 ) % 11;  // modulo 12 counter
        rx_ready_next = rx_count_reg == 10;         // 1 when reporting the last of the 11 bits
    end

    assign rx_ready = rx_ready_reg;
    assign rx_data = rx_reg[8:0];                   // prune off the stop bit

endmodule
