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

`default_nettype none

/**
* This attempts to create a tri-state output.
*
* When s1 is pressed (low) the output driver will be enabled.
* When the the output driver is enabled, s2 pressed will cause the
* output to be driven high and when s2 is released the output will
* be driven low.
*
* Yosys does not include the pullup (if the pcf file requests it)
* on outputs with inferred tristate drivers.
*
* Note that Yosys will only (currently) infer a tristate driver
* if the ternary operator is used to drive an output pin.
**************************************************************************/
module top (
    input  wire     s1_n,
    input  wire     s2_n,
    output wire     led1,
    output wire     led2,
    output wire     d_out
    );

    // This does not seem to turn on the pullup when d_out=1'bz
    // It *does* appear to let d_out float when it is set to z.
    //
    // Yosys includes a warning about limited tri-state support.  
    // So this misfeature is probably a thing.

    assign led1 = s1_n;                 // LED will go on when press s1
    assign led2 = s2_n;                 // LED will go on when press s2

    assign d_out = ~s1_n ? ~s2_n : 1'bz; // tri-state when s1 is released

endmodule
