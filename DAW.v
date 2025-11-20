module DAW (
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
	output reg	     [6:0]		HEX0,
	output reg	     [6:0]		HEX1,
	output reg	     [6:0]		HEX2,
	output reg	     [6:0]		HEX3,
	//output		     [6:0]		HEX4,
	//output		     [6:0]		HEX5,

	//////////// IR //////////
	//input 		          		IRDA_RXD,
	//output		          		IRDA_TXD,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output reg	     [9:0]		LEDR,

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

	//////////// GPIO_0 //////////
	//inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1 //////////
	//inout 		    [35:0]		GPIO_1
);

	// ========= Reset (KEY[0] active-low) =========
	// KEY[0] = 0 -> reset asserted (this matches vga_driver's active-low reset)
	wire rst = KEY[0];

	// ========= Wires from timing module =========
	wire        vga_clk_int;
	wire        hsync_int;
	wire        vsync_int;
	wire        active_pixels;
	wire [9:0]  xPixel;
	wire [9:0]  yPixel;

	// Instantiate the VGA timing driver (your instructor’s style)
	vga_driver timing_inst (
		.clk          (CLOCK_50),
		.rst          (rst),
		.vga_clk      (vga_clk_int),
		.hsync        (hsync_int),
		.vsync        (vsync_int),
		.active_pixels(active_pixels),
		.frame_done   (),           // unused for now
		.xPixel       (xPixel),
		.yPixel       (yPixel),
		.VGA_BLANK_N  (VGA_BLANK_N),
		.VGA_SYNC_N   (VGA_SYNC_N)
	);

	assign VGA_CLK = vga_clk_int;
	assign VGA_HS  = hsync_int;
	assign VGA_VS  = vsync_int;

	// ========= Wires from DAW main screen module =========
	wire [7:0] app_r;
	wire [7:0] app_g;
	wire [7:0] app_b;
	wire [6:0] hex0_int, hex1_int, hex2_int, hex3_int;
	wire [9:0] ledr_int;

	// ========= Instantiate MAIN PAGE / DAW FSM =========
	daw_main_screen main_ui (
		.vga_clk       (vga_clk_int),
		.rst_n         (KEY[0]),      // same KEY[0 active-low reset

		.xPixel        (xPixel),
		.yPixel        (yPixel),
		.active_pixels (active_pixels),

		.KEY           (KEY),
		.SW            (SW),

		.VGA_R         (app_r),
		.VGA_G         (app_g),
		.VGA_B         (app_b),

		.HEX0          (hex0_int),
		.HEX1          (hex1_int),
		.HEX2          (hex2_int),
		.HEX3          (hex3_int),
		.LEDR          (ledr_int)
	);

	// ========= Drive board outputs =========
	always @(*) begin
		// Pass through colors
		VGA_R = app_r;
		VGA_G = app_g;
		VGA_B = app_b;

		// 7-seg from app
		HEX0  = hex0_int;
		HEX1  = hex1_int;
		HEX2  = hex2_int;
		HEX3  = hex3_int;

		// LEDs from app
		LEDR  = ledr_int;
	end

endmodule
