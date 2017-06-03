/*
** i2s audio out w/ dual clock fifo, 32bit / channel and 48 kHz sample rate
**
** Dave Beck, beck.dac@live.com
*/

module audio_out
	(
		input clk,				// global input clock
		input aclr,				// asynchronous clear
		input [63:0] sample,	// next sample input
		input wrreq,			// active high sample input is ready
		output wrfull,			// active high the fifo is full
		output lrck,			// i2s, left / righ channel clock
		output bck,				// i2s, bit clock
		output dout,			// i2s, bit stream
		output sck				// i2s, system clock
	);

	wire pll_locked;
	wire clk_48kHz, clk_96kHz, clk_3MHz;	// sample clock, lrclock and bit clock

	// audio pll
	pll_audio PLL_AUDIO
		(
			.areset(aclr),
			.inclk0(clk),
			.c0 (clk_3MHz),
			.c1 (clk_48kHz),
			.c2 (clk_96kHz),
			.locked(pll_locked)
		);

	assign bck = clk_3MHz;
	assign sck = clk;

	wire [63:0] sample_out;
	wire i2s_ready_for_sample;
	wire rdempty;

	// dual clock fifo
	dcfifo_audio DCFIFO_AUDIO
		(
			.aclr(aclr),
			.data(sample),
			.rdclk(clk_3MHz),
			.rdreq(i2s_ready_for_sample),
			.wrclk(clk),
			.wrreq(wrreq),
			.q(sample_out),
			.rdempty(rdempty),
			.wrfull(wrfull)
		);

	assign sample_ready = !rdempty;
	
	// i2s transmitter
	i2s_tx I2S_TX
		(
			.sclk(clk_3MHz),
			.aclr(aclr),
			.lrck(lrck),
			.dout(dout),
			.ready(i2s_ready_for_sample),
			.sample_ready(sample_ready),
			.sample(sample_out)
		);	

endmodule
