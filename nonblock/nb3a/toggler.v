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

/**
* A simple function that swaps the values in two registers.
* The purpose of this is to illustrate the difference between 
* using = and <= in simulation and synthesis.
***************************************************************************/
module toggler (
    input wire          clk,
    output reg [3:0]    x,
    output reg [3:0]    a,
    output reg [3:0]    b
    );

    // This is OK in SIM and FPGAs. 
    // But not all real devices can synthesize initialization like this.
    initial begin
        // a $monitor will be ignored when synthesizing
        $monitor("toggler: %3d: x:%4b a:%4b b:%4b", $time, x, a, b);
        x = 0;
        a = 'b1111;
        b = 'b0000;
    end


`define TOGGLE_MODE_SWAP

`ifdef TOGGLE_MODE_SWAP
    always @(posedge clk)
        a <= b;
    always @(posedge clk)
        b <= a;
    always @(posedge clk)
        x <= a + b;
`else
    always @(posedge clk)
        a <= a + 1;
    always @(posedge clk)
        x <= a + b;
    always @(posedge clk)
        b <= b + 1;
`endif

endmodule
