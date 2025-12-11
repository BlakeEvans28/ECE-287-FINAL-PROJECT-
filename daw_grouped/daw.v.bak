module daw (
  	//////////// ADC //////////
	//output		          		ADC_CONVST,
	//output		          		ADC_DIN,
	//input 		          		ADC_DOUT,
	//output		          		ADC_SCLK,

	//////////// Audio //////////
	//input 		          		AUD_ADCDAT,
	//inout 		          		AUD_ADCLRCK,
	//inout 		          		AUD_BCLK,
	//output		          		AUD_DACDAT,
	//inout 		          		AUD_DACLRCK,
	//output		          		AUD_XCK,

	//////////// CLOCK //////////
	//input 		          		CLOCK2_50,
	//input 		          		CLOCK3_50,
	//input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SDRAM //////////
	//output		    [12:0]		DRAM_ADDR,
	//output		     [1:0]		DRAM_BA,
	//output		          		DRAM_CAS_N,
	//output		          		DRAM_CKE,
	//output		          		DRAM_CLK,
	//output		          		DRAM_CS_N,
	//inout 		    [15:0]		DRAM_DQ,
	//output		          		DRAM_LDQM,
	//output		          		DRAM_RAS_N,
	//output		          		DRAM_UDQM,
	//output		          		DRAM_WE_N,

	//////////// I2C for Audio and Video-In //////////
	//output		          		FPGA_I2C_SCLK,
	//inout 		          		FPGA_I2C_SDAT,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	//output		     [6:0]		HEX4,
	//output		     [6:0]		HEX5,

	//////////// IR //////////
	//input 		          		IRDA_RXD,
	//output		          		IRDA_TXD,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// PS2 //////////
	//inout 		          		PS2_CLK,
	//inout 		          		PS2_CLK2,
	//inout 		          		PS2_DAT,
	//inout 		          		PS2_DAT2,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// Video-In //////////
	//input 		          		TD_CLK27,
	//input 		     [7:0]		TD_DATA,
	//input 		          		TD_HS,
	//output		          		TD_RESET_N,
	//input 		          		TD_VS,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output reg	     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output reg	     [7:0]		VGA_G,
	output		          		VGA_HS,
	output reg	     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_1

);

  wire [7:0] bpm;
  
  // BPM digits
  wire [3:0] bpm_ones;
  wire [3:0] bpm_tens;
  wire [3:0] bpm_hundreds;

  assign bpm_ones     = bpm % 10;
  assign bpm_tens     = (bpm / 10) % 10;
  assign bpm_hundreds = bpm / 100;



  // Turn off all displays.
	assign	HEX0		=	7'h00;
	assign	HEX1		=	7'h00;
	assign	HEX2		=	7'h00;
	assign	HEX3		=	7'h00;

wire active_pixels; // is on when we're in the active draw space

wire [9:0]x; // current x
wire [9:0]y; // current y - 10 bits = 1024 ... a little bit more than we need

wire clk;
wire rst;

assign clk = CLOCK_50;
assign rst = SW[0];

assign LEDR[0] = active_pixels;

vga_driver_daw the_vga(
.clk(clk),
.rst(rst),

.vga_clk(VGA_CLK),

.hsync(VGA_HS),
.vsync(VGA_VS),

.active_pixels(active_pixels),

.xPixel(x),
.yPixel(y),

.VGA_BLANK_N(VGA_BLANK_N),
.VGA_SYNC_N(VGA_SYNC_N)
);

// Shapes ------------------------------------------------------------------------

// pause button
parameter bar_w = 5;
parameter bar_h = 24;
parameter bar_gap = 6;
parameter pause_location_x = 20;
parameter pause_location_y = 20;

wire [9:0] left_bar_x1 = pause_location_x - (bar_gap / 2) - bar_w;
wire [9:0] left_bar_x2 = left_bar_x1 + bar_w;

wire [9:0] right_bar_x1 = pause_location_x + (bar_gap / 2);
wire [9:0] right_bar_x2 = right_bar_x1 + bar_w;

wire [9:0] bar_y_top = pause_location_y;
wire [9:0] bar_y_bottom = pause_location_y + bar_h;

wire [9:0] left_bar = (x >= left_bar_x1 && x < left_bar_x2 &&
							  y >= bar_y_top && y < bar_y_bottom); // top has lower value than bottom since origin is top left

wire [9:0] right_bar = (x >= right_bar_x1 && x < right_bar_x2 &&
							  y >= bar_y_top && y < bar_y_bottom); 

//play button
parameter play_h = 24;
parameter play_w = 18;
parameter play_location_x = 12;
parameter play_location_y = 20;

wire signed [10:0] dx = x - play_location_x;
wire signed [10:0] dy = y - (play_location_y + play_h/2);

// abs(dy)
wire [10:0] abs_dy = dy[10] ? -dy : dy;

wire play_button =
    (dx >= 0) && (dx < play_w) &&
    (abs_dy <= play_h/2) &&
    (abs_dy * play_w <= (play_w - dx) * (play_h/2));



//--------------------------------------------------------------------------------

