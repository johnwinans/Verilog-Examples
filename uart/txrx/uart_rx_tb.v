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
*/

`timescale 1ns/1ns

`default_nettype none

module tb ();

    localparam bit_rate         = 9600;
    localparam clk_hz           = 25000000;

    localparam clk_period       = (1.0/clk_hz)*1000000000;          // in timescale units
    localparam brg_divisor      = clk_hz/bit_rate/16;               // 16X bit-rate clk divisor
    localparam bit_period       = (1.0/bit_rate)*1000000000;        // bit-rate clock period

    reg         clk             = 0;
    reg         reset           = 1;
    reg         brg_tick_reg    = 0;
    reg         rx              = 0;            // come out of reset spacing (not nice)
    reg         rx_read_tick    = 0;

    wire [7:0]  d;
    wire        rx_done_tick;
    wire        rx_ready;

    reg [14:0]  rx_clk_reg      = 0;

    always #(clk_period/2) clk = ~clk;

    // divide the system clock by 2604 for a BRG close enough to 9600
    always @( posedge clk ) begin
        if ( rx_clk_reg == brg_divisor-1 ) begin
            rx_clk_reg <= 0;
            brg_tick_reg <= 1;
        end else begin
            rx_clk_reg <= rx_clk_reg+1;
            brg_tick_reg <= 0;
        end
    end

    uart_rx uut (
        .clk(clk),
        .reset(reset),
        .brg_tick(brg_tick_reg),
        .rx(rx),
        .rx_read_tick(rx_read_tick),
        .d(d),
        .rx_done_tick(rx_done_tick),
        .rx_ready(rx_ready)
    );

    integer i;

    initial begin
        $dumpfile( { `__FILE__, "cd" } );
        $dumpvars;

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        reset <= 0;

        // waste enough time for an invalid null byte w/frame error arrives (a break, actually)
        wait( rx_ready );
        rx <= 1;            // marking

        @(posedge clk);
        rx_read_tick <= 1;
        @(posedge clk);
        rx_read_tick <= 0;

        // wait till the UART is IDLE
        wait ( uut.state_reg[uut.IDLE] == 1 );

        // mess with the start-bit arrival phase angle
        // a short time here will start sending before an entire stop-bit period has lapsed
        @(posedge brg_tick_reg);
        //#(clk_period*500);



        rx <= 0;            // start
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // d0
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d1
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // d2
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d3
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // d4
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // d5
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d6
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d7
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // stop

        wait( rx_ready );   // wait till the UART is done

        // read the UART holding reg
        @(posedge clk);
        rx_read_tick <= 1;
        @(posedge clk);
        rx_read_tick <= 0;

        // note that the UART sets rx_ready midway through the first stop bit
        for (i=0; i<8; i=i+1) @(posedge brg_tick_reg);      // waste 1/2 bit-time
        rx <= 1;            // stop

        // now send an all-ones character B2B
        rx <= 0;            // start
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // d0...

        wait( rx_ready );   // wait till the UART is done

        // read the UART holding reg
        @(posedge clk);
        rx_read_tick <= 1;
        @(posedge clk);
        rx_read_tick <= 0;



        // Send a byte at a rate that is a little too fast.

        // waste some time
        for (i=0; i<5; i=i+1) @(posedge brg_tick_reg);

        rx <= 0;            // start
        for (i=0; i<15; i=i+1) @(posedge brg_tick_reg);     // too short
        rx <= 1;            // d0
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d1
        for (i=0; i<15; i=i+1) @(posedge brg_tick_reg);     // too short
        rx <= 1;            // d2
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d3
        for (i=0; i<15; i=i+1) @(posedge brg_tick_reg);     // too short
        rx <= 0;            // d4
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d5
        for (i=0; i<15; i=i+1) @(posedge brg_tick_reg);     // too short
        rx <= 1;            // d6
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d7
        for (i=0; i<15; i=i+1) @(posedge brg_tick_reg);     // too short
        rx <= 1;            // stop

        wait( rx_ready );   // wait till the UART is done

        // read the UART holding reg
        @(posedge clk);
        rx_read_tick <= 1;
        @(posedge clk);
        rx_read_tick <= 0;



        // wait a while
        #(bit_period*2);
        // get out of phase with the brg
        @(posedge brg_tick_reg);
        @(posedge brg_tick_reg);

        // send a glitch (false start bit)
        rx <= 0;            // start
        for (i=0; i<4; i=i+1) @(posedge brg_tick_reg);      // too short
        rx <= 1;
        for (i=0; i<2; i=i+1) @(posedge brg_tick_reg);      // not even a full bit period


        // send a normal character to make sure the RX FSM restarts properly
        rx <= 0;            // start
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // d0
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d1
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // d2
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d3
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // d4
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d5
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // d6
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // d7
        for (i=0; i<16; i=i+1) @(posedge brg_tick_reg);
        rx <= 1;            // stop

        wait( rx_ready );   // wait till the UART is done

        // read the UART holding reg
        @(posedge clk);
        rx_read_tick <= 1;
        @(posedge clk);
        rx_read_tick <= 0;


        // wait a while
        #(bit_period*1);

        // send a spew of glitches
        rx <= 0;            // start
        for (i=0; i<4; i=i+1) @(posedge brg_tick_reg);      // too short
        rx <= 1;
        for (i=0; i<1; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // start
        for (i=0; i<1; i=i+1) @(posedge brg_tick_reg);      // too short
        rx <= 1;
        for (i=0; i<2; i=i+1) @(posedge brg_tick_reg);
        rx <= 0;            // start
        for (i=0; i<7; i=i+1) @(posedge brg_tick_reg);      // too short
        rx <= 1;
        for (i=0; i<1; i=i+1) @(posedge brg_tick_reg);

        // waste some time
        #(bit_period*5);
        $finish;
    end

    initial begin
        #(bit_period*20*10);  // stop after a while if we get stuck
        $finish;
    end

endmodule
