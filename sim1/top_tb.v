// 10ns = the time represented by #1
// 1ns is the resolution of the times stored in the simulation VCD (Value Change Dump) file
`timescale 10ns/1ns

// Create a module named 'tb' that has no ports
module tb();

    reg a;          // Signals driven from within a process (an initial or always block) must be type reg
    reg b;

    wire sum;       // Signals that are driven from outside a process must be type wire
    wire cy;



    // A (very simple) behavioral circuit description
    // Note that things like this are also possible: assign q = ~a&(b|c)^d
    //assign sum = a ^ b;
    //assign  cy = a & b;


    // A structural circuit description.
    // Note that xor() and other gates can have as many inputs as you want
    xor( sum, a, b );
    and( cy, a, b );



    // 'initial' is a 'process' that will run once when the simulation starts
    // $xyz is the notation used to refer to a 'system task'
    initial begin
        $dumpfile("top_tb.vcd");    // where to write the dump
        $dumpvars;                  // dump EVERYTHING
    end

    // You can have as many initial blocks as you want.
    // All initial process blocks will start at the same time and run in parallel.
    initial begin
        a = 0;      // = is a 'blocking assignment' that runs in the order given during simulation
        b = 0;

        // Because zero time has passed since assigning values above, the 
        // simulator may not have had time to perform the XOR and AND operations.
        // This is NOT because it is simulating a propagation delay.  But it
        // often acts in a similar manner. 
        // $time is called a 'system task'
 
        $display("%5t: a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy);

        // Note that the sum and cy values are displayed as 'x'.
        // This is because they do not yet have a known value.
        // Verilog types like wire and reg have 4-state values!
        // They can be 0, 1, x or z.
        // x = unknown.
        // z = HI-Z (floating... remember this is simulating hardware)

        #1;         // #nnn is a statement that will wait nnn units of time given in the `timescale
 
        // Because the simulator has advanced the time, any outputs from other
        // process blocks and combinational corcuitry will have been simulated
        // by now.

        $display("%5t: a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy);
        #1;     // wait some more so that the following won't interfere with the $display

        a = 0;
        b = 1;

        #1;
        $display("%5t: a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy);
        #1;

        a = 1;
        b = 0;

        #1;
        $display("%5t: a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy);
        #1;

        a = 1;
        b = 1;

        #1;
        $display("%5t: a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy);
        #1;

        a = 0;
        b = 0;
        #1;
        $display("%5t: a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy);
        #2;
        
        $finish;    // The $finish 'system task' halts the simulation
    end

endmodule
