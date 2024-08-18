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

`timescale 100ns/1ps

module tb();

    reg         reset;
    reg         ps2d;
    reg         ps2c;
    wire [8:0]  data;
    wire        ready;

    ps2 uut (
        .reset(reset),
        .ps2_data(ps2d),
        .ps2_clk(ps2c),
        .rx_data(data),
        .rx_ready(ready)
    );

    initial begin
        $dumpfile("ps2_tb.vcd");
        $dumpvars;
        reset = 0;
        ps2d = 1;
        ps2c = 1;
    end
    
    integer i;

    initial begin
        #1
        reset = 1;
        #4;
        reset = 0;
        #10;

        // start bit
        ps2d = 0;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        // data bits
        for ( i = 0; i < 8; i = i + 1 ) begin
            ps2d = i < 6 ? 1 : 0;               // just send some 1s followed by 0s
            #1;
            ps2c = 0;
            #1;
            ps2c = 1;
        end

        // odd parity bit
        ps2d = 1;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        // stop bit
        ps2d = 1;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        #5;

        // start bit
        ps2d = 0;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        // data bits
        for ( i = 0; i < 8; i = i + 1 ) begin
            ps2d = i&1;         // set every other bit
            #1;
            ps2c = 0;
            #1;
            ps2c = 1;
        end

        // odd parity bit
        ps2d = 1;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        // stop bit
        ps2d = 1;
        #1;
        ps2c = 0;
        #1;
        ps2c = 1;

        #10;
        $finish;
    end

endmodule
