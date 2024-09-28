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

`timescale 1ns/1ps
`default_nettype none

module tb ( );

    reg     clk;
    reg     din;
    wire    dout;

    initial begin
        $dumpfile("sync_tb.vcd");
        $dumpvars;
        clk = 0;
        din = 0;
    end

    sync #(
        .SYNC_LEN(3)
    ) uut (
        .clk(clk),
        .in(din),
        .out(dout)
    );
    
    always #1 clk = ~clk;

    initial begin
        #3.9;
        din = 1;
        #1;
        din = 0;
        #4;
        din = 1;
        #5;
        din = 0;
        #8;
        din = 1;
        #9;
        din = 0;
        #5;
        $finish;
    end

endmodule
