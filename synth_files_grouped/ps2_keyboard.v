module ps2_keyboard (
    input  wire CLOCK_50,
    input  wire PS2_CLK,
    input  wire PS2_DAT,

    output reg  [7:0] scan_code = 8'h00,
    output reg        scan_ready = 1'b0
);

    // -----------------------
    // Synchronize PS/2 lines
    // -----------------------
    reg [2:0] ps2c_sync;
    reg [2:0] ps2d_sync;

    always @(posedge CLOCK_50) begin
        ps2c_sync <= {ps2c_sync[1:0], PS2_CLK};
        ps2d_sync <= {ps2d_sync[1:0], PS2_DAT};
    end

    wire ps2_clk_fall = (ps2c_sync[2:1] == 2'b10);  // falling edge detect
    wire ps2_data = ps2d_sync[2];

    // -----------------------
    // Frame receiver
    // -----------------------
    reg [3:0] bit_count = 0;
    reg [10:0] shift_reg = 11'd0;

    always @(posedge CLOCK_50) begin
        scan_ready <= 1'b0;  // default

        if (ps2_clk_fall) begin
            shift_reg <= {ps2_data, shift_reg[10:1]};
            bit_count <= bit_count + 1;

            // Completed 11-bit frame?
            if (bit_count == 10) begin
                bit_count <= 0;

                // Extract data bits [8:1]
                scan_code <= shift_reg[8:1];
                scan_ready <= 1'b1;
            end
        end
    end

endmodule
