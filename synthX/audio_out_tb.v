`timescale 1ns/1ps

module audio_out_tb();
	localparam CLOCK_PERIOD_NS = 20;

	reg clk = 0;
	always #(CLOCK_PERIOD_NS/2) clk <= !clk;

	reg aclr = 0;
	reg wrreq = 0;
	reg [63:0] sample = 64'd0;
	wire wrfull;
	wire lrck;
	wire bck;
	wire dout;
	wire sck;

	audio_out MUT
		(
			.clk(clk),
			.aclr(aclr),
			.sample(sample),
			.wrreq(wrreq),
			.wrfull(wrfull),
			.lrck(lrck),
			.bck(bck),
			.dout(dout),
			.sck(sck)
		);

	initial
		begin
			#CLOCK_PERIOD_NS
			aclr <= 1;
			#CLOCK_PERIOD_NS
			aclr <= 0;
			#CLOCK_PERIOD_NS
			sample[63:32] <= 1024;
			sample[31:0] <= 4000;
			#150 // let pll sync
			#CLOCK_PERIOD_NS
			wrreq <= 1;
			#CLOCK_PERIOD_NS
			// ready should fall
			wrreq <= 0;
			#(CLOCK_PERIOD_NS * 2 * 2700)
			// ready should come back up
			$finish;
		end

endmodule
