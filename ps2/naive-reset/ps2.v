
// A naive PS2 keyboard interface with cheesy keyboard reset generator.
// If this ever gets out of sync with the ps2 data, it will report garbage.

module ps2 (
    input wire          reset,
    input wire          ps2_data_in,
    output wire         ps2_data_out,
    input wire          ps2_clk_in,
    output wire         ps2_clk_out,
    output wire [8:0]   rx_data,    // data with parity in MSB position
    output wire         rx_ready    // rx_data has valid/stable data
    );

    reg [9:0]   rx_reg, rx_next;                // one less to discard the start bit 
    reg [3:0]   rx_count_reg, rx_count_next;
    reg         rx_ready_reg, rx_ready_next;

    // async reset
    always @ (negedge ps2_clk_in, posedge reset) begin
        if (reset) begin
            rx_reg <= 0;
            rx_count_reg <= 0;
            rx_ready_reg <= 0;
        end else begin
            rx_reg <= rx_next;
            rx_count_reg <= rx_count_next;
            rx_ready_reg <= rx_ready_next;
        end
    end

    always @(*) begin
        rx_next = { ps2_data_in, rx_reg[9:1] };     // shift in LSB first

        // XXX this is sooooooooo bad!!!!!
        if ( ps2_data_reg == 0 ) 
            rx_count_next = 0;   // XXX stall the counter during the reset cycle
        else
            rx_count_next = ( rx_count_reg + 1 ) % 11;  // modulo 12 counter

        rx_ready_next = rx_count_reg == 10;         // 1 when reporting the last of the 11 bits
    end

    assign rx_ready = rx_ready_reg;
    assign rx_data = rx_reg[8:0];                   // prune off the stop bit

    // used for the keyboard reset command hack
    reg         ps2_data_reg;

    always @ (negedge ps2_clk_in, posedge reset) begin
/*
        if ( reset ) 
            ps2_data_reg <= 0;
        else
            ps2_data_reg <= ~reset;
*/

        if (reset) begin
            // if reset is active, hold down the data line
            ps2_data_reg <= 0;
        end else begin
            // if reset is not active then release the data line on the next negedge ps2_clk_in
//            if ( ps2_clk_in == 0)
                ps2_data_reg <= 1;
        end

    end

    assign ps2_clk_out = ~reset;            // pull down the clock for the length of the reset signal
    assign ps2_data_out = ps2_data_reg;     // pull down the data when driving a 0 else let it float

endmodule
