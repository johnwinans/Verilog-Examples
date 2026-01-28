/*
*    Copyright (C) 2024,2025  John Winans
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
* A simple UART tester.
*/

`default_nettype none

module top (
    input   wire        clk25,
    input   wire        s1_n,
    input   wire        s2_n,
    input   wire        rx,
    output  wire        tx
    );

    wire        reset = ~s1_n;

    wire        tx_done_tick;
    reg         brg_tick_reg, brg_tick_next;
    reg [15:0]  tx_clk_reg, tx_clk_next;
    reg [7:0]   d_reg, d_next;

    uart_tx utx (
        .clk(clk25),
        .reset(reset),
        .brg_tick(brg_tick_reg),       // one tick per bit to tx
        .d_tick(tx_done_tick),         // write as soon as the last is completed
        .tx_done_tick(tx_done_tick),
        .tx(tx),
        .d(d_reg)
    );

    // generate a bit rate clock 
    always @( posedge clk25, posedge reset ) begin
        if ( reset ) begin
            tx_clk_reg <= 0;
            brg_tick_reg <= 0;
            d_reg <= 8'h0d;             // start by sending CR
        end else begin
            tx_clk_reg <= tx_clk_next;
            brg_tick_reg <= brg_tick_next;
            d_reg <= d_next;
        end
    end

    always @(*) begin
        d_next          = d_reg;
        brg_tick_next   = 0;
        tx_clk_next     = tx_clk_reg + 1;

        if ( tx_done_tick ) begin
            case ( d_reg )
            8'h7e:      d_next = 8'h0d;     // ~ (highest printable char code)
            8'h0d:      d_next = 8'h0a;     // 0d = CR
            8'h0a:      d_next = 8'h20;     // 0a = LF
            default:    d_next = d_reg + 1;
            endcase
        end

        // reset the counter at the desired TX bit rate
        if ( tx_clk_reg == 2604 ) begin     // close enough for 9600 BPS
            tx_clk_next <= 0;
            brg_tick_next <= 1;
        end 
    end

endmodule