// bitmapped numbers -------------------------------------------------------------
// 5×7 bitmap for digit '4'
// Digit 0
function [4:0] digit0;
    input [2:0] row;
    begin
        case(row)
            0: digit0 = 5'b01110;
            1: digit0 = 5'b10001;
            2: digit0 = 5'b10011;
            3: digit0 = 5'b10101;
            4: digit0 = 5'b11001;
            5: digit0 = 5'b10001;
            6: digit0 = 5'b01110;
            default: digit0 = 5'b00000;
        endcase
    end
endfunction

// Digit 1
function [4:0] digit1;
    input [2:0] row;
    begin
        case(row)
            0: digit1 = 5'b00100;
            1: digit1 = 5'b01100;
            2: digit1 = 5'b00100;
            3: digit1 = 5'b00100;
            4: digit1 = 5'b00100;
            5: digit1 = 5'b00100;
            6: digit1 = 5'b11111;
            default: digit1 = 5'b00000;
        endcase
    end
endfunction

// Digit 2
function [4:0] digit2;
    input [2:0] row;
    begin
        case(row)
            0: digit2 = 5'b01110;
            1: digit2 = 5'b10001;
            2: digit2 = 5'b00001;
            3: digit2 = 5'b00110;
            4: digit2 = 5'b01000;
            5: digit2 = 5'b10000;
            6: digit2 = 5'b11111;
            default: digit2 = 5'b00000;
        endcase
    end
endfunction

// Digit 3
function [4:0] digit3;
    input [2:0] row;
    begin
        case(row)
            0: digit3 = 5'b11110;
            1: digit3 = 5'b00001;
            2: digit3 = 5'b00001;
            3: digit3 = 5'b01110;
            4: digit3 = 5'b00001;
            5: digit3 = 5'b00001;
            6: digit3 = 5'b11110;
            default: digit3 = 5'b00000;
        endcase
    end
endfunction

// Digit 4
function [4:0] digit4;
    input [2:0] row;
    begin
        case(row)
            0: digit4 = 5'b00100;
            1: digit4 = 5'b01100;
            2: digit4 = 5'b10100;
            3: digit4 = 5'b10100;
            4: digit4 = 5'b11111;
            5: digit4 = 5'b00100;
            6: digit4 = 5'b00100;
            default: digit4 = 5'b00000;
        endcase
    end
endfunction

// Digit 5
function [4:0] digit5;
    input [2:0] row;
    begin
        case(row)
            0: digit5 = 5'b11111;
            1: digit5 = 5'b10000;
            2: digit5 = 5'b11110;
            3: digit5 = 5'b00001;
            4: digit5 = 5'b00001;
            5: digit5 = 5'b10001;
            6: digit5 = 5'b01110;
            default: digit5 = 5'b00000;
        endcase
    end
endfunction

// Digit 6
function [4:0] digit6;
    input [2:0] row;
    begin
        case(row)
            0: digit6 = 5'b00110;
            1: digit6 = 5'b01000;
            2: digit6 = 5'b10000;
            3: digit6 = 5'b11110;
            4: digit6 = 5'b10001;
            5: digit6 = 5'b10001;
            6: digit6 = 5'b01110;
            default: digit6 = 5'b00000;
        endcase
    end
endfunction

// Digit 7
function [4:0] digit7;
    input [2:0] row;
    begin
        case(row)
            0: digit7 = 5'b11111;
            1: digit7 = 5'b00001;
            2: digit7 = 5'b00010;
            3: digit7 = 5'b00100;
            4: digit7 = 5'b01000;
            5: digit7 = 5'b10000;
            6: digit7 = 5'b10000;
            default: digit7 = 5'b00000;
        endcase
    end
endfunction

// Digit 8
function [4:0] digit8;
    input [2:0] row;
    begin
        case(row)
            0: digit8 = 5'b01110;
            1: digit8 = 5'b10001;
            2: digit8 = 5'b10001;
            3: digit8 = 5'b01110;
            4: digit8 = 5'b10001;
            5: digit8 = 5'b10001;
            6: digit8 = 5'b01110;
            default: digit8 = 5'b00000;
        endcase
    end
endfunction

// Digit 9
function [4:0] digit9;
    input [2:0] row;
    begin
        case(row)
            0: digit9 = 5'b01110;
            1: digit9 = 5'b10001;
            2: digit9 = 5'b10001;
            3: digit9 = 5'b01111;
            4: digit9 = 5'b00001;
            5: digit9 = 5'b00010;
            6: digit9 = 5'b11100;
            default: digit9 = 5'b00000;
        endcase
    end
endfunction

// time sig slash
function [4:0] digit_slash;
    input [2:0] row;
    begin
        case(row)
            0: digit_slash = 5'b00001;
            1: digit_slash = 5'b00010;
            2: digit_slash = 5'b00010;
            3: digit_slash = 5'b00100;
            4: digit_slash = 5'b01000;
            5: digit_slash = 5'b01000;
            6: digit_slash = 5'b10000;
            default: digit_slash = 5'b00000;
        endcase
    end
endfunction

// letter a
function [4:0] lettera;
    input [2:0] row;
    begin
        case(row)
            0: lettera = 5'b01110;
            1: lettera = 5'b10001;
            2: lettera = 5'b10001;
            3: lettera = 5'b11111;
            4: lettera = 5'b10001;
            5: lettera = 5'b10001;
            6: lettera = 5'b10001;
            default: lettera = 5'b00000;
        endcase
    end
endfunction

