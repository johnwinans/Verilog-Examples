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

module tb();

    reg clk = 0;
    reg reset = 1;

    localparam clk_hz       = 6000000;
    localparam clk_period   = (1.0/clk_hz)*1000000000;    // period in nsec

    always #(clk_period/2) clk = ~clk;

    initial begin
        $dumpfile( { `__FILE__, "cd" } );
        $dumpvars;
    end
    
    integer i;

    initial begin
        #(4*clk_period);
        reset = 0;

        // wait for 128 characters to pass 
        for (i=0; i<128; i=i+1) begin
            @(posedge uut.tx_done_tick);
        end

        $finish;
    end

    initial begin
        #200000000;         // Force stop at 200msec no matter what.
        $finish;
    end


    wire    tx;
    reg     rx = 0;

    top #(
        .clk_hz(clk_hz)
        ) uut (
        .clk(clk),
        .s1_n(~reset),
        .rx(rx),
        .tx(tx)
    );

endmodule
