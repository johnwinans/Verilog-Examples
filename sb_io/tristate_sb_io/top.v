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
* Manually can configure the IO block to do what we want.
* See The LATTICE ICE Technology Library Tecnical Note (FPGA-TN-02026-3.2)
**************************************************************************/
module top (
    input  wire     s1_n,
    input  wire     s2_n,
    output wire     led1,
    output wire     led2,
    output wire     d_out
    );

    wire driver_enable;

    // FPGA-TN-02026-3.2 notes the following regarding
    // the PULLUP parameter on the SB_IO:
    //
    // By default, the IO will have NO pull up. This parameter is used only 
    // on bank 0, 1, and 2. Ignored when it is placed at bank 3.
    //
    // And yet... it seems to work fine on pin 1 (which is on bank 3.)

    SB_IO #(
        .PIN_TYPE(6'b1010_01),
        .PULLUP(1'b1)                   // enable the pullup
//        .PULLUP(1'b0)                   // disable the pullup
    ) tri_state (
        .PACKAGE_PIN(d_out),            // the physical pin number with the pullup on it
        .OUTPUT_ENABLE(driver_enable),  // when driver_enable is high, turn on the output
        .D_OUT_0(~s2_n)                 // the value to write out the pin when the driver is on
    );

    assign led1 = s1_n;                 // LED will go on when press s1
    assign led2 = s2_n;                 // LED will go on when press s2

    assign driver_enable = ~s1_n;       // turn on driver when s1 is low

endmodule