// letter b
function [4:0] letterb;
    input [2:0] row;
    begin
        case(row)
            0: letterb = 5'b11110;
            1: letterb = 5'b10001;
            2: letterb = 5'b10001;
            3: letterb = 5'b11110;
            4: letterb = 5'b10001;
            5: letterb = 5'b10001;
            6: letterb = 5'b11110;
            default: letterb = 5'b00000;
        endcase
    end
endfunction

// letter d
function [4:0] letterd;
    input [2:0] row;
    begin
        case(row)
            0: letterd = 5'b11110;
            1: letterd = 5'b10001;
            2: letterd = 5'b10001;
            3: letterd = 5'b10001;
            4: letterd = 5'b10001;
            5: letterd = 5'b10001;
            6: letterd = 5'b11110;
            default: letterd = 5'b00000;
        endcase
    end
endfunction

// letter e
function [4:0] lettere;
    input [2:0] row;
    begin
        case(row)
            0: lettere = 5'b11111;
            1: lettere = 5'b10000;
            2: lettere = 5'b10000;
            3: lettere = 5'b11111;
            4: lettere = 5'b10000;
            5: lettere = 5'b10000;
            6: lettere = 5'b11111;
            default: lettere = 5'b00000;
        endcase
    end
endfunction

// letter h
function [4:0] letterh;
    input [2:0] row;
    begin
        case(row)
            0: letterh = 5'b10001;
            1: letterh = 5'b10001;
            2: letterh = 5'b10001;
            3: letterh = 5'b11111;
            4: letterh = 5'b10001;
            5: letterh = 5'b10001;
            6: letterh = 5'b10001;
            default: letterh = 5'b00000;
        endcase
    end
endfunction

// letter m
function [4:0] letterm;
    input [2:0] row;
    begin
        case(row)
            0: letterm = 5'b10001;
            1: letterm = 5'b11011;
            2: letterm = 5'b11111;
            3: letterm = 5'b10101;
            4: letterm = 5'b10001;
            5: letterm = 5'b10001;
            6: letterm = 5'b10001;
            default: letterm = 5'b00000;
        endcase
    end
endfunction

// letter n
function [4:0] lettern;
    input [2:0] row;
    begin
        case(row)
            0: lettern = 5'b10001;
            1: lettern = 5'b11001;
            2: lettern = 5'b11101;
            3: lettern = 5'b10101;
            4: lettern = 5'b10111;
            5: lettern = 5'b10011;
            6: lettern = 5'b10001;
            default: lettern = 5'b00000;
        endcase
    end
endfunction

// letter o
function [4:0] lettero;
    input [2:0] row;
    begin
        case(row)
            0: lettero = 5'b01110;
            1: lettero = 5'b10001;
            2: lettero = 5'b10001;
            3: lettero = 5'b10001;
            4: lettero = 5'b10001;
            5: lettero = 5'b10001;
            6: lettero = 5'b01110;
            default: lettero = 5'b00000;
        endcase
    end
endfunction

// letter p
function [4:0] letterp;
    input [2:0] row;
    begin
        case(row)
            0: letterp = 5'b11110;
            1: letterp = 5'b10001;
            2: letterp = 5'b10001;
            3: letterp = 5'b11110;
            4: letterp = 5'b10000;
            5: letterp = 5'b10000;
            6: letterp = 5'b10000;
            default: letterp = 5'b00000;
        endcase
    end
endfunction

// letter r
function [4:0] letterr;
    input [2:0] row;
    begin
        case(row)
            0: letterr = 5'b11110;
            1: letterr = 5'b10001;
            2: letterr = 5'b10001;
            3: letterr = 5'b11110;
            4: letterr = 5'b10110;
            5: letterr = 5'b10011;
            6: letterr = 5'b10001;
            default: letterr = 5'b00000;
        endcase
    end
endfunction

// letter s
function [4:0] letters;
    input [2:0] row;
    begin
        case(row)
            0: letters = 5'b01111;
            1: letters = 5'b10000;
            2: letters = 5'b10000;
            3: letters = 5'b01110;
            4: letters = 5'b00001;
            5: letters = 5'b00001;
            6: letters = 5'b11110;
            default: letters = 5'b00000;
        endcase
    end
endfunction

// letter t
function [4:0] lettert;
    input [2:0] row;
    begin
        case(row)
            0: lettert = 5'b11111;
            1: lettert = 5'b00100;
            2: lettert = 5'b00100;
            3: lettert = 5'b00100;
            4: lettert = 5'b00100;
            5: lettert = 5'b00100;
            6: lettert = 5'b00100;
            default: lettert = 5'b00000;
        endcase
    end
endfunction

// letter u
function [4:0] letteru;
    input [2:0] row;
    begin
        case(row)
            0: letteru = 5'b10001;
            1: letteru = 5'b10001;
            2: letteru = 5'b10001;
            3: letteru = 5'b10001;
            4: letteru = 5'b10001;
            5: letteru = 5'b10001;
            6: letteru = 5'b01110;
            default: letteru = 5'b00000;
        endcase
    end
endfunction

// letter y
function [4:0] lettery;
    input [2:0] row;
    begin
        case(row)
            0: lettery = 5'b10001;
            1: lettery = 5'b10001;
            2: lettery = 5'b01010;
            3: lettery = 5'b01110;
            4: lettery = 5'b00100;
            5: lettery = 5'b00100;
            6: lettery = 5'b00100;
            default: lettery = 5'b00000;
        endcase
    end
