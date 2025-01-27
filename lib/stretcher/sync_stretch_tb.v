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

`timescale 1ns/10ps
`default_nettype none

module tb ( );

    reg     reset;
    reg     clk1;
    reg     clk2;
    reg     din;
    wire    dout;

    initial begin
        $dumpfile("sync_stretch_tb.vcd");
        $dumpvars;
    end

    stretch_sync uut
    (
        .reset(reset),
        .clk1(clk1),
        .clk2(clk2),
        .in(din),
        .out(dout)
    );

    always #1 clk1 = ~clk1;

    always #0.7 clk2 = ~clk2;       // clk2 is running faster than clk1
    //always #1.3 clk2 = ~clk2;       // clk2 is running slower than clk1

    initial begin
        reset = 1;
        clk1 = 0;
        clk2 = 0;
        din = 0;
        #4;
        reset = 0;
        #3;

        #0.1;        // eliminate sim scheduling order-of-events problems

        din = 1;
        #2;
        din = 0;
        #6;

        din = 1;
        #2;
        din = 0;
        #6;

        din = 1;
        #2;
        din = 0;
        #10;


        // When clk2 is slower than clk1 then might have to increase the stretch width.
        // BUT then the period between din pulses has to be widened too.
        din = 1;
        #2;
        din = 0;
        #4;
        din = 1;
        #2;
        din = 0;
        #10;

        din = 1;
        #2;
        din = 0;
        #4;
        din = 1;
        #2;
        din = 0;
        #10;

        din = 1;
        #2;
        din = 0;
        #4;
        din = 1;
        #2;
        din = 0;
        #10;

        din = 1;
        #2;
        din = 0;
        #4;
        din = 1;
        #2;
        din = 0;
        #10;

        din = 1;
        #2;
        din = 0;
        #4;
        din = 1;
        #2;
        din = 0;
        #10;

        

        $finish;
    end

endmodule
