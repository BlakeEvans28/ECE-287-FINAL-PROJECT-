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


function [4:0] get_digit_row;
    input [3:0] digit;
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
            default: get_digit_row = 5'b00000;
        endcase
    end
endfunction

// Returns 1 if (x,y) lies on the digit pixel
function draw_digit;
    input [9:0] x, y;        // screen pixel
    input [9:0] digit_x;     // upper-left corner
    input [9:0] digit_y;
    input [3:0] digit;       // number 0–9
    input [3:0] scale;       // scale factor
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

//--------------------------------------------------------------------------------
parameter white = 24'hFFFFFF;
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
	
	else
	{VGA_R, VGA_G, VGA_B} = black; //background
	
end

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