endfunction

// letter c
function [4:0] letterc;
    input [2:0] row;
    begin
        case(row)
            0: letterc = 5'b01111;
            1: letterc = 5'b10000;
            2: letterc = 5'b10000;
            3: letterc = 5'b10000;
            4: letterc = 5'b10000;
            5: letterc = 5'b10000;
            6: letterc = 5'b01111;
            default: letterc = 5'b00000;
        endcase
    end
endfunction

// letter i
function [4:0] letteri;
    input [2:0] row;
    begin
        case(row)
            0: letteri = 5'b11111;
            1: letteri = 5'b00100;
            2: letteri = 5'b00100;
            3: letteri = 5'b00100;
            4: letteri = 5'b00100;
            5: letteri = 5'b00100;
            6: letteri = 5'b11111;
            default: letteri = 5'b00000;
        endcase
    end
endfunction

// letter k
function [4:0] letterk;
    input [2:0] row;
    begin
        case(row)
            0: letterk = 5'b10001;
            1: letterk = 5'b10010;
            2: letterk = 5'b10010;
            3: letterk = 5'b11100;
            4: letterk = 5'b10010;
            5: letterk = 5'b10010;
            6: letterk = 5'b10001;
            default: letterk = 5'b00000;
        endcase
    end
endfunction

// select left icon
function [4:0] selectl;
    input [2:0] row;
    begin
        case(row)
            0: selectl = 5'b00000;
            1: selectl = 5'b00000;
            2: selectl = 5'b11111;
            3: selectl = 5'b10000;
            4: selectl = 5'b10000;
            5: selectl = 5'b10000;
            6: selectl = 5'b11111;
            default: selectl = 5'b00000;
        endcase
    end
endfunction

// select middle icon
function [4:0] selectm;
    input [2:0] row;
    begin
        case(row)
            0: selectm = 5'b00000;
            1: selectm = 5'b00000;
            2: selectm = 5'b11111;
            3: selectm = 5'b00000;
            4: selectm = 5'b00000;
            5: selectm = 5'b00000;
            6: selectm = 5'b11111;
            default: selectm = 5'b00000;
        endcase
    end
endfunction

// select right icon
function [4:0] selectr;
    input [2:0] row;
    begin
        case(row)
            0: selectr = 5'b00000;
            1: selectr = 5'b00000;
            2: selectr = 5'b11111;
            3: selectr = 5'b00001;
            4: selectr = 5'b00001;
            5: selectr = 5'b00001;
            6: selectr = 5'b11111;
            default: selectr = 5'b00000;
        endcase
    end
endfunction


function [4:0] get_digit_row;
    input [5:0] digit;
    input [2:0] row;
    begin
        case (digit)
            0: get_digit_row = digit0(row);
            1: get_digit_row = digit1(row);
            2: get_digit_row = digit2(row);
            3: get_digit_row = digit3(row);
            4: get_digit_row = digit4(row);
            5: get_digit_row = digit5(row);
            6: get_digit_row = digit6(row);
            7: get_digit_row = digit7(row);
            8: get_digit_row = digit8(row);
            9: get_digit_row = digit9(row);
				10: get_digit_row = digit_slash(row);
				11: get_digit_row = lettera(row);
				12: get_digit_row = letterb(row);
				13: get_digit_row = letterd(row);
				14: get_digit_row = lettere(row);
				15: get_digit_row = letterh(row);
				16: get_digit_row = letterm(row);
				17: get_digit_row = lettern(row);
				18: get_digit_row = lettero(row);
				19: get_digit_row = letterp(row);
				20: get_digit_row = letterr(row);
				21: get_digit_row = letters(row);
				22: get_digit_row = lettert(row);
				23: get_digit_row = letteru(row);
				24: get_digit_row = lettery(row);
				25: get_digit_row = selectl(row);
				26: get_digit_row = selectm(row);
				27: get_digit_row = selectr(row);
				28: get_digit_row = letterc(row);
				29: get_digit_row = letteri(row);
				30: get_digit_row = letterk(row);
            default: get_digit_row = 5'b00000;
        endcase
    end
endfunction

// Returns 1 if (x,y) lies on the digit pixel
function draw_digit;
    input [9:0] x, y;        // screen pixel
    input [9:0] digit_x;     // upper-left corner
    input [9:0] digit_y;
    input [5:0] digit;   
    input [5:0] scale;       // scale factor
    reg inside;
    reg [2:0] px, py;
    reg [4:0] bits;
    begin
        inside =
            (x >= digit_x) && (x < digit_x + 5*scale) &&
            (y >= digit_y) && (y < digit_y + 7*scale);

        if (!inside) begin
            draw_digit = 0;
        end else begin
            px = (x - digit_x) / scale;
            py = (y - digit_y) / scale;
            bits = get_digit_row(digit, py);
            draw_digit = bits[4 - px];
        end
    end
endfunction




wire d4 = draw_digit(x, y, 100, 20, 4, 3);
wire d3 = draw_digit(x, y, 120, 20, 3, 3);
wire timesig = draw_digit(x, y, 140, 20, 10, 3);

wire lm1 = draw_digit(x, y, 25, 120, 16, 4);
wire le = draw_digit(x, y, 50, 120, 14, 4);
wire ln = draw_digit(x, y, 75, 120, 17, 4);
wire lu1 = draw_digit(x, y, 100, 120, 23, 4);

