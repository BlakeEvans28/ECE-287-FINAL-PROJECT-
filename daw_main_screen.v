module daw_main_screen (
    input        vga_clk,       // not used in this simple version, but kept for compatibility
    input        rst_n,         // not used here

    input  [9:0] xPixel,
    input  [9:0] yPixel,
    input        active_pixels,

    input  [3:0] KEY,           // not used yet (buttons)
    input  [9:0] SW,            // not used yet (switches)

    output reg [7:0] VGA_R,
    output reg [7:0] VGA_G,
    output reg [7:0] VGA_B,

    output reg [6:0] HEX0,
    output reg [6:0] HEX1,
    output reg [6:0] HEX2,
    output reg [6:0] HEX3,

    output reg [9:0] LEDR
);

// SUPER SIMPLE MAIN PAGE RENDERER
// --------------------------------
// No FSMs, no menus that move, just static colored regions
// so you can prove that your VGA timing + top-level wiring works.
//
// Layout (640x480):
//   - Top bar  : y 0-39    -> teal
//   - Menu row1: y 80-119  -> cyan bar
//   - Menu row2: y 140-179 -> green bar
//   - Menu row3: y 200-239 -> yellow bar
//   - Menu row4: y 260-299 -> magenta bar
//   - Elsewhere: dark blue background

always @(*) begin
    // default outputs
    VGA_R = 8'd0;
    VGA_G = 8'd0;
    VGA_B = 8'd0;

    // all segments off (for common-anode 7-seg)
    HEX0  = 7'b1111111;
    HEX1  = 7'b1111111;
    HEX2  = 7'b1111111;
    HEX3  = 7'b1111111;

    // LEDs off
    LEDR  = 10'b0;

    if (active_pixels) begin
        // dark blue background
        VGA_R = 8'd0;
        VGA_G = 8'd0;
        VGA_B = 8'd20;

        // top header bar
        if (yPixel < 10'd40) begin
            VGA_R = 8'd0;
            VGA_G = 8'd180;
            VGA_B = 8'd180;
        end

        // first menu row
        if ((yPixel >= 10'd80) && (yPixel < 10'd120) &&
            (xPixel >= 10'd80) && (xPixel < 10'd560)) begin
            VGA_R = 8'd0;
            VGA_G = 8'd255;
            VGA_B = 8'd255;
        end

        // second menu row
        if ((yPixel >= 10'd140) && (yPixel < 10'd180) &&
            (xPixel >= 10'd80) && (xPixel < 10'd560)) begin
            VGA_R = 8'd0;
            VGA_G = 8'd255;
            VGA_B = 8'd0;
        end

        // third menu row
        if ((yPixel >= 10'd200) && (yPixel < 10'd240) &&
            (xPixel >= 10'd80) && (xPixel < 10'd560)) begin
            VGA_R = 8'd255;
            VGA_G = 8'd255;
            VGA_B = 8'd0;
        end

        // fourth menu row
        if ((yPixel >= 10'd260) && (yPixel < 10'd300) &&
            (xPixel >= 10'd80) && (xPixel < 10'd560)) begin
            VGA_R = 8'd255;
            VGA_G = 8'd0;
            VGA_B = 8'd255;
        end
    end
end

endmodule
