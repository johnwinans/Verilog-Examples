`timescale 1ns/1ps

module tb();

    reg a;
    reg b;
    wire sum;
    wire cy;

    top uut (
        .a(a),
        .b(b),
        .sum(sum),
        .cy(cy)
        );

    initial begin
        $dumpfile("top_tb.vcd");    // where to write the dump
        $dumpvars;                  // dump EVERYTHING
    end

    initial begin
        $monitor("time:%0t a=%b, b=%b, sum=%b, cy=%b", $time, a, b, sum, cy);
    
        a = 0;
        b = 0;
        // same game as we saw eariler with #0 $display()
        #0 if ( !( sum==0 && cy==0 ) ) begin $display("%s:%0d time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", `__FILE__, `__LINE__, $time, a, b, sum, cy); $finish; end
        #1

        a = 0;
        b = 1;
        #0 if ( !( sum==1 && cy==0 ) ) begin $display("%s:%0d time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", `__FILE__, `__LINE__, $time, a, b, sum, cy); $finish; end
        #1

        a = 1;
        b = 0;
        #0 if ( !( sum==1 && cy==0 ) ) begin $display("%s:%0d time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", `__FILE__, `__LINE__, $time, a, b, sum, cy); $finish; end
        #1

        a = 1;
        b = 1;
        #0 if ( !( sum==0 && cy==1 ) ) begin $display("%s:%0d time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", `__FILE__, `__LINE__, $time, a, b, sum, cy); $finish; end
        #1

        a = 0;
        b = 0;
        #0 if ( !( sum==0 && cy==0 ) ) begin $display("%s:%0d time:%0t FAILED a=%b, b=%b, sum=%b, cy=%b", `__FILE__, `__LINE__, $time, a, b, sum, cy); $finish; end
        #1
        
        $finish;
    end

endmodule