wire ld = draw_digit(x, y, 25, 200, 13, 4);
wire lr = draw_digit(x, y, 50, 200, 20, 4);
wire lu2 = draw_digit(x, y, 75, 200, 23, 4);
wire lm2 = draw_digit(x, y,100, 200, 16, 4);

wire ls = draw_digit(x, y, 25, 280, 21, 4);
wire ly = draw_digit(x, y, 50, 280, 24, 4);
wire ln2 = draw_digit(x, y, 75, 280, 17, 4);
wire lt = draw_digit(x, y, 100, 280, 22, 4);
wire lh = draw_digit(x, y, 125, 280, 15, 4);

wire ld2 = draw_digit(x, y, 25, 360, 13, 4);
wire le2 = draw_digit(x, y, 50, 360, 14, 4);
wire lm3 = draw_digit(x, y, 75, 360, 16, 4);
wire lo = draw_digit(x, y, 100, 360, 18, 4);

// BPM section
wire lb = draw_digit(x, y, 400, 20, 12, 4);
wire lp = draw_digit(x, y, 425, 20, 19, 4);
wire lm4 = draw_digit(x, y, 450, 20, 16, 4);

// tempo value
wire hundreds = draw_digit(x, y, 500, 20, bpm_hundreds, 4);
wire tens = draw_digit(x, y, 525, 20, bpm_tens, 4);
wire ones = draw_digit(x, y, 550, 20, bpm_ones, 4);



// select icons
wire select1l = draw_digit(x, y, 0, 80, 25, 12);
wire select1m = draw_digit(x, y, 40, 80, 26, 12);
wire select1r = draw_digit(x, y, 80, 80, 27, 12);

wire select2l = draw_digit(x, y, 0, 160, 25, 12);
wire select2m = draw_digit(x, y, 40, 160, 26, 12);
wire select2r = draw_digit(x, y, 80, 160, 27, 12);

wire select3l = draw_digit(x, y, 0, 240, 25, 12);
wire select3m = draw_digit(x, y, 55, 240, 26, 12);
wire select3r = draw_digit(x, y, 110, 240, 27, 12);


wire select4l = draw_digit(x, y, 0, 320, 25, 12);
wire select4m = draw_digit(x, y, 40, 320, 26, 12);
wire select4r = draw_digit(x, y, 80, 320, 27, 12);

// SELECTED icons
wire selected1l = draw_digit(x, y, 0, 80, 25, 12);
wire selected1m = draw_digit(x, y, 40, 80, 26, 12);
wire selected1r = draw_digit(x, y, 80, 80, 27, 12);

wire selected2l = draw_digit(x, y, 0, 160, 25, 12);
wire selected2m = draw_digit(x, y, 40, 160, 26, 12);
wire selected2r = draw_digit(x, y, 80, 160, 27, 12);

wire selected3l = draw_digit(x, y, 0, 240, 25, 12);
wire selected3m = draw_digit(x, y, 55, 240, 26, 12);
wire selected3r = draw_digit(x, y, 110, 240, 27, 12);


wire selected4l = draw_digit(x, y, 0, 320, 25, 12);
wire selected4m = draw_digit(x, y, 40, 320, 26, 12);
wire selected4r = draw_digit(x, y, 80, 320, 27, 12);

// ---------------- MENU SCREEN DRAW ---------------- //

// drum menu text
wire menu_drum3 = draw_digit(x, y, 375, 100, 13, 2);
wire menu_drum2 = draw_digit(x, y, 390, 100, 20, 2);
wire menu_drum1 = draw_digit(x, y, 405, 100, 23, 2);
wire menu_drum0 = draw_digit(x, y, 420, 100, 16, 2);

// synth menu text
wire menu_synth4 = draw_digit(x, y, 370, 260, 21, 2);
wire menu_synth3 = draw_digit(x, y, 385, 260, 24, 2);
wire menu_synth2 = draw_digit(x, y, 400, 260, 17, 2);
wire menu_synth1 = draw_digit(x, y, 415, 260, 22, 2);
wire menu_synth0 = draw_digit(x, y, 430, 260, 15, 2);

// menu measure for DRUM
parameter beats      = 9;
parameter beat_spacing = 50;
parameter beat_line_w = 3;

parameter measure_x = 200;
parameter measure_y = 140;
parameter measure_w = beat_spacing * (beats - 1) + beat_line_w;
parameter measure_h = 80;

parameter light_grey = 24'hCFCFCF;
parameter white        = 24'hFFFFFF;
parameter measure_grey = 24'h707070;
parameter beat_grey    = 24'hA0A0A0;
parameter beat_white   = 24'hE0E0E0;


wire measure_bg =
    (x >= measure_x && x < measure_x + measure_w &&
     y >= measure_y && y < measure_y + measure_h);
	  
