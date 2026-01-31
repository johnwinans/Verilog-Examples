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
* A divide by N counter.
* This is useful for generate a 1HZ clock from a faster time base.
*
* In this example, the time base is assumed to be defined using a 
* macro named CLK_HZ.
*
* Note that the number of bits in the counter is calculated by the 
* compiler based on the number of bits required to represent the largest
* possible binary value that the counter is expected to contain. 
***************************************************************************/
module timer (
    input wire  clk,
    input wire  reset,
    output reg  Q = 0       // useful for sim if no reset is generated!
    );

    // Even if reset is never asserted, in a real circuit, counter and Q
    // will always have *some* initial value.
    // But, in simulation, if no reset then counter will always be unknown.
    reg [$clog2(`CLK_HZ/2):0] counter = 0;

    // Note that reset only works if clk is running. 
    // This is what is called a synchonous reset.
    always @(posedge clk)       
    begin
        if (reset) 
        begin
            counter <= 0;
            Q <= 0;
        end
        else if ( counter >= (`CLK_HZ/2)-1 )
        //else if ( counter >= (100/2)-1 )        // sloooow for simulation
        begin
            counter <= 0;
            Q <= ~Q;
        end
        else
            counter <= counter + 1;
    end

endmodule