wire beat1 = (x >= measure_x + beat_spacing*0 && x < measure_x + beat_spacing*0 + beat_line_w);
wire beat2 = (x >= measure_x + beat_spacing*1 && x < measure_x + beat_spacing*1 + beat_line_w);
wire beat3 = (x >= measure_x + beat_spacing*2 && x < measure_x + beat_spacing*2 + beat_line_w);
wire beat4 = (x >= measure_x + beat_spacing*3 && x < measure_x + beat_spacing*3 + beat_line_w);
wire beat5 = (x >= measure_x + beat_spacing*4 && x < measure_x + beat_spacing*4 + beat_line_w);
wire beat6 = (x >= measure_x + beat_spacing*5 && x < measure_x + beat_spacing*5 + beat_line_w);
wire beat7 = (x >= measure_x + beat_spacing*6 && x < measure_x + beat_spacing*6 + beat_line_w);
wire beat8 = (x >= measure_x + beat_spacing*7 && x < measure_x + beat_spacing*7 + beat_line_w);
wire beat9 = (x >= measure_x + beat_spacing*8 && x < measure_x + beat_spacing*8 + beat_line_w);


wire beat_y =
    (y >= measure_y && y < measure_y + measure_h);

wire menu_drum_draw =
    (menu_s || drum_s || demo_s) &&
    (menu_drum3 || menu_drum2 || menu_drum1 || menu_drum0);

wire menu_synth_draw =
    (menu_s || synth_s || demo_s) &&
    (menu_synth4 || menu_synth3 || menu_synth2 || menu_synth1 || menu_synth0);
	 
wire measure_on = measure_bg && (menu_s || drum_s || demo_s);

wire beat_line_grey =
    beat_y && (menu_s || drum_s || demo_s) &&
    (beat1 || beat2 || beat3 || beat4 || beat6 || beat7 || beat8 || beat9);

wire beat_line_white =
    beat_y && (menu_s || drum_s || demo_s) && beat5;

// menu measure for synth

parameter synth_measure_y = 300;

wire synth_measure_bg =
    (x >= measure_x && x < measure_x + measure_w &&
     y >= synth_measure_y && y < synth_measure_y + measure_h);

wire synth_beat_y =
    (y >= synth_measure_y && y < synth_measure_y + measure_h);

wire synth_beat_line_grey =
    synth_beat_y && (menu_s || synth_s || demo_s) &&
    (beat1 || beat2 || beat3 || beat4 || beat6 || beat7 || beat8 || beat9);

wire synth_beat_line_white =
    synth_beat_y && (menu_s || synth_s || demo_s) && beat5;

wire synth_measure_on =
    synth_measure_bg && (menu_s || synth_s || demo_s);
	 
// measure playheads
wire [9:0] drum_playhead_x;
wire [9:0] synth_playhead_x;

// playhead instantiations
playhead drum_ph (clk, rst, is_playing, bpm, measure_x, measure_w, beat_spacing, drum_playhead_x);

playhead synth_ph (clk, rst, is_playing, bpm, measure_x, measure_w, beat_spacing, synth_playhead_x);


wire drum_playhead =
    is_playing &&
    (menu_s || drum_s || demo_s) &&
    (x >= drum_playhead_x && x < drum_playhead_x + 2) &&
    (y >= measure_y && y < measure_y + measure_h);

wire synth_playhead =
    is_playing &&
    (menu_s || synth_s || demo_s) &&
    (x >= synth_playhead_x && x < synth_playhead_x + 2) &&
    (y >= synth_measure_y && y < synth_measure_y + measure_h);

	 
	// drum screen selections 
wire kick_sel, snare_sel, hat_sel, chip_sel;
   // drum screen instantiations
drum_sound_select drum_sounds (clk, rst, KEY[2], kick_sel, snare_sel, hat_sel, chip_sel);

parameter drum_sel_y    = measure_y + measure_h + 20;
parameter drum_sel_h    = 44;
parameter drum_sel_gap  = 14;

parameter kick_w  = 92; 
parameter snare_w = 114;
parameter hat_w   = 70;
parameter chip_w  = 92;

parameter kick_x  = measure_x;
parameter snare_x = kick_x  + kick_w  + drum_sel_gap;
parameter hat_x   = snare_x + snare_w + drum_sel_gap;
parameter chip_x  = hat_x   + hat_w   + drum_sel_gap;

// DRUM TEXT
wire kick_text  = drum_s && (kick_k || kick_i || kick_c || kick_k2);
wire snare_text = drum_s && (sn_s || sn_n || sn_a || sn_r || sn_e);
wire hat_text   = drum_s && (hat_h || hat_a || hat_t);
wire chip_text  = drum_s && (chip_c || chip_h || chip_i || chip_p);

// DRUM SELECTION BACKGROUND
wire kick_bg  = drum_s && kick_sel  && kick_box;
wire snare_bg = drum_s && snare_sel && snare_box;
wire hat_bg   = drum_s && hat_sel   && hat_box;
wire chip_bg  = drum_s && chip_sel  && chip_box;


wire kick_box  = drum_s &&
    (x >= kick_x  && x < kick_x  + kick_w) &&
    (y >= drum_sel_y && y < drum_sel_y + drum_sel_h);

wire snare_box = drum_s &&
    (x >= snare_x && x < snare_x + snare_w) &&
    (y >= drum_sel_y && y < drum_sel_y + drum_sel_h);

wire hat_box   = drum_s &&
    (x >= hat_x   && x < hat_x   + hat_w) &&
    (y >= drum_sel_y && y < drum_sel_y + drum_sel_h);

wire chip_box  = drum_s &&
    (x >= chip_x  && x < chip_x  + chip_w) &&
    (y >= drum_sel_y && y < drum_sel_y + drum_sel_h);


	// letters
wire kick_k  = draw_digit(x, y, kick_x  + 10, drum_sel_y + 8, 30, 4);
wire kick_i  = draw_digit(x, y, kick_x  + 32, drum_sel_y + 8, 29, 4);
wire kick_c  = draw_digit(x, y, kick_x  + 54, drum_sel_y + 8, 28, 4);
wire kick_k2 = draw_digit(x, y, kick_x  + 76, drum_sel_y + 8, 30, 4);

wire sn_s = draw_digit(x, y, snare_x + 8,  drum_sel_y + 8, 21, 4);
wire sn_n = draw_digit(x, y, snare_x + 30, drum_sel_y + 8, 17, 4);
wire sn_a = draw_digit(x, y, snare_x + 52, drum_sel_y + 8, 11, 4);
wire sn_r = draw_digit(x, y, snare_x + 74, drum_sel_y + 8, 20, 4);
wire sn_e = draw_digit(x, y, snare_x + 96, drum_sel_y + 8, 14, 4);

wire hat_h = draw_digit(x, y, hat_x + 10, drum_sel_y + 8, 15, 4);
wire hat_a = draw_digit(x, y, hat_x + 32, drum_sel_y + 8, 11, 4);
wire hat_t = draw_digit(x, y, hat_x + 54, drum_sel_y + 8, 22, 4);

wire chip_c = draw_digit(x, y, chip_x + 10, drum_sel_y + 8, 28, 4);
wire chip_h = draw_digit(x, y, chip_x + 32, drum_sel_y + 8, 15, 4);
wire chip_i = draw_digit(x, y, chip_x + 54, drum_sel_y + 8, 29, 4);
wire chip_p = draw_digit(x, y, chip_x + 76, drum_sel_y + 8, 19, 4);



	// drum screen measure select
wire measure1_sel, measure2_sel;
	// drum measure selections
drum_measure_select measure_select (clk, rst, KEY[2], measure1_sel, measure2_sel);

parameter meas_sel_y = drum_sel_y + drum_sel_h + 16;
parameter meas_sel_w = 48;
parameter meas_sel_h = 44;
parameter meas_gap   = 20;

parameter meas1_x = measure_x;
parameter meas2_x = meas1_x + meas_sel_w + meas_gap;

wire meas1_box =
    drum_s &&
    (x >= meas1_x && x < meas1_x + meas_sel_w) &&
    (y >= meas_sel_y && y < meas_sel_y + meas_sel_h);

wire meas2_box =
    drum_s &&
    (x >= meas2_x && x < meas2_x + meas_sel_w) &&
    (y >= meas_sel_y && y < meas_sel_y + meas_sel_h);
	 
wire meas1_txt = draw_digit(x, y, meas1_x + 14, meas_sel_y + 8, 1, 4);

wire meas2_txt = draw_digit(x, y, meas2_x + 14, meas_sel_y + 8, 2, 4);




// logic instantiations
select_logic my_select(clk, rst, KEY[3:0], menu, drum, synth, demo);
selected_logic my_selected(clk, rst, KEY[1], menu, drum, synth, demo, menu_s, drum_s, synth_s, demo_s);
bpm_logic my_bpm(clk, rst, SW[1], KEY[0], bpm);

//--------------------------------------------------------------------------------
parameter grey  = 24'hA0A0A0;
parameter black = 24'h000000;
parameter red = 24'hFF0000;


reg [23:0] shape_color;
reg [23:0] background_color;

always @(*)
begin

	if (left_bar & is_playing)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (right_bar && is_playing)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (play_button && is_paused)
	{VGA_R, VGA_G, VGA_B} = white;	
	
	else if (d4)
	{VGA_R, VGA_G, VGA_B} = white;	

	else if (d3)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (timesig)
	{VGA_R, VGA_G, VGA_B} = white;

	// menu, drum, synth, demo
	// menu
	else if (lm1)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (le)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (ln)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lu1)
	{VGA_R, VGA_G, VGA_B} = white;
	
	// drum
	else if (ld)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lr)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lu2)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lm2)
	{VGA_R, VGA_G, VGA_B} = white;
	
	// synth
	else if (ls)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (ly)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (ln2)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lt)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lh)
	{VGA_R, VGA_G, VGA_B} = white;
	
	// demo
	else if (ld2)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (le2)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lm3)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lo)
	{VGA_R, VGA_G, VGA_B} = white;
	
	// BPM
	else if (lb)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lp)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (lm4)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (hundreds)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (tens)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (ones)
	{VGA_R, VGA_G, VGA_B} = white;
	
	
	// select bars
	else if (select1l && menu)
	{VGA_R, VGA_G, VGA_B} = grey;
	
		else if (select1m && menu)
	{VGA_R, VGA_G, VGA_B} = grey;
	
	else if (select1r && menu)
	{VGA_R, VGA_G, VGA_B} = grey;
	
	else if (select2l && drum)
	{VGA_R, VGA_G, VGA_B} = grey;
	
		else if (select2m && drum)
	{VGA_R, VGA_G, VGA_B} = grey;
	
	else if (select2r && drum)
	{VGA_R, VGA_G, VGA_B} = grey;
	
	else if (select3l && synth)
	{VGA_R, VGA_G, VGA_B} = grey;
	
		else if (select3m && synth)
	{VGA_R, VGA_G, VGA_B} = grey;
	
	else if (select3r && synth)
	{VGA_R, VGA_G, VGA_B} = grey;
	
	else if (select4l && demo)
	{VGA_R, VGA_G, VGA_B} = grey;

	else if (select4m && demo)
	{VGA_R, VGA_G, VGA_B} = grey;
	
	else if (select4r && demo)
	{VGA_R, VGA_G, VGA_B} = grey;
	
	// SELECTED bars
	else if (selected1l && menu_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected1m && menu_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected1r && menu_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected2l && drum_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected2m && drum_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected2r && drum_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected3l && synth_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected3m && synth_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected3r && synth_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected4l && demo_s)
	{VGA_R, VGA_G, VGA_B} = white;

	else if (selected4m && demo_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	else if (selected4r && demo_s)
	{VGA_R, VGA_G, VGA_B} = white;
	
	
	// ------------------------------------//
	
	// MENU SCREEN
else if (menu_drum_draw)
    {VGA_R, VGA_G, VGA_B} = white;

else if (menu_synth_draw)
    {VGA_R, VGA_G, VGA_B} = white;
	 
	   // PLAYHEADS
else if (drum_playhead)
    {VGA_R, VGA_G, VGA_B} = 24'h0000FF;

else if (synth_playhead)
    {VGA_R, VGA_G, VGA_B} = 24'h0000FF;

	// DRUM MEASURE
else if (beat_line_white)
  {VGA_R, VGA_G, VGA_B} = beat_white;

else if (beat_line_grey)
  {VGA_R, VGA_G, VGA_B} = beat_grey;

else if (measure_on)
  {VGA_R, VGA_G, VGA_B} = measure_grey;
  
  // SYNTH MEASURE
else if (synth_beat_line_white)
  {VGA_R, VGA_G, VGA_B} = beat_white;

else if (synth_beat_line_grey)
  {VGA_R, VGA_G, VGA_B} = beat_grey;

else if (synth_measure_on)
  {VGA_R, VGA_G, VGA_B} = measure_grey;

  
 // MEASURE SELECT
else if (meas1_box && measure1_sel)
    {VGA_R, VGA_G, VGA_B} = white;

else if (meas2_box && measure2_sel)
    {VGA_R, VGA_G, VGA_B} = white;

else if (meas1_box || meas2_box)
    {VGA_R, VGA_G, VGA_B} = grey;

else if (measure1_sel && meas1_txt)
    {VGA_R, VGA_G, VGA_B} = white;

else if (measure2_sel && meas2_txt)
    {VGA_R, VGA_G, VGA_B} = white;
  
  
 // DRUM TEXT
else if (kick_text)
    {VGA_R, VGA_G, VGA_B} = white;

else if (snare_text)
    {VGA_R, VGA_G, VGA_B} = white;

else if (hat_text)
    {VGA_R, VGA_G, VGA_B} = white;

else if (chip_text)
    {VGA_R, VGA_G, VGA_B} = white;

// DRUM SELECTION BACKGROUND
else if (kick_bg)
    {VGA_R, VGA_G, VGA_B} = grey;

else if (snare_bg)
    {VGA_R, VGA_G, VGA_B} = grey;

else if (hat_bg)
    {VGA_R, VGA_G, VGA_B} = grey;

else if (chip_bg)
    {VGA_R, VGA_G, VGA_B} = grey;

  
	else
	{VGA_R, VGA_G, VGA_B} = black; //background
	
end


// STATES FOR PAUSE/PLAY
reg is_paused;
reg is_playing;

reg[2:0] S, NS;

parameter  IDLE      = 3'd0,
			  PLAY   	= 3'd1,
			  PLAY_WAIT = 3'd2,		
			  PAUSE 		= 3'd3,
			  PAUSE_WAIT = 3'd4;

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= IDLE;
	else
		S <= NS;
end

always @(*)
begin
case(S)
	IDLE: if (KEY[3] == 1'b0)
				NS = PLAY;
			else
				NS = IDLE;
	
	PLAY: if (KEY[3] == 1'b1)
				NS = PLAY_WAIT;
			else
				NS = PLAY;
	PLAY_WAIT: if (KEY[3] == 1'b0)
				NS = PAUSE;
			else
				NS = PLAY_WAIT;
	PAUSE: if (KEY[3] == 1'b1)
				NS = PAUSE_WAIT;
			else
				NS = PAUSE;
	PAUSE_WAIT: if (KEY[3] == 1'b0)
						NS = PLAY;
					else
						NS = PAUSE_WAIT;
endcase
end

always @(posedge clk or negedge rst)
begin
	if (!rst)
	begin
		is_paused <= 1'b1;
		is_playing <= 1'b0;
	end
	else
		case(S)
			IDLE: begin
				is_paused <= 1'b1;
				is_playing <= 1'b0;
				end
			PLAY: begin
				is_paused <= 1'b0;
				is_playing <= 1'b1;
				end
			PLAY_WAIT: begin
				is_paused <= 1'b0;
				is_playing <= 1'b1;
				end
			PAUSE: begin
				is_paused <= 1'b1;
				is_playing <= 1'b0;
				end
			PAUSE_WAIT: begin
				is_paused <= 1'b1;
				is_playing <= 1'b0;
				end
		endcase
end

endmodule


